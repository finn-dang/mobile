import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/order_model.dart';
import '../../../models/order_status.dart';
import '../../../services/order_service.dart';
import 'order_status_widgets.dart';

class OrdersDataSource extends DataTableSource {
  final List<OrderModel> orders;
  final BuildContext context;
  final Function(OrderModel) onView;
  final Function(OrderModel) onEdit;
  final Function(String orderId, OrderStatus newStatus)? onStatusUpdated;
  final String Function(int) formatPrice;
  final String Function(DateTime) formatDate;

  final OrderService _orderService = OrderService();
  final Map<String, bool> _updatingStatus = {};

  OrdersDataSource({
    required this.orders,
    required this.context,
    required this.onView,
    required this.onEdit,
    this.onStatusUpdated,
    required this.formatPrice,
    required this.formatDate,
  });

  // ---------------------------------------------------------------------------
  // Status update
  // ---------------------------------------------------------------------------

  Future<void> updateOrderStatus(
    OrderModel order,
    OrderStatus newStatus,
  ) async {
    if (_updatingStatus[order.id] == true) return;

    onStatusUpdated?.call(order.id, newStatus);
    _setState(() => _updatingStatus[order.id] = true);

    try {
      await _orderService.updateOrderStatus(order.id, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật ${order.orderCode}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      onStatusUpdated?.call(order.id, order.status);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      _setState(() => _updatingStatus[order.id] = false);
    }
  }

  void _setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Row builder
  // ---------------------------------------------------------------------------

  @override
  DataRow? getRow(int index) {
    if (index >= orders.length) return null;
    final order = orders[index];
    final isCancelled = order.status == OrderStatus.cancelled;

    return DataRow2(
      cells: [
        // Order code
        DataCell(
          Text(
            order.orderCode,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              fontSize: 13,
              color: AppColors.textPrimary,
              letterSpacing: -0.1,
            ),
          ),
        ),
        // Customer
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                order.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                order.phone,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Items count
        DataCell(
          Text(
            '${order.items.length} món',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Total
        DataCell(
          Text(
            '${formatPrice(order.total)} ₫',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        // Payment method
        DataCell(PaymentMethodPill(method: order.paymentMethod)),
        // Payment status
        DataCell(PaymentStatusPill(status: order.paymentStatus)),
        // Status (dropdown if not cancelled, pill+lock if cancelled)
        DataCell(
          isCancelled
              ? OrderStatusPill(status: order.status, locked: true)
              : OrderStatusDropdown(
                  value: order.status,
                  isUpdating: _updatingStatus[order.id] == true,
                  onChanged: (s) {
                    if (s != null && s != order.status) {
                      updateOrderStatus(order, s);
                    }
                  },
                ),
        ),
        // Created at
        DataCell(
          Text(
            formatDate(order.createdAt),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        // Actions
        DataCell(
          _RowActions(
            onView: () => onView(order),
            onEdit: () => onEdit(order),
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => orders.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

// ---------------------------------------------------------------------------
// Row actions
// ---------------------------------------------------------------------------

class _RowActions extends StatelessWidget {
  final VoidCallback onView;
  final VoidCallback onEdit;
  const _RowActions({required this.onView, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconAction(
          icon: Icons.visibility_outlined,
          tooltip: 'Xem chi tiết',
          color: AppColors.info,
          onPressed: onView,
        ),
        AppSpacing.gapXs,
        _IconAction(
          icon: Icons.edit_outlined,
          tooltip: 'Cập nhật trạng thái + ghi chú',
          color: AppColors.primary600,
          onPressed: onEdit,
        ),
      ],
    );
  }
}

class _IconAction extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;

  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_IconAction> createState() => _IconActionState();
}

class _IconActionState extends State<_IconAction> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: SizedBox(
        width: 30,
        height: 30,
        child: Material(
          color: _hover
              ? widget.color.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: InkWell(
            onTap: widget.onPressed,
            onHover: (v) => setState(() => _hover = v),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Icon(widget.icon, size: 16, color: widget.color),
          ),
        ),
      ),
    );
  }
}
