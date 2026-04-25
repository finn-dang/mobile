import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'products_data_source.dart';
import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/product_model.dart';
import '../../../models/category_model.dart';

class ProductsDataTable extends StatelessWidget {
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final Function(int, bool) onSort;
  final int sortColumnIndex;
  final bool sortAscending;
  final int rowsPerPage;
  final ValueChanged<int?>? onRowsPerPageChanged;
  final bool isTablet;
  final String Function(int) formatPrice;
  final Function(ProductModel) onView;
  final Function(ProductModel) onEdit;
  final Function(ProductModel) onDelete;

  const ProductsDataTable({
    super.key,
    required this.products,
    required this.categories,
    required this.onSort,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.rowsPerPage,
    this.onRowsPerPageChanged,
    required this.isTablet,
    required this.formatPrice,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  /// Helper: tạo header text style chuẩn cho mọi cột.
  static const TextStyle _headerStyle = TextStyle(
    color: AppColors.neutral600,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    letterSpacing: 0.3,
  );

  DataColumn2 _column(
    String label, {
    ColumnSize size = ColumnSize.M,
    bool numeric = false,
    int? sortIndex,
  }) {
    return DataColumn2(
      label: Text(label.toUpperCase(), style: _headerStyle),
      size: size,
      numeric: numeric,
      onSort: sortIndex == null
          ? null
          : (_, ascending) => onSort(sortIndex, ascending),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable2(
      minWidth: isTablet ? 800 : 1200,
      columnSpacing: isTablet ? 8 : 16,
      horizontalMargin: isTablet ? 8 : 16,
      rowsPerPage: rowsPerPage,
      onRowsPerPageChanged: onRowsPerPageChanged,
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
      headingRowColor:
          WidgetStateProperty.all(AppColors.neutral50),
      headingRowHeight: 44,
      dataRowHeight: 64,
      dividerThickness: 0.6,
      border: TableBorder(
        horizontalInside: BorderSide(
          color: AppColors.neutral100,
          width: 1,
        ),
      ),
      columns: [
        _column('Hình ảnh', size: ColumnSize.S),
        _column('Tên sản phẩm', size: ColumnSize.L, sortIndex: 0),
        _column('Danh mục', size: ColumnSize.M, sortIndex: 1),
        _column('Giá', size: ColumnSize.M, numeric: true, sortIndex: 2),
        _column('Giá gốc', size: ColumnSize.M, numeric: true, sortIndex: 3),
        _column('Số lượng', size: ColumnSize.S, numeric: true, sortIndex: 4),
        _column('Trạng thái', size: ColumnSize.S, sortIndex: 5),
        _column('Hành động', size: ColumnSize.S),
      ],
      source: ProductsDataSource(
        products: products,
        categories: categories,
        context: context,
        onView: onView,
        onEdit: onEdit,
        onDelete: onDelete,
        formatPrice: formatPrice,
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
                Icons.inventory_2_outlined,
                size: 26,
                color: AppColors.neutral400,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Không có sản phẩm nào',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Thử điều chỉnh bộ lọc hoặc thêm sản phẩm mới.',
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
