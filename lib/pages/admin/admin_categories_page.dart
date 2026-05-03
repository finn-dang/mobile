import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../config/colors.dart';
import '../../config/spacing.dart';
import '../../models/category_model.dart';
import '../../services/category_service.dart';
import '../../services/image_service.dart';
import '../../widgets/admin/admin_categories/categories_data_table.dart';
import '../../widgets/admin/admin_categories/categories_search_and_filter_bar.dart';
import '../../widgets/admin/admin_categories/categories_stats.dart';
import '../../widgets/admin/admin_categories/create_category_dialog.dart';
import '../../widgets/admin/admin_categories/delete_category_dialog.dart';
import '../../widgets/admin/admin_categories/edit_category_dialog.dart';
import '../../widgets/admin/admin_categories/expandable_category_row.dart';
import '../../widgets/admin/admin_categories/mobile_categories_view.dart';
import '../../widgets/admin/common/admin_card.dart';
import '../../widgets/admin/common/admin_page_header.dart';

/// Admin Categories – Modern Minimal.
class AdminCategoriesPage extends StatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  State<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  final _categoryService = CategoryService();
  final _imageService = ImageService();

  int _rowsPerPage = 10;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  String? _selectedStatus;

  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedIds = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  // ---------------------------------------------------------------------------
  // Data helpers
  // ---------------------------------------------------------------------------

  List<CategoryModel> _filterAll(List<CategoryModel> categories) {
    final query = _searchController.text.toLowerCase();
    return categories.where((c) {
      final matchesSearch = query.isEmpty ||
          c.name.toLowerCase().contains(query) ||
          (c.description?.toLowerCase().contains(query) ?? false);
      final matchesStatus =
          _selectedStatus == null || c.status == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  List<ExpandableCategoryRow> _organizeRows(List<CategoryModel> categories) {
    // Lấy parents (không có parentId)
    final parents = categories.where((c) => c.parentId == null).toList();

    parents.sort((a, b) {
      int cmp;
      switch (_sortColumnIndex) {
        case 0:
          cmp = a.name.compareTo(b.name);
          break;
        case 1:
          cmp = a.status.compareTo(b.status);
          break;
        case 2:
          cmp = a.createdAt.compareTo(b.createdAt);
          break;
        default:
          cmp = a.name.compareTo(b.name);
      }
      return _sortAscending ? cmp : -cmp;
    });

    // Khi có search query, auto-expand tất cả parents có children matching
    final query = _searchController.text.toLowerCase();
    final autoExpand = query.isNotEmpty;

    return parents.map((parent) {
      final children = categories
          .where((c) => c.parentId == parent.id)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      final isExpanded =
          _expandedIds.contains(parent.id) || (autoExpand && children.isNotEmpty);

      return ExpandableCategoryRow(
        category: parent,
        children: children,
        isExpanded: isExpanded,
      );
    }).toList();
  }

  void _toggleExpand(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  void _expandAll(List<ExpandableCategoryRow> rows) {
    setState(() {
      for (final r in rows) {
        if (r.children.isNotEmpty) _expandedIds.add(r.category.id);
      }
    });
  }

  void _collapseAll() => setState(() => _expandedIds.clear());

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  void _showCreateDialog(List<CategoryModel> all) {
    showDialog(
      context: context,
      builder: (_) => CreateCategoryDialog(
        allCategories: all,
        onCreate: (newCategory) async {
          try {
            await _categoryService.createCategory(newCategory);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã tạo danh mục thành công!'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditDialog(CategoryModel category, List<CategoryModel> all) {
    showDialog(
      context: context,
      builder: (_) => EditCategoryDialog(
        category: category,
        allCategories: all,
        onSave: (updated) async {
          try {
            await _categoryService.updateCategory(category.id, updated);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã cập nhật danh mục!'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteDialog(CategoryModel category) {
    showDialog(
      context: context,
      builder: (_) => DeleteCategoryDialog(
        category: category,
        onConfirm: () async {
          try {
            final hasChildren = await _categoryService.hasChildren(category.id);
            if (hasChildren) {
              if (!mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Không thể xoá danh mục đang chứa danh mục con!',
                  ),
                  backgroundColor: AppColors.warning,
                  duration: Duration(seconds: 3),
                ),
              );
              return;
            }
            if (category.imageUrl != null) {
              await _imageService.deleteCategoryImage(category.imageUrl!);
            }
            await _categoryService.deleteCategory(category.id);
            if (!mounted) return;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã xoá: ${category.name}'),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );
          } catch (e) {
            if (!mounted) return;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
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
      color: AppColors.adminBackground,
      child: StreamBuilder<List<CategoryModel>>(
        stream: _categoryService.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingState();
          }
          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error.toString(),
              onRetry: () => setState(() {}),
            );
          }

          final categories = snapshot.data ?? const [];
          final filtered = _filterAll(categories);
          final rows = _organizeRows(filtered);

          if (isMobile) {
            return MobileCategoriesView(
              expandableRows: rows,
              searchController: _searchController,
              selectedStatus: _selectedStatus,
              onStatusChanged: (v) =>
                  setState(() => _selectedStatus = v),
              onClearFilters: _clearFilters,
              onEdit: (c) => _showEditDialog(c, categories),
              onDelete: _showDeleteDialog,
              onSort: _onSort,
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              onCreate: () => _showCreateDialog(categories),
              onToggleExpand: _toggleExpand,
            );
          }

          return _DesktopBody(
            isTablet: isTablet,
            categoriesAll: categories,
            filtered: filtered,
            rows: rows,
            searchController: _searchController,
            selectedStatus: _selectedStatus,
            rowsPerPage: _rowsPerPage,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            onStatusChanged: (v) => setState(() => _selectedStatus = v),
            onClearFilters: _clearFilters,
            onSort: _onSort,
            onRowsPerPageChanged: (v) =>
                setState(() => _rowsPerPage = v ?? 10),
            onToggleExpand: _toggleExpand,
            onCreate: () => _showCreateDialog(categories),
            onEdit: (c) => _showEditDialog(c, categories),
            onDelete: _showDeleteDialog,
            onExpandAll: () => _expandAll(rows),
            onCollapseAll: _collapseAll,
            anyExpanded: _expandedIds.isNotEmpty,
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
  final List<CategoryModel> categoriesAll;
  final List<CategoryModel> filtered;
  final List<ExpandableCategoryRow> rows;
  final TextEditingController searchController;
  final String? selectedStatus;
  final int rowsPerPage;
  final int sortColumnIndex;
  final bool sortAscending;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClearFilters;
  final void Function(int, bool) onSort;
  final ValueChanged<int?> onRowsPerPageChanged;
  final ValueChanged<String> onToggleExpand;
  final VoidCallback onCreate;
  final Function(CategoryModel) onEdit;
  final Function(CategoryModel) onDelete;
  final VoidCallback onExpandAll;
  final VoidCallback onCollapseAll;
  final bool anyExpanded;

  const _DesktopBody({
    required this.isTablet,
    required this.categoriesAll,
    required this.filtered,
    required this.rows,
    required this.searchController,
    required this.selectedStatus,
    required this.rowsPerPage,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onStatusChanged,
    required this.onClearFilters,
    required this.onSort,
    required this.onRowsPerPageChanged,
    required this.onToggleExpand,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
    required this.onExpandAll,
    required this.onCollapseAll,
    required this.anyExpanded,
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
            icon: Icons.account_tree_outlined,
            title: 'Danh mục',
            subtitle:
                'Tổ chức danh mục theo cấu trúc cây – cha và con. Click vào hàng để mở rộng.',
            action: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AdminSecondaryButton(
                  icon: anyExpanded
                      ? Icons.unfold_less_rounded
                      : Icons.unfold_more_rounded,
                  label: anyExpanded ? 'Thu gọn' : 'Mở rộng',
                  onPressed: anyExpanded ? onCollapseAll : onExpandAll,
                ),
                AppSpacing.gapSm,
                AdminPrimaryButton(
                  icon: Icons.add_rounded,
                  label: isTablet ? 'Thêm' : 'Thêm danh mục',
                  onPressed: onCreate,
                ),
              ],
            ),
          ),
          CategoriesStats(
            categories: filtered,
            isTablet: isTablet,
          ),
          const SizedBox(height: AppSpacing.lg),
          CategoriesSearchAndFilterBar(
            searchController: searchController,
            selectedStatus: selectedStatus,
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
              child: CategoriesDataTable(
                expandableRows: rows,
                onSort: onSort,
                sortColumnIndex: sortColumnIndex,
                sortAscending: sortAscending,
                rowsPerPage: rowsPerPage,
                onRowsPerPageChanged: onRowsPerPageChanged,
                onEdit: onEdit,
                onDelete: onDelete,
                onToggleExpand: onToggleExpand,
                isTablet: isTablet,
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
              'Không thể tải danh mục',
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
