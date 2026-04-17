import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/category_model.dart';
import 'expandable_categories_data_source.dart';
import 'expandable_category_row.dart';

class CategoriesDataTable extends StatelessWidget {
  final List<ExpandableCategoryRow> expandableRows;
  final Function(int, bool) onSort;
  final int sortColumnIndex;
  final bool sortAscending;
  final int rowsPerPage;
  final ValueChanged<int?>? onRowsPerPageChanged;
  final Function(CategoryModel) onEdit;
  final Function(CategoryModel) onDelete;
  final Function(String) onToggleExpand;
  final bool isTablet;

  const CategoriesDataTable({
    super.key,
    required this.expandableRows,
    required this.onSort,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.rowsPerPage,
    this.onRowsPerPageChanged,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleExpand,
    required this.isTablet,
  });

  static const TextStyle _headerStyle = TextStyle(
    color: AppColors.neutral600,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    letterSpacing: 0.3,
  );

  DataColumn2 _column(
    String label, {
    ColumnSize size = ColumnSize.M,
    int? sortIndex,
  }) {
    return DataColumn2(
      label: Text(label.toUpperCase(), style: _headerStyle),
      size: size,
      onSort: sortIndex == null
          ? null
          : (_, ascending) => onSort(sortIndex, ascending),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable2(
      minWidth: isTablet ? 800 : 1100,
      columnSpacing: isTablet ? 8 : 16,
      horizontalMargin: isTablet ? 8 : 16,
      rowsPerPage: rowsPerPage,
      onRowsPerPageChanged: onRowsPerPageChanged,
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
      headingRowColor: WidgetStateProperty.all(AppColors.neutral50),
      headingRowHeight: 44,
      dataRowHeight: 60,
      dividerThickness: 0.6,
      border: TableBorder(
        horizontalInside: BorderSide(
          color: AppColors.neutral100,
          width: 1,
        ),
      ),
      columns: [
        _column('Hình ảnh', size: ColumnSize.S),
        _column('Tên danh mục', size: ColumnSize.L, sortIndex: 0),
        _column('Danh mục cha', size: ColumnSize.M),
        _column('Trạng thái', size: ColumnSize.M, sortIndex: 1),
        _column('Ngày tạo', size: ColumnSize.M, sortIndex: 2),
        _column('Hành động', size: ColumnSize.S),
      ],
      source: ExpandableCategoriesDataSource(
        expandableRows: expandableRows,
        context: context,
        onEdit: onEdit,
        onDelete: onDelete,
        onToggleExpand: onToggleExpand,
      ),
      empty: const _EmptyState(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(AppRadius.xl2),
              ),
              child: const Icon(
                Icons.category_outlined,
                size: 26,
                color: AppColors.neutral400,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Không có danh mục nào',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Thử điều chỉnh bộ lọc hoặc thêm danh mục mới.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
