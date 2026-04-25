import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/order_payment_status.dart';
import '../../../models/order_status.dart';
import '../../../models/payment_method.dart';

/// Pill hiển thị trạng thái đơn hàng (read-only) – Modern Minimal.
///
/// Có chấm tròn cùng tone + border 1px nhẹ.
class OrderStatusPill extends StatelessWidget {
  final OrderStatus status;
  final bool locked;
  final EdgeInsetsGeometry? padding;
  const OrderStatusPill({
    super.key,
    required this.status,
    this.locked = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: status.color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              status.adminDisplayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: status.color,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.05,
              ),
            ),
          ),
          if (locked) ...[
            const SizedBox(width: 6),
            Icon(Icons.lock_outline_rounded,
                size: 11, color: status.color.withValues(alpha: 0.7)),
          ],
        ],
      ),
    );
  }
}

/// Dropdown đổi trạng thái đơn hàng – Modern Minimal.
///
/// Giữ tone color của status hiện tại + border + chevron nhỏ.
class OrderStatusDropdown extends StatelessWidget {
  final OrderStatus value;
  final ValueChanged<OrderStatus?> onChanged;
  final bool isUpdating;

  const OrderStatusDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.isUpdating = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isUpdating) {
      return Container(
        width: 120,
        height: 28,
        alignment: Alignment.center,
        child: SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(value.color),
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: value.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: value.color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<OrderStatus>(
          value: value,
          isDense: true,
          isExpanded: true,
          icon: Icon(
            Icons.unfold_more_rounded,
            size: 14,
            color: value.color.withValues(alpha: 0.7),
          ),
          style: TextStyle(
            color: value.color,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          items: OrderStatus.values
              .map(
                (s) => DropdownMenuItem<OrderStatus>(
                  value: s,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: s.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          s.adminDisplayName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: s.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Pill cho phương thức thanh toán – Modern Minimal.
class PaymentMethodPill extends StatelessWidget {
  final PaymentMethod method;
  const PaymentMethodPill({super.key, required this.method});

  ({Color fg, Color bg, IconData icon, String label}) get _style {
    switch (method) {
      case PaymentMethod.cod:
        return (
          fg: AppColors.warningDark,
          bg: AppColors.warningContainer,
          icon: Icons.local_shipping_outlined,
          label: 'COD',
        );
      case PaymentMethod.momo:
        return (
          fg: const Color(0xFFA50064),
          bg: const Color(0xFFFCE7F3),
          icon: Icons.qr_code_2_rounded,
          label: 'MoMo',
        );
      case PaymentMethod.payos:
        return (
          fg: const Color(0xFF065F46),
          bg: AppColors.successContainer,
          icon: Icons.qr_code_scanner_rounded,
          label: 'PayOS',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: 12, color: s.fg),
          const SizedBox(width: 4),
          Text(
            s.label,
            style: TextStyle(
              color: s.fg,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.05,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill hiển thị trạng thái thanh toán – Modern Minimal.
class PaymentStatusPill extends StatelessWidget {
  final OrderPaymentStatus status;
  const PaymentStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: status.color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: TextStyle(
              color: status.color,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.05,
            ),
          ),
        ],
      ),
    );
  }
}
