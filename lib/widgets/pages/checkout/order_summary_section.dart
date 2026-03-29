// Modern Minimal – Tóm tắt đơn hàng (items + subtotal + shipping + total).
//
// Wrap trong card border 1px, total to bằng cam. Dùng order_items_list bên
// trong cho list sản phẩm.

import 'package:flutter/material.dart';

import '../../../../config/colors.dart';
import '../../../../config/spacing.dart';
import '../../../../models/cart_model.dart';
import 'order_items_list.dart';

class OrderSummarySection extends StatelessWidget {
  final List<CartItemModel> cartItems;
  final int shippingFee;

  const OrderSummarySection({
    super.key,
    required this.cartItems,
    this.shippingFee = 30000,
  });

  int get subtotal =>
      cartItems.fold<int>(0, (sum, i) => sum + i.totalPrice);

  int get total => subtotal + shippingFee;

  String _formatPrice(int p) => p.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderItemsList(cartItems: cartItems),
          AppSpacing.gapLg,
          const Divider(height: 1, color: AppColors.adminBorder),
          AppSpacing.gapMd,
          _SummaryRow(
            label: 'Tiền hàng',
            value: '${_formatPrice(subtotal)} ₫',
          ),
          AppSpacing.gapSm,
          _SummaryRow(
            label: 'Phí vận chuyển',
            value: shippingFee == 0
                ? 'Miễn phí'
                : '${_formatPrice(shippingFee)} ₫',
            valueColor:
                shippingFee == 0 ? AppColors.successDark : AppColors.textPrimary,
          ),
          AppSpacing.gapMd,
          const Divider(height: 1, color: AppColors.adminBorder),
          AppSpacing.gapMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.1,
                ),
              ),
              Text(
                '${_formatPrice(total)} ₫',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary600,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
