import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../config/colors.dart';
import '../config/spacing.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';
import '../widgets/footer.dart';
import '../widgets/pages/products/filter_sidebar.dart';
import '../widgets/pages/products/mobile_filter_sheet.dart';
import '../widgets/pages/products/product_grid.dart';
import '../widgets/pages/products/sort_bar.dart';

/// Products listing customer – Modern Minimal.
///
/// Layout: Page header + (Filter sidebar | Sort bar + Product grid).
/// Mobile: filter sheet bottom-up, sort vẫn nằm trên grid.
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _categoryService = CategoryService();
  final _productService = ProductService();

  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<RangeValues> _priceRange =
      ValueNotifier(const RangeValues(0, 10000000));
  final ValueNotifier<ProductSort> _sort =
      ValueNotifier(ProductSort.none);

  String? _selectedParentId;
  String? _selectedChildId;
  bool _priceInitialized = false;

  final Map<String, String> _categoryNameCache = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _priceRange.dispose();
    _sort.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String? _categoryName(String id, List<CategoryModel> all) {
    if (_categoryNameCache.containsKey(id)) {
      return _categoryNameCache[id];
    }
    try {
      final n = all.firstWhere((c) => c.id == id).name;
      _categoryNameCache[id] = n;
      return n;
    } catch (_) {
      return null;
    }
  }

  List<ProductModel> _filterByCategoryAndStatus(
    List<ProductModel> products,
  ) {
    return products.where((p) {
      if (p.status != 'Còn hàng') return false;
      if (_selectedChildId != null) return p.childCategoryId == _selectedChildId;
      if (_selectedParentId != null) return p.categoryId == _selectedParentId;
      return true;
    }).toList();
  }

  List<ProductModel> _applySearchAndPrice(
    List<ProductModel> products,
    List<CategoryModel> categories,
    RangeValues range,
  ) {
    final query = _searchController.text.toLowerCase().trim();
    return products.where((p) {
      // Price
      if (p.price < range.start || p.price > range.end) return false;

      // Search
      if (query.isNotEmpty) {
        if (!p.name.toLowerCase().contains(query)) {
          final cat = _categoryName(p.categoryId, categories)?.toLowerCase() ?? '';
          final desc = p.description?.toLowerCase() ?? '';
          if (!cat.contains(query) && !desc.contains(query)) return false;
        }
      }
      return true;
    }).toList();
  }

  List<ProductModel> _sortList(
    List<ProductModel> products,
    ProductSort sort,
  ) {
    if (sort == ProductSort.none) return products;
    final out = List<ProductModel>.from(products);
    switch (sort) {
      case ProductSort.nameAsc:
        out.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ProductSort.nameDesc:
        out.sort((a, b) => b.name.compareTo(a.name));
        break;
      case ProductSort.priceAsc:
        out.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSort.priceDesc:
        out.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSort.none:
        break;
    }
    return out;
  }

  void _resetAll(double minPrice, double maxPrice) {
    setState(() {
      _searchController.clear();
      _selectedParentId = null;
      _selectedChildId = null;
    });
    _priceRange.value = RangeValues(minPrice, maxPrice);
    _sort.value = ProductSort.none;
  }

  void _openMobileFilter({
    required List<CategoryModel> parents,
    required List<CategoryModel> children,
    required double minPrice,
    required double maxPrice,
    required int totalResults,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => MobileFilterSheet(
          searchController: _searchController,
          parentCategories: parents,
          childCategories: children,
          selectedParentId: _selectedParentId,
          selectedChildId: _selectedChildId,
          onParentSelected: (id) {
            setSheetState(() {});
            setState(() {
              _selectedParentId = id;
              _selectedChildId = null;
            });
          },
          onChildSelected: (id) {
            setSheetState(() {});
            setState(() => _selectedChildId = id);
          },
          priceRange: _priceRange.value,
          minPrice: minPrice,
          maxPrice: maxPrice,
          onPriceChanged: (v) {
            setSheetState(() {});
            _priceRange.value = v;
          },
          onReset: () {
            setSheetState(() {});
            _resetAll(minPrice, maxPrice);
          },
          totalResults: totalResults,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Container(
      color: AppColors.surface,
      child: StreamBuilder<List<CategoryModel>>(
        stream: _categoryService.getCategories(),
        builder: (context, catSnap) {
          if (catSnap.connectionState == ConnectionState.waiting) {
            return const _LoadingState();
          }
          if (catSnap.hasError) {
            return _ErrorState(message: catSnap.error.toString());
          }

          final allCategories = catSnap.data ?? const <CategoryModel>[];
          final parents = allCategories
              .where((c) => c.parentId == null && c.status == 'Hiển thị')
              .toList();
          final children = _selectedParentId == null
              ? <CategoryModel>[]
              : allCategories
                  .where((c) =>
                      c.parentId == _selectedParentId &&
                      c.status == 'Hiển thị')
                  .toList();

          return StreamBuilder<List<ProductModel>>(
            stream: _productService.getProducts(),
            builder: (context, prodSnap) {
              if (prodSnap.connectionState == ConnectionState.waiting) {
                return const _LoadingState();
              }
              if (prodSnap.hasError) {
                return _ErrorState(message: prodSnap.error.toString());
              }

              final all = prodSnap.data ?? const <ProductModel>[];
              final filteredByCategory = _filterByCategoryAndStatus(all);

              final minPrice = filteredByCategory.isEmpty
                  ? 0.0
                  : filteredByCategory
                      .map((p) => p.price.toDouble())
                      .reduce((a, b) => a < b ? a : b);
              final maxPrice = filteredByCategory.isEmpty
                  ? 10000000.0
                  : filteredByCategory
                      .map((p) => p.price.toDouble())
                      .reduce((a, b) => a > b ? a : b);

              if (!_priceInitialized && filteredByCategory.isNotEmpty) {
                _priceRange.value = RangeValues(minPrice, maxPrice);
                _priceInitialized = true;
              }
              // Clamp khi range vượt min/max mới
              final cur = _priceRange.value;
              if (cur.start < minPrice ||
                  cur.end > maxPrice ||
                  cur.start > cur.end) {
                Future.microtask(() {
                  _priceRange.value = RangeValues(
                    cur.start.clamp(minPrice, maxPrice),
                    cur.end.clamp(minPrice, maxPrice),
                  );
                });
              }

              return ValueListenableBuilder<RangeValues>(
                valueListenable: _priceRange,
                builder: (_, range, __) {
                  return ValueListenableBuilder<ProductSort>(
                    valueListenable: _sort,
                    builder: (_, sort, __) {
                      final filtered = _applySearchAndPrice(
                        filteredByCategory,
                        allCategories,
                        range,
                      );
                      final products = _sortList(filtered, sort);

                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _PageHeader(),
                            if (isMobile)
                              _MobileBody(
                                products: products,
                                allCategories: allCategories,
                                totalResults: products.length,
                                sort: sort,
                                onSortChanged: (v) => _sort.value = v,
                                onOpenFilter: () => _openMobileFilter(
                                  parents: parents,
                                  children: children,
                                  minPrice: minPrice,
                                  maxPrice: maxPrice,
                                  totalResults: products.length,
                                ),
                                onTapProduct: (p) =>
                                    context.go('/products/${p.id}'),
                              )
                            else
                              _DesktopBody(
                                isTablet: isTablet,
                                searchController: _searchController,
                                parentCategories: parents,
                                childCategories: children,
                                selectedParentId: _selectedParentId,
                                selectedChildId: _selectedChildId,
                                onParentSelected: (id) {
                                  setState(() {
                                    _selectedParentId = id;
                                    _selectedChildId = null;
                                  });
                                },
                                onChildSelected: (id) =>
                                    setState(() => _selectedChildId = id),
                                priceRange: range,
                                minPrice: minPrice,
                                maxPrice: maxPrice,
                                onPriceChanged: (v) =>
                                    _priceRange.value = v,
                                onReset: () =>
                                    _resetAll(minPrice, maxPrice),
                                products: products,
                                allCategories: allCategories,
                                sort: sort,
                                onSortChanged: (v) => _sort.value = v,
                                onTapProduct: (p) =>
                                    context.go('/products/${p.id}'),
                              ),
                            const SizedBox(height: AppSpacing.xl3),
                            const Footer(),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page header (đơn giản, không dùng AdminPageHeader vì style customer)
// ---------------------------------------------------------------------------

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? AppSpacing.lg : AppSpacing.xl3,
        AppSpacing.xl,
        isMobile ? AppSpacing.lg : AppSpacing.xl3,
        AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.adminBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 18,
                  color: AppColors.primary600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tất cả sản phẩm',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Khám phá bộ sưu tập figure chính hãng – đa dạng phiên bản và màu sắc.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop body – sidebar trái + grid phải
// ---------------------------------------------------------------------------

class _DesktopBody extends StatelessWidget {
  final bool isTablet;
  final TextEditingController searchController;
  final List<CategoryModel> parentCategories;
  final List<CategoryModel> childCategories;
  final String? selectedParentId;
  final String? selectedChildId;
  final ValueChanged<String?> onParentSelected;
  final ValueChanged<String?> onChildSelected;
  final RangeValues priceRange;
  final double minPrice;
  final double maxPrice;
  final ValueChanged<RangeValues> onPriceChanged;
  final VoidCallback onReset;
  final List<ProductModel> products;
  final List<CategoryModel> allCategories;
  final ProductSort sort;
  final ValueChanged<ProductSort> onSortChanged;
  final ValueChanged<ProductModel> onTapProduct;

  const _DesktopBody({
    required this.isTablet,
    required this.searchController,
    required this.parentCategories,
    required this.childCategories,
    required this.selectedParentId,
    required this.selectedChildId,
    required this.onParentSelected,
    required this.onChildSelected,
    required this.priceRange,
    required this.minPrice,
    required this.maxPrice,
    required this.onPriceChanged,
    required this.onReset,
    required this.products,
    required this.allCategories,
    required this.sort,
    required this.onSortChanged,
    required this.onTapProduct,
  });

  @override
  Widget build(BuildContext context) {
    final padding = isTablet ? AppSpacing.lg : AppSpacing.xl3;

    return Padding(
      padding: EdgeInsets.fromLTRB(padding, AppSpacing.lg, padding, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilterSidebar(
            searchController: searchController,
            parentCategories: parentCategories,
            childCategories: childCategories,
            selectedParentId: selectedParentId,
            selectedChildId: selectedChildId,
            onParentSelected: onParentSelected,
            onChildSelected: onChildSelected,
            priceRange: priceRange,
            minPrice: minPrice,
            maxPrice: maxPrice,
            onPriceChanged: onPriceChanged,
            onReset: onReset,
            totalResults: products.length,
          ),
          AppSpacing.gapLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SortBar(
                  totalResults: products.length,
                  sortOption: sort,
                  onSortChanged: onSortChanged,
                ),
                AppSpacing.gapMd,
                ProductGrid(
                  products: products,
                  allCategories: allCategories,
                  onTap: onTapProduct,
                  hasSidebar: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile body – chỉ sort bar (filter mở từ button), grid bên dưới
// ---------------------------------------------------------------------------

class _MobileBody extends StatelessWidget {
  final List<ProductModel> products;
  final List<CategoryModel> allCategories;
  final int totalResults;
  final ProductSort sort;
  final ValueChanged<ProductSort> onSortChanged;
  final VoidCallback onOpenFilter;
  final ValueChanged<ProductModel> onTapProduct;

  const _MobileBody({
    required this.products,
    required this.allCategories,
    required this.totalResults,
    required this.sort,
    required this.onSortChanged,
    required this.onOpenFilter,
    required this.onTapProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SortBar(
            totalResults: totalResults,
            sortOption: sort,
            onSortChanged: onSortChanged,
            onOpenFilter: onOpenFilter,
            showFilterButton: true,
          ),
          AppSpacing.gapMd,
          ProductGrid(
            products: products,
            allCategories: allCategories,
            onTap: onTapProduct,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// State widgets
// ---------------------------------------------------------------------------

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 400,
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: AppColors.primary500,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(AppRadius.xl2),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 26,
                color: AppColors.errorDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Không thể tải sản phẩm',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
