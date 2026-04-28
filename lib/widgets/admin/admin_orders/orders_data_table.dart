import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/order_model.dart';
import '../../../models/order_status.dart';
import 'orders_data_source.dart';

class OrdersDataTable extends StatelessWidget {
  final List<OrderModel> orders;
  final Function(int, bool) onSort;
  final int sortColumnIndex;
  final bool sortAscending;
  final int rowsPerPage;
  final ValueChanged<int?>? onRowsPerPageChanged;
  final bool isTablet;
  final String Function(int) formatPrice;
  final String Function(DateTime) formatDate;
  final Function(String orderId, OrderStatus newStatus)? onStatusUpdated;
  final Function(OrderModel) onView;
  final Function(OrderModel) onEdit;

  const OrdersDataTable({
    super.key,
    required this.orders,
    required this.onSort,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.rowsPerPage,
    this.onRowsPerPageChanged,
    required this.isTablet,
    required this.formatPrice,
    required this.formatDate,
    this.onStatusUpdated,
    required this.onView,
    required this.onEdit,
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
      minWidth: isTablet ? 980 : 1320,
      columnSpacing: isTablet ? 8 : 16,
      horizontalMargin: isTablet ? 8 : 16,
      rowsPerPage: rowsPerPage,
      onRowsPerPageChanged: onRowsPerPageChanged,
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
      headingRowColor: WidgetStateProperty.all(AppColors.neutral50),
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
        _column('Mã đơn', size: ColumnSize.M, sortIndex: 0),
        _column('Khách hàng', size: ColumnSize.L, sortIndex: 1),
        _column('SL món', size: ColumnSize.S, sortIndex: 2),
        _column('Tổng tiền', size: ColumnSize.M, numeric: true, sortIndex: 3),
        _column('Phương thức', size: ColumnSize.S, sortIndex: 4),
        _column('TT thanh toán', size: ColumnSize.M, sortIndex: 5),
        _column('Trạng thái', size: ColumnSize.M, sortIndex: 6),
        _column('Ngày đặt', size: ColumnSize.M, sortIndex: 7),
        _column('Hành động', size: ColumnSize.S),
      ],
      source: OrdersDataSource(
        orders: orders,
        context: context,
        onView: onView,
        onEdit: onEdit,
        onStatusUpdated: onStatusUpdated,
        formatPrice: formatPrice,
        formatDate: formatDate,
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
                Icons.receipt_long_outlined,
                size: 26,
                color: AppColors.neutral400,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Không có đơn hàng nào',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Thử điều chỉnh bộ lọc hoặc kiểm tra lại sau.',
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
