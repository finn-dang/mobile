import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';

/// Card tổng kết giỏ hàng (sticky bên phải desktop / dưới mobile) – Modern Minimal.
class CartSummaryCard extends StatelessWidget {
  final int subtotal;
  final int shipping;
  final int itemCount;
  final bool hasOutOfStock;
  final bool isLoading;
  final VoidCallback onCheckout;

  const CartSummaryCard({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.itemCount,
    required this.hasOutOfStock,
    required this.isLoading,
    required this.onCheckout,
  });

  String _formatPrice(int p) => p.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );

  @override
  Widget build(BuildContext context) {
    final total = subtotal + shipping;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.adminBorder),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 16,
                color: AppColors.textPrimary,
              ),
              SizedBox(width: 8),
              Text(
                'Tóm tắt đơn hàng',
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
          _SummaryRow(label: 'Số sản phẩm', value: '$itemCount món'),
          AppSpacing.gapSm,
          _SummaryRow(
            label: 'Tạm tính',
            value: '${_formatPrice(subtotal)} ₫',
          ),
          AppSpacing.gapSm,
          _SummaryRow(
            label: 'Phí vận chuyển',
            value: shipping == 0
                ? 'Miễn phí'
                : '${_formatPrice(shipping)} ₫',
            valueColor:
                shipping == 0 ? AppColors.successDark : AppColors.textPrimary,
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
          if (hasOutOfStock) ...[
            AppSpacing.gapMd,
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.errorLight),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 14,
                    color: AppColors.errorDark,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Có sản phẩm hết hàng – vui lòng xoá để tiếp tục',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.errorDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          AppSpacing.gapMd,
          _CheckoutButton(
            isLoading: isLoading,
            disabled: itemCount == 0 || hasOutOfStock,
            onPressed: onCheckout,
          ),
          AppSpacing.gapSm,
          const Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 12,
                color: AppColors.neutral400,
              ),
              SizedBox(width: 6),
              Text(
                'Bảo mật & mã hoá thông tin thanh toán',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

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

class _CheckoutButton extends StatefulWidget {
  final bool isLoading;
  final bool disabled;
  final VoidCallback onPressed;

  const _CheckoutButton({
    required this.isLoading,
    required this.disabled,
    required this.onPressed,
  });

  @override
  State<_CheckoutButton> createState() => _CheckoutButtonState();
}

class _CheckoutButtonState extends State<_CheckoutButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final blocked = widget.disabled || widget.isLoading;
    final color = blocked
        ? AppColors.primary300
        : (_hover ? AppColors.primary600 : AppColors.primary500);
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: blocked ? null : widget.onPressed,
        onHover: (v) => setState(() => _hover = v),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(
                  Icons.lock_open_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              const SizedBox(width: 8),
              const Text(
                'Tiến hành thanh toán',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
