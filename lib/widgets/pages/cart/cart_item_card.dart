import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/cart_model.dart';
import '../../web_safe_network_image.dart';

/// Card 1 sản phẩm trong giỏ hàng – Modern Minimal.
///
/// Hiển thị: thumb 80px + tên + variant badge + giá + counter + xoá.
/// Có warning bar khi hết hàng hoặc vượt số lượng.
class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final int availableQuantity;
  final bool isLoadingStock;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.availableQuantity,
    required this.isLoadingStock,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  String _formatPrice(int p) => p.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = !isLoadingStock && availableQuantity == 0;
    final isExceeded =
        !isLoadingStock && item.quantity > availableQuantity && availableQuantity > 0;
    final canDec = !isOutOfStock && item.quantity > 1;
    final canInc = !isOutOfStock && item.quantity < availableQuantity;

    final variantText = [
      if (item.selectedVersion != null) item.selectedVersion,
      if (item.selectedColor != null) item.selectedColor,
    ].whereType<String>().join(' · ');

    final borderColor = isOutOfStock
        ? AppColors.errorLight
        : (isExceeded ? AppColors.warningLight : AppColors.adminBorder);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: borderColor, width: isOutOfStock ? 1.2 : 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumb(
                imageUrl: item.imageUrl,
                isOutOfStock: isOutOfStock,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.1,
                        height: 1.35,
                      ),
                    ),
                    if (variantText.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: AppColors.adminBorder),
                        ),
                        child: Text(
                          variantText,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_formatPrice(item.price)} ₫',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary600,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (item.originalPrice > item.price) ...[
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              '${_formatPrice(item.originalPrice)} ₫',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.neutral400,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: AppColors.neutral400,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.gapSm,
              _RemoveButton(onTap: onRemove),
            ],
          ),
          if (isOutOfStock || isExceeded) ...[
            AppSpacing.gapSm,
            isOutOfStock
                ? const _StockBanner(
                    icon: Icons.warning_amber_rounded,
                    message: 'Sản phẩm hiện đã hết hàng',
                    fg: AppColors.errorDark,
                    bg: AppColors.errorContainer,
                    border: AppColors.errorLight,
                  )
                : _StockBanner(
                    icon: Icons.info_outline_rounded,
                    message: 'Chỉ còn $availableQuantity sản phẩm',
                    fg: AppColors.warningDark,
                    bg: AppColors.warningContainer,
                    border: AppColors.warningLight,
                  ),
          ],
          AppSpacing.gapMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QtySelector(
                value: item.quantity,
                canInc: canInc,
                canDec: canDec,
                onInc: onIncrement,
                onDec: onDecrement,
              ),
              Text(
                '${_formatPrice(item.totalPrice)} ₫',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
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

class _Thumb extends StatelessWidget {
  final String? imageUrl;
  final bool isOutOfStock;

  const _Thumb({required this.imageUrl, required this.isOutOfStock});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.adminBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: imageUrl != null
              ? WebSafeNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.4,
                        color: AppColors.primary500,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.image_outlined,
                    size: 22,
                    color: AppColors.neutral400,
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 22,
                    color: AppColors.neutral400,
                  ),
                ),
        ),
        if (isOutOfStock)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: const Text(
                  'Hết hàng',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StockBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color fg;
  final Color bg;
  final Color border;

  const _StockBanner({
    required this.icon,
    required this.message,
    required this.fg,
    required this.bg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtySelector extends StatelessWidget {
  final int value;
  final bool canInc;
  final bool canDec;
  final VoidCallback onInc;
  final VoidCallback onDec;

  const _QtySelector({
    required this.value,
    required this.canInc,
    required this.canDec,
    required this.onInc,
    required this.onDec,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(
            icon: Icons.remove_rounded,
            enabled: canDec,
            onPressed: onDec,
          ),
          SizedBox(
            width: 36,
            child: Center(
              child: Text(
                '$value',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          _QtyButton(
            icon: Icons.add_rounded,
            enabled: canInc,
            onPressed: onInc,
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const _QtyButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: Center(
            child: Icon(
              icon,
              size: 14,
              color: enabled ? AppColors.textPrimary : AppColors.neutral300,
            ),
          ),
        ),
      ),
    );
  }
}

class _RemoveButton extends StatefulWidget {
  final VoidCallback onTap;
  const _RemoveButton({required this.onTap});

  @override
  State<_RemoveButton> createState() => _RemoveButtonState();
}

class _RemoveButtonState extends State<_RemoveButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Xoá khỏi giỏ',
      child: SizedBox(
        width: 32,
        height: 32,
        child: Material(
          color:
              _hover ? AppColors.errorContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: InkWell(
            onTap: widget.onTap,
            onHover: (v) => setState(() => _hover = v),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: const Icon(
              Icons.delete_outline_rounded,
              size: 16,
              color: AppColors.error,
            ),
          ),
        ),
      ),
    );
  }
}
