// Modern Minimal – List sản phẩm trong checkout (read-only).
//
// Container border 1px wrap, mỗi item có thumb 56px + tên + variant pill +
// quantity + giá. Divider mảnh giữa items.

import 'package:flutter/material.dart';

import '../../../../config/colors.dart';
import '../../../../config/spacing.dart';
import '../../../../models/cart_model.dart';
import '../../web_safe_network_image.dart';

class OrderItemsList extends StatelessWidget {
  final List<CartItemModel> cartItems;

  const OrderItemsList({super.key, required this.cartItems});

  String _formatPrice(int p) => p.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 16,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: 8),
            const Text(
              'Sản phẩm',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                '${cartItems.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral600,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.gapMd,
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.adminBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < cartItems.length; i++) ...[
                if (i > 0)
                  const Divider(height: 1, color: AppColors.neutral100),
                _Row(
                  item: cartItems[i],
                  formatPrice: _formatPrice,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final CartItemModel item;
  final String Function(int) formatPrice;
  const _Row({required this.item, required this.formatPrice});

  @override
  Widget build(BuildContext context) {
    final variant = [
      if (item.selectedVersion != null) item.selectedVersion,
      if (item.selectedColor != null) item.selectedColor,
    ].whereType<String>().join(' · ');

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumb
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.adminBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: item.imageUrl != null
                ? WebSafeNetworkImage(
                    imageUrl: item.imageUrl!,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const Center(
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.4,
                          color: AppColors.primary500,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 18,
                        color: AppColors.neutral400,
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 18,
                      color: AppColors.neutral400,
                    ),
                  ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.1,
                    height: 1.35,
                  ),
                ),
                if (variant.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius:
                          BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.adminBorder),
                    ),
                    child: Text(
                      variant,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SL: ${item.quantity}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${formatPrice(item.totalPrice)} ₫',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
