import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';

/// 2 nút "Thêm vào giỏ" (outline) + "Mua ngay" (primary cam) – Modern Minimal.
class BuyActionBar extends StatelessWidget {
  final bool isOutOfStock;
  final bool isLoading;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final bool stacked;

  const BuyActionBar({
    super.key,
    required this.isOutOfStock,
    required this.isLoading,
    required this.onAddToCart,
    required this.onBuyNow,
    this.stacked = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutOfStock) {
      return _OutOfStockButton();
    }

    final addButton = _OutlinedAction(
      icon: Icons.shopping_bag_outlined,
      label: 'Thêm vào giỏ',
      isLoading: isLoading,
      onPressed: onAddToCart,
    );

    final buyButton = _PrimaryAction(
      icon: Icons.flash_on_rounded,
      label: 'Mua ngay',
      isLoading: isLoading,
      onPressed: onBuyNow,
    );

    if (stacked) {
      return Column(
        children: [
          SizedBox(width: double.infinity, child: buyButton),
          AppSpacing.gapSm,
          SizedBox(width: double.infinity, child: addButton),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: addButton),
        AppSpacing.gapMd,
        Expanded(flex: 2, child: buyButton),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _PrimaryAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _PrimaryAction({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<_PrimaryAction> createState() => _PrimaryActionState();
}

class _PrimaryActionState extends State<_PrimaryAction> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.isLoading
          ? AppColors.primary300
          : (_hover ? AppColors.primary600 : AppColors.primary500),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: widget.isLoading ? null : widget.onPressed,
        onHover: (v) => setState(() => _hover = v),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
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
                Icon(widget.icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.isLoading ? 'Đang xử lý...' : widget.label,
                style: const TextStyle(
                  fontSize: 14.5,
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

class _OutlinedAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _OutlinedAction({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<_OutlinedAction> createState() => _OutlinedActionState();
}

class _OutlinedActionState extends State<_OutlinedAction> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _hover ? AppColors.primary50 : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: widget.isLoading ? null : widget.onPressed,
        onHover: (v) => setState(() => _hover = v),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.primary500,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary500,
                  ),
                )
              else
                Icon(widget.icon, size: 18, color: AppColors.primary600),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary600,
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

class _OutOfStockButton extends StatelessWidget {
  const _OutOfStockButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.block_rounded,
            size: 18,
            color: AppColors.neutral500,
          ),
          SizedBox(width: 8),
          Text(
            'Hết hàng',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral500,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
