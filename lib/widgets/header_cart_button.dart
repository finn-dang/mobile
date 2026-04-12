import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/colors.dart';
import '../config/spacing.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';

/// Nút Giỏ hàng trên header – Modern Minimal.
class HeaderCartButton extends StatelessWidget {
  final bool isMobile;

  const HeaderCartButton({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final cartService = CartService();
    return StreamBuilder<List<CartItemModel>>(
      stream: cartService.getCartItems(),
      builder: (context, snapshot) {
        int total = 0;
        if (snapshot.hasData && snapshot.data != null) {
          for (final i in snapshot.data!) {
            total += i.quantity;
          }
        }

        return _IconWithBadge(
          icon: Icons.shopping_cart_outlined,
          tooltip: 'Giỏ hàng',
          badgeCount: total,
          isActive: GoRouterState.of(context).uri.path == '/cart',
          onTap: () => context.go('/cart'),
          isMobile: isMobile,
        );
      },
    );
  }
}

class _IconWithBadge extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final int badgeCount;
  final bool isActive;
  final VoidCallback onTap;
  final bool isMobile;

  const _IconWithBadge({
    required this.icon,
    required this.tooltip,
    required this.badgeCount,
    required this.isActive,
    required this.onTap,
    required this.isMobile,
  });

  @override
  State<_IconWithBadge> createState() => _IconWithBadgeState();
}

class _IconWithBadgeState extends State<_IconWithBadge> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final size = widget.isMobile ? 40.0 : 40.0;
    return Tooltip(
      message: widget.tooltip,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: widget.isActive
                  ? AppColors.primary50
                  : (_hover ? AppColors.surfaceMuted : Colors.transparent),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: InkWell(
                onTap: widget.onTap,
                onHover: (v) => setState(() => _hover = v),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Center(
                  child: Icon(
                    widget.icon,
                    size: 20,
                    color: widget.isActive
                        ? AppColors.primary600
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            if (widget.badgeCount > 0)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.badgeCount > 99 ? '99+' : '${widget.badgeCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
