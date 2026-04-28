import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';

/// Empty state cho cart – Modern Minimal.
///
/// Có 2 mode: chưa login + cart rỗng.
class EmptyCart extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback onAction;

  const EmptyCart({
    super.key,
    required this.isLoggedIn,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final icon = isLoggedIn
        ? Icons.shopping_bag_outlined
        : Icons.lock_outline_rounded;
    final title = isLoggedIn
        ? 'Giỏ hàng trống'
        : 'Vui lòng đăng nhập';
    final desc = isLoggedIn
        ? 'Hãy khám phá sản phẩm và thêm vào giỏ hàng để bắt đầu mua sắm.'
        : 'Đăng nhập để xem các sản phẩm bạn đã thêm vào giỏ hàng.';
    final actionLabel = isLoggedIn ? 'Khám phá sản phẩm' : 'Đăng nhập';
    final actionIcon =
        isLoggedIn ? Icons.shopping_bag_outlined : Icons.login_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl5,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(AppRadius.xl3),
            ),
            child: Icon(icon, size: 32, color: AppColors.primary600),
          ),
          AppSpacing.gapMd,
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          AppSpacing.gapLg,
          _PrimaryButton(
            icon: actionIcon,
            label: actionLabel,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _hover ? AppColors.primary600 : AppColors.primary500,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: widget.onPressed,
        onHover: (v) => setState(() => _hover = v),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
