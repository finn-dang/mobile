import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../config/colors.dart';
import '../config/spacing.dart';
import '../services/auth_service.dart';
import 'header_cart_button.dart';
import 'header_orders_button.dart';
import 'product_chatbot/chat_dock_scope.dart';

/// Header trang customer – Modern Minimal.
///
/// • Nền trắng + border 1px dưới (sticky-friendly)
/// • Logo cam, nav text màu chữ chính
/// • Active nav có underline cam
/// • Mobile: drawer bottom-sheet sạch
class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.adminBorder, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? AppSpacing.lg : AppSpacing.xl3,
            vertical: 12,
          ),
          child: Row(
            children: [
              // Logo
              GestureDetector(
                onTap: () => context.go('/'),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary500,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Uniqlo Clone Store',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              if (!isMobile) ...[
                _NavItem(label: 'Trang chủ', route: '/'),
                AppSpacing.gapXl,
                _NavItem(label: 'Sản phẩm', route: '/products'),
                AppSpacing.gapXl,
                _NavItem(label: 'Tin tức', route: '/news'),
                AppSpacing.gapXl2,
                const _ToolDivider(),
                AppSpacing.gapMd,
                const HeaderCartButton(isMobile: false),
                AppSpacing.gapSm,
                const HeaderOrdersButton(isMobile: false),
                AppSpacing.gapMd,
                _AccountButton(isMobile: false),
              ] else ...[
                const HeaderCartButton(isMobile: true),
                const HeaderOrdersButton(isMobile: true),
                IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => _showMobileMenu(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl2),
            topRight: Radius.circular(AppRadius.xl2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MobileNavItem(
                    label: 'Trang chủ',
                    icon: Icons.home_outlined,
                    route: '/',
                    currentRoute: currentRoute,
                  ),
                  _MobileNavItem(
                    label: 'Sản phẩm',
                    icon: Icons.inventory_2_outlined,
                    route: '/products',
                    currentRoute: currentRoute,
                  ),
                  _MobileNavItem(
                    label: 'Tin tức',
                    icon: Icons.article_outlined,
                    route: '/news',
                    currentRoute: currentRoute,
                  ),
                  _MobileNavItem(
                    label: 'Đơn hàng',
                    icon: Icons.receipt_long_outlined,
                    route: '/orders',
                    currentRoute: currentRoute,
                  ),
                  _MobileMenuTile(
                    icon: Icons.smart_toy_outlined,
                    label: 'Tư vấn phối đồ',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      Future.microtask(() {
                        if (context.mounted) {
                          ChatDockScope.open(context);
                        }
                      });
                    },
                  ),
                  const Divider(
                    height: 24,
                    color: AppColors.neutral100,
                  ),
                  _MobileAccountButton(currentRoute: currentRoute),
                  SizedBox(
                    height: MediaQuery.of(sheetContext).padding.bottom + 12,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop nav item (underline khi active)
// ---------------------------------------------------------------------------

class _NavItem extends StatefulWidget {
  final String label;
  final String route;
  const _NavItem({required this.label, required this.route});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isActive = GoRouterState.of(context).uri.path == widget.route;

    return InkWell(
      onTap: () => context.go(widget.route),
      onHover: (v) => setState(() => _hover = v),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? AppColors.primary600
                    : (_hover
                        ? AppColors.textPrimary
                        : AppColors.textSecondary),
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              height: 2,
              width: isActive ? 22 : 0,
              decoration: BoxDecoration(
                color: AppColors.primary500,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolDivider extends StatelessWidget {
  const _ToolDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: AppColors.neutral200,
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile nav items
// ---------------------------------------------------------------------------

class _MobileNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  final String currentRoute;

  const _MobileNavItem({
    required this.label,
    required this.icon,
    required this.route,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentRoute == route;
    return _MobileMenuTile(
      icon: icon,
      label: label,
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
      isActive: isActive,
    );
  }
}

class _MobileMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _MobileMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AppColors.primary50 : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 12,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive
                    ? AppColors.primary600
                    : AppColors.neutral500,
              ),
              AppSpacing.gapMd,
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? AppColors.primary600
                        : AppColors.textPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              if (isActive)
                Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: AppColors.primary600,
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.neutral400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Account button (desktop + mobile)
// ---------------------------------------------------------------------------

class _AccountButton extends StatelessWidget {
  final bool isMobile;
  final AuthService _authService = AuthService();

  _AccountButton({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        final isLoggedIn = snapshot.hasData && snapshot.data != null;
        if (isLoggedIn) {
          return _AccountMenuButton(isMobile: isMobile);
        }
        return _LoginButton(isMobile: isMobile);
      },
    );
  }
}

class _AccountMenuButton extends StatefulWidget {
  final bool isMobile;
  final AuthService _authService = AuthService();
  _AccountMenuButton({required this.isMobile});

  @override
  State<_AccountMenuButton> createState() => _AccountMenuButtonState();
}

class _AccountMenuButtonState extends State<_AccountMenuButton> {
  bool _hover = false;

  String get _name {
    final n = widget._authService.currentUser?.displayName;
    if (n == null || n.trim().isEmpty) {
      return widget._authService.currentUser?.email?.split('@').first ?? 'Bạn';
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showAccountMenu(context),
      onHover: (v) => setState(() => _hover = v),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
        decoration: BoxDecoration(
          color: _hover ? AppColors.surfaceMuted : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: _hover ? AppColors.adminBorder : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              alignment: Alignment.center,
              child: Text(
                _name.isNotEmpty ? _name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: AppColors.primary600,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _name,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.neutral500,
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountMenu(BuildContext context) {
    if (widget.isMobile) {
      _showAccountSheet(context, widget._authService);
      return;
    }

    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    showMenu(
      context: context,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.adminBorder),
      ),
      elevation: 4,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height + 6,
        offset.dx + renderBox.size.width,
        offset.dy + renderBox.size.height + 100,
      ),
      items: [
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(
                Icons.logout_rounded,
                size: 16,
                color: AppColors.error,
              ),
              SizedBox(width: 10),
              Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          onTap: () async {
            await Future.delayed(const Duration(milliseconds: 100));
            try {
              await widget._authService.signOut();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: $e')),
                );
              }
            }
          },
        ),
      ],
    );
  }
}

void _showAccountSheet(BuildContext context, AuthService authService) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl2),
          topRight: Radius.circular(AppRadius.xl2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
              ),
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text(
                'Đăng xuất',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () async {
                Navigator.pop(sheetContext);
                try {
                  await authService.signOut();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e')),
                    );
                  }
                }
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(sheetContext).padding.bottom + 12),
        ],
      ),
    ),
  );
}

class _LoginButton extends StatefulWidget {
  final bool isMobile;
  const _LoginButton({required this.isMobile});

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary500,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: () => context.go('/login'),
        onHover: (v) => setState(() => _hover = v),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isMobile ? 12 : AppSpacing.lg,
            vertical: widget.isMobile ? 8 : 9,
          ),
          decoration: BoxDecoration(
            color: _hover ? AppColors.primary600 : AppColors.primary500,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.login_rounded,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                'Đăng nhập',
                style: TextStyle(
                  fontSize: widget.isMobile ? 13 : 13.5,
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

class _MobileAccountButton extends StatelessWidget {
  final AuthService _authService = AuthService();
  final String currentRoute;

  _MobileAccountButton({required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        final isLoggedIn = snapshot.hasData && snapshot.data != null;
        if (isLoggedIn) {
          final name = snapshot.data?.displayName ?? 'Bạn';
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                _showAccountSheet(context, _authService);
              },
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: AppColors.primary600,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.neutral400,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return _MobileMenuTile(
          icon: Icons.login_rounded,
          label: 'Đăng nhập',
          onTap: () {
            Navigator.pop(context);
            context.go('/login');
          },
        );
      },
    );
  }
}
