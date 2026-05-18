import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../config/colors.dart';
import '../../config/spacing.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';
import '../../widgets/admin/admin_products/mobile_products_view.dart';
import '../../widgets/admin/admin_products/products_data_table.dart';
import '../../widgets/admin/admin_products/products_search_and_filter_bar.dart';
import '../../widgets/admin/admin_products/products_stats.dart';
import '../../widgets/admin/admin_products/view_product_dialog.dart';
import '../../widgets/admin/common/admin_card.dart';
import '../../widgets/admin/common/admin_page_header.dart';

/// Admin Products – Modern Minimal.
class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  final _productService = ProductService();
  final _categoryService = CategoryService();

  int _rowsPerPage = 10;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  String? _selectedCategoryId;
  String? _selectedStatus;

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    // 400ms thay vì 2000ms cũ – feel nhanh hơn nhiều mà vẫn tránh spam.
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() {});
    });
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _formatPrice(int price) => price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );

  String? _getCategoryName(String categoryId, List<CategoryModel> categories) {
    try {
      return categories.firstWhere((c) => c.id == categoryId).name;
    } catch (_) {
      return null;
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategoryId = null;
      _selectedStatus = null;
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  List<ProductModel> _applyFiltersAndSort(
    List<ProductModel> products,
    List<CategoryModel> categories,
  ) {
    final query = _searchController.text.toLowerCase();
    final filtered = products.where((p) {
      final categoryName = _getCategoryName(p.categoryId, categories);
      final matchesSearch = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          (categoryName?.toLowerCase().contains(query) ?? false) ||
          (p.description?.toLowerCase().contains(query) ?? false);
      final matchesCategory =
          _selectedCategoryId == null || p.categoryId == _selectedCategoryId;
      final matchesStatus =
          _selectedStatus == null || p.calculatedStatus == _selectedStatus;
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();

    return _sortInternal(filtered, categories);
  }

  List<ProductModel> _sortInternal(
    List<ProductModel> products,
    List<CategoryModel> categories,
  ) {
    final out = List<ProductModel>.from(products);
    out.sort((a, b) {
      int cmp;
      switch (_sortColumnIndex) {
        case 0:
          cmp = a.name.compareTo(b.name);
          break;
        case 1:
          final ac = _getCategoryName(a.categoryId, categories) ?? '';
          final bc = _getCategoryName(b.categoryId, categories) ?? '';
          cmp = ac.compareTo(bc);
          break;
        case 2:
          cmp = a.price.compareTo(b.price);
          break;
        case 3:
          cmp = a.originalPrice.compareTo(b.originalPrice);
          break;
        case 4:
          cmp = a.quantity.compareTo(b.quantity);
          break;
        case 5:
          cmp = a.calculatedStatus.compareTo(b.calculatedStatus);
          break;
        default:
          cmp = 0;
      }
      return _sortAscending ? cmp : -cmp;
    });
    return out;
  }

  Future<void> _handleDelete(ProductModel product) async {
    try {
      await _productService.deleteProduct(product.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa: ${product.name}'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xóa: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Container(
      color: AppColors.adminBackground,
      child: StreamBuilder<List<CategoryModel>>(
        stream: _categoryService.getCategories(),
        builder: (context, categorySnapshot) {
          final categories = categorySnapshot.data ?? const [];
          final parentCategories =
              categories.where((c) => c.parentId == null).toList();

          return StreamBuilder<List<ProductModel>>(
            stream: _productService.getProducts(),
            builder: (context, productSnapshot) {
              if (productSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const _LoadingState();
              }
              if (productSnapshot.hasError) {
                return _ErrorState(
                  message: productSnapshot.error.toString(),
                  onRetry: () => setState(() {}),
                );
              }

              final products = productSnapshot.data ?? const [];
              final processed = _applyFiltersAndSort(products, categories);

              if (isMobile) {
                return MobileProductsView(
                  products: processed,
                  categories: categories,
                  searchController: _searchController,
                  selectedCategoryId: _selectedCategoryId,
                  selectedStatus: _selectedStatus,
                  onCategoryChanged: (v) =>
                      setState(() => _selectedCategoryId = v),
                  onStatusChanged: (v) =>
                      setState(() => _selectedStatus = v),
                  onClearFilters: _clearFilters,
                  onSort: _onSort,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  formatPrice: _formatPrice,
                  onDelete: _handleDelete,
                );
              }

              return _DesktopBody(
                isTablet: isTablet,
                processed: processed,
                categories: categories,
                parentCategories: parentCategories,
                searchController: _searchController,
                selectedCategoryId: _selectedCategoryId,
                selectedStatus: _selectedStatus,
                rowsPerPage: _rowsPerPage,
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                formatPrice: _formatPrice,
                onCategoryChanged: (v) =>
                    setState(() => _selectedCategoryId = v),
                onStatusChanged: (v) => setState(() => _selectedStatus = v),
                onClearFilters: _clearFilters,
                onSort: _onSort,
                onRowsPerPageChanged: (v) =>
                    setState(() => _rowsPerPage = v ?? 10),
                onView: (p) => showDialog(
                  context: context,
                  builder: (_) => ViewProductDialog(
                    product: p,
                    categories: categories,
                    formatPrice: _formatPrice,
                    isMobile: false,
                    onEdit: () {
                      Navigator.of(context).pop();
                      context.go('/admin/products/${p.id}/edit');
                    },
                  ),
                ),
                onEdit: (p) => context.go('/admin/products/${p.id}/edit'),
                onDelete: _handleDelete,
                onCreate: () => context.go('/admin/products/new'),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop body
// ---------------------------------------------------------------------------

class _DesktopBody extends StatelessWidget {
  final bool isTablet;
  final List<ProductModel> processed;
  final List<CategoryModel> categories;
  final List<CategoryModel> parentCategories;

  final TextEditingController searchController;
  final String? selectedCategoryId;
  final String? selectedStatus;
  final int rowsPerPage;
  final int sortColumnIndex;
  final bool sortAscending;
  final String Function(int) formatPrice;

  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClearFilters;
  final void Function(int, bool) onSort;
  final ValueChanged<int?> onRowsPerPageChanged;
  final void Function(ProductModel) onView;
  final void Function(ProductModel) onEdit;
  final void Function(ProductModel) onDelete;
  final VoidCallback onCreate;

  const _DesktopBody({
    required this.isTablet,
    required this.processed,
    required this.categories,
    required this.parentCategories,
    required this.searchController,
    required this.selectedCategoryId,
    required this.selectedStatus,
    required this.rowsPerPage,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.formatPrice,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onClearFilters,
    required this.onSort,
    required this.onRowsPerPageChanged,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final padding = isTablet ? AppSpacing.pageMd : AppSpacing.pageLg;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminPageHeader(
            icon: Icons.inventory_2_outlined,
            title: 'Sản phẩm',
            subtitle:
                'Quản lý danh sách sản phẩm, giá bán, kho và trạng thái hiển thị.',
            action: AdminPrimaryButton(
              icon: Icons.add_rounded,
              label: isTablet ? 'Thêm' : 'Thêm sản phẩm',
              onPressed: onCreate,
            ),
          ),
          ProductsStats(
            products: processed,
            isTablet: isTablet,
            formatPrice: formatPrice,
          ),
          const SizedBox(height: AppSpacing.lg),
          ProductsSearchAndFilterBar(
            searchController: searchController,
            categories: parentCategories,
            selectedCategoryId: selectedCategoryId,
            selectedStatus: selectedStatus,
            onCategoryChanged: onCategoryChanged,
            onStatusChanged: onStatusChanged,
            onClearFilters: onClearFilters,
            isTablet: isTablet,
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: AdminCard(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
                0,
              ),
              child: ProductsDataTable(
                products: processed,
                categories: categories,
                onSort: onSort,
                sortColumnIndex: sortColumnIndex,
                sortAscending: sortAscending,
                rowsPerPage: rowsPerPage,
                onRowsPerPageChanged: onRowsPerPageChanged,
                isTablet: isTablet,
                formatPrice: formatPrice,
                onView: onView,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ),
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
    return const Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: AppColors.primary500,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl3),
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
              'Không thể tải dữ liệu',
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
            const SizedBox(height: AppSpacing.lg),
            AdminSecondaryButton(
              icon: Icons.refresh_rounded,
              label: 'Thử lại',
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
