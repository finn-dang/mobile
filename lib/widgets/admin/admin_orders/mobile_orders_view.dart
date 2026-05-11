import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/order_model.dart';
import '../../../models/order_status.dart';
import '../common/admin_card.dart';
import '../common/admin_page_header.dart';
import 'order_status_widgets.dart';
import 'orders_search_and_filter_bar.dart';

/// Danh sách đơn hàng dạng card cho mobile – Modern Minimal.
class MobileOrdersView extends StatelessWidget {
  final List<OrderModel> orders;
  final TextEditingController searchController;
  final OrderStatus? selectedStatus;
  final String? selectedDateRange;
  final ValueChanged<OrderStatus?> onStatusChanged;
  final ValueChanged<String?> onDateRangeChanged;
  final VoidCallback onClearFilters;
  final String Function(int) formatPrice;
  final String Function(DateTime) formatDate;
  final void Function(OrderModel) onView;
  final void Function(OrderModel) onEdit;

  const MobileOrdersView({
    super.key,
    required this.orders,
    required this.searchController,
    required this.selectedStatus,
    required this.selectedDateRange,
    required this.onStatusChanged,
    required this.onDateRangeChanged,
    required this.onClearFilters,
    required this.formatPrice,
    required this.formatDate,
    required this.onView,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.adminBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdminPageHeader(
              icon: Icons.receipt_long_outlined,
              title: 'Đơn hàng',
              subtitle: 'Xem và cập nhật trạng thái đơn hàng.',
              dense: true,
            ),
            OrdersSearchAndFilterBar(
              searchController: searchController,
              selectedStatus: selectedStatus,
              selectedDateRange: selectedDateRange,
              onStatusChanged: onStatusChanged,
              onDateRangeChanged: onDateRangeChanged,
              onClearFilters: onClearFilters,
              isTablet: false,
              isMobile: true,
            ),
            AppSpacing.gapLg,
            if (orders.isEmpty)
              const _EmptyState()
            else
              for (final o in orders)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _OrderCard(
                    order: o,
                    formatPrice: formatPrice,
                    formatDate: formatDate,
                    onView: () => onView(o),
                    onEdit: () => onEdit(o),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final String Function(int) formatPrice;
  final String Function(DateTime) formatDate;
  final VoidCallback onView;
  final VoidCallback onEdit;

  const _OrderCard({
    required this.order,
    required this.formatPrice,
    required this.formatDate,
    required this.onView,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  order.orderCode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              AppSpacing.gapSm,
              OrderStatusPill(status: order.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            order.fullName,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            order.phone,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
          const Divider(
            height: AppSpacing.md * 2,
            color: AppColors.neutral100,
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'TỔNG TIỀN',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatPrice(order.total)} ₫',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.primary600,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapSm,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PaymentMethodPill(method: order.paymentMethod),
                  const SizedBox(height: 6),
                  PaymentStatusPill(status: order.paymentStatus),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.items.length} sản phẩm  •  ${formatDate(order.createdAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AdminSecondaryButton(
                  icon: Icons.visibility_outlined,
                  label: 'Xem',
                  onPressed: onView,
                ),
              ),
              AppSpacing.gapSm,
              Expanded(
                child: AdminPrimaryButton(
                  icon: Icons.edit_outlined,
                  label: 'Sửa',
                  onPressed: onEdit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.adminBorder),
      ),
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
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
