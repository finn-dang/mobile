import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/colors.dart';
import '../config/spacing.dart';
import '../models/order_status.dart';
import '../services/order_service.dart';

/// Nút Đơn hàng trên header – Modern Minimal.
class HeaderOrdersButton extends StatelessWidget {
  final bool isMobile;
  const HeaderOrdersButton({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();
    return StreamBuilder(
      stream: orderService.getOrders(),
      builder: (context, snapshot) {
        final orders = snapshot.data ?? const [];
        final pending = orders
            .where((o) =>
                o.status == OrderStatus.pending ||
                o.status == OrderStatus.confirmed ||
                o.status == OrderStatus.processing ||
                o.status == OrderStatus.delivering)
            .length;

        return _IconWithBadge(
          icon: Icons.receipt_long_outlined,
          tooltip: 'Đơn hàng của tôi',
          badgeCount: pending,
          isActive: GoRouterState.of(context).uri.path == '/orders',
          onTap: () => context.go('/orders'),
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

  const _IconWithBadge({
    required this.icon,
    required this.tooltip,
    required this.badgeCount,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_IconWithBadge> createState() => _IconWithBadgeState();
}

class _IconWithBadgeState extends State<_IconWithBadge> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: SizedBox(
        width: 40,
        height: 40,
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
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.badgeCount > 9 ? '9+' : '${widget.badgeCount}',
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
