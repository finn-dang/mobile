// Modern Minimal – Hiển thị phương thức thanh toán đã chọn (read-only).
//
// Card border 1px, icon container theo tone của method, tên + mô tả.

import 'package:flutter/material.dart';

import '../../../../config/colors.dart';
import '../../../../config/spacing.dart';
import '../../../../models/payment_method.dart';

class PaymentMethodDisplay extends StatelessWidget {
  final PaymentMethod paymentMethod;

  const PaymentMethodDisplay({super.key, required this.paymentMethod});

  ({IconData icon, Color iconBg, Color iconFg}) get _style {
    switch (paymentMethod) {
      case PaymentMethod.cod:
        return (
          icon: Icons.local_shipping_outlined,
          iconBg: AppColors.warningContainer,
          iconFg: AppColors.warningDark,
        );
      case PaymentMethod.momo:
        return (
          icon: Icons.qr_code_2_rounded,
          iconBg: const Color(0xFFFCE7F3),
          iconFg: const Color(0xFFA50064),
        );
      case PaymentMethod.payos:
        return (
          icon: Icons.qr_code_scanner_rounded,
          iconBg: AppColors.successContainer,
          iconFg: const Color(0xFF065F46),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.payments_outlined,
                size: 16,
                color: AppColors.textPrimary,
              ),
              SizedBox(width: 8),
              Text(
                'Phương thức thanh toán',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: s.iconBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(s.icon, size: 18, color: s.iconFg),
              ),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      paymentMethod.name,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      paymentMethod.description,
                      style: const TextStyle(
                        fontSize: 12.5,
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
