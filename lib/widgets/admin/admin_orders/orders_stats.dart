import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/order_model.dart';
import '../../../models/order_status.dart';
import '../common/admin_card.dart';

/// Stats grid cho Orders – Modern Minimal.
class OrdersStats extends StatelessWidget {
  final List<OrderModel> orders;
  final bool isTablet;
  final String Function(int) formatPrice;

  const OrdersStats({
    super.key,
    required this.orders,
    required this.isTablet,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final total = orders.length;
    final pending = orders.where((o) =>
        o.status == OrderStatus.pending ||
        o.status == OrderStatus.processing ||
        o.status == OrderStatus.confirmed).length;
    final completed =
        orders.where((o) => o.status == OrderStatus.completed).length;
    final revenue = orders
        .where((o) => o.status == OrderStatus.completed)
        .fold<int>(0, (sum, o) => sum + o.total);

    final completionPct =
        total == 0 ? 0 : ((completed / total) * 100).round();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isTablet ? 2 : 4,
      crossAxisSpacing: AppSpacing.lg,
      mainAxisSpacing: AppSpacing.lg,
      childAspectRatio: isTablet ? 2.4 : 2.0,
      children: [
        AdminStatCard(
          title: 'Tổng đơn hàng',
          value: total.toString(),
          icon: Icons.receipt_long_outlined,
          accent: AppColors.info,
        ),
        AdminStatCard(
          title: 'Đang xử lý',
          value: pending.toString(),
          icon: Icons.pending_actions_outlined,
          accent: AppColors.warning,
        ),
        AdminStatCard(
          title: 'Đã hoàn thành',
          value: completed.toString(),
          icon: Icons.check_circle_outline_rounded,
          accent: AppColors.success,
          hint: '$completionPct%',
          hintFg: AppColors.successDark,
          hintBg: AppColors.successContainer,
        ),
        AdminStatCard(
          title: 'Doanh thu',
          value: _formatRevenue(revenue),
          icon: Icons.payments_outlined,
          accent: AppColors.primary500,
          hint: '$completed đơn',
          hintFg: AppColors.primary700,
          hintBg: AppColors.primary50,
        ),
      ],
    );
  }

  String _formatRevenue(int v) {
    if (v >= 1000000000) return '${(v / 1000000000).toStringAsFixed(1)} tỷ';
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)} triệu';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return formatPrice(v);
  }
}
