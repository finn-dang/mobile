import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../config/colors.dart';
import '../../config/spacing.dart';
import '../../services/auth_service.dart';

/// AdminShellLayout – Modern Minimal
///
/// • Desktop / Tablet: sidebar sáng, tối giản, có thể collapse.
/// • Mobile: AppBar + Drawer.
class AdminShellLayout extends StatelessWidget {
  final Widget child;

  const AdminShellLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    if (isMobile) {
      return _AdminMobileLayout(child: child);
    }
    return _AdminDesktopLayout(isTablet: isTablet, child: child);
  }
}

// ---------------------------------------------------------------------------
// Menu data
// ---------------------------------------------------------------------------

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  final bool Function(String currentPath) match;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.match,
  });
}

class _NavGroup {
  final String label;
  final List<_NavItem> items;
  const _NavGroup({required this.label, required this.items});
}

List<_NavGroup> _buildNavGroups() {
  return const [
    _NavGroup(label: 'TỔNG QUAN', items: [
      _NavItem(
        icon: Icons.dashboard_outlined,
        label: 'Dashboard',
        route: '/admin',
        match: _MatchExact.admin,
      ),
    ]),
    _NavGroup(label: 'KINH DOANH', items: [
      _NavItem(
        icon: Icons.inventory_2_outlined,
        label: 'Sản phẩm',
        route: '/admin/products',
        match: _MatchPrefix.products,
      ),
      _NavItem(
        icon: Icons.category_outlined,
        label: 'Danh mục',
        route: '/admin/categories',
        match: _MatchPrefix.categories,
      ),
      _NavItem(
        icon: Icons.shopping_bag_outlined,
        label: 'Đơn hàng',
        route: '/admin/orders',
        match: _MatchPrefix.orders,
      ),
      _NavItem(
        icon: Icons.reviews_outlined,
        label: 'Đánh giá',
        route: '/admin/reviews',
        match: _MatchPrefix.reviews,
      ),
    ]),
    _NavGroup(label: 'NỘI DUNG', items: [
      _NavItem(
        icon: Icons.home_outlined,
        label: 'Sections trang chủ',
        route: '/admin/home-sections',
        match: _MatchPrefix.homeSections,
      ),
      _NavItem(
        icon: Icons.article_outlined,
        label: 'Tin tức',
        route: '/admin/news',
        match: _MatchPrefix.news,
      ),
    ]),
    _NavGroup(label: 'HỆ THỐNG', items: [
      _NavItem(
        icon: Icons.people_outline,
        label: 'Người dùng',
        route: '/admin/users',
        match: _MatchPrefix.users,
      ),
      _NavItem(
        icon: Icons.settings_outlined,
        label: 'Cài đặt',
        route: '/admin/settings',
        match: _MatchPrefix.settings,
      ),
    ]),
  ];
}

// Static match functions để có thể dùng const
class _MatchExact {
  static bool admin(String p) => p == '/admin';
}

class _MatchPrefix {
  static bool products(String p) => p.startsWith('/admin/products');
  static bool categories(String p) => p.startsWith('/admin/categories');
  static bool orders(String p) => p.startsWith('/admin/orders');
  static bool reviews(String p) => p.startsWith('/admin/reviews');
  static bool homeSections(String p) => p.startsWith('/admin/home-sections');
  static bool news(String p) => p.startsWith('/admin/news');
  static bool users(String p) => p.startsWith('/admin/users');
  static bool settings(String p) => p.startsWith('/admin/settings');
}

// ---------------------------------------------------------------------------
// Logout helper
// ---------------------------------------------------------------------------

Future<void> _handleLogout(BuildContext context) async {
  final auth = AuthService();
  try {
    await auth.signOut();
    if (!context.mounted) return;
    context.go('/');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đăng xuất thành công!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lỗi khi đăng xuất: $e'),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop layout
// ---------------------------------------------------------------------------

class _AdminDesktopLayout extends StatefulWidget {
  final Widget child;
  final bool isTablet;
  const _AdminDesktopLayout({required this.child, required this.isTablet});

  @override
  State<_AdminDesktopLayout> createState() => _AdminDesktopLayoutState();
}

class _AdminDesktopLayoutState extends State<_AdminDesktopLayout> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      body: Row(
        children: [
          _AdminSidebar(
            isTablet: widget.isTablet,
            isCollapsed: _isCollapsed,
            onToggle: () => setState(() => _isCollapsed = !_isCollapsed),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile layout
// ---------------------------------------------------------------------------

class _AdminMobileLayout extends StatefulWidget {
  final Widget child;
  const _AdminMobileLayout({required this.child});

  @override
  State<_AdminMobileLayout> createState() => _AdminMobileLayoutState();
}

class _AdminMobileLayoutState extends State<_AdminMobileLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.adminBackground,
      appBar: AppBar(
        backgroundColor: AppColors.adminSidebarBg,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: AppColors.adminSidebarBg,
        shape: const Border(
          bottom: BorderSide(color: AppColors.adminBorder, width: 1),
        ),
        title: const Text(
          'Admin',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: _AdminDrawer(
        onItemSelected: () => _scaffoldKey.currentState?.closeDrawer(),
      ),
      body: widget.child,
    );
  }
}

// ---------------------------------------------------------------------------
// Sidebar
// ---------------------------------------------------------------------------

class _AdminSidebar extends StatelessWidget {
  final bool isTablet;
  final bool isCollapsed;
  final VoidCallback onToggle;

  const _AdminSidebar({
    required this.isTablet,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final width = isCollapsed ? 72.0 : (isTablet ? 220.0 : 248.0);
    final groups = _buildNavGroups();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.adminSidebarBg,
        border: Border(
          right: BorderSide(color: AppColors.adminBorder, width: 1),
        ),
      ),
      child: Column(
        children: [
          _SidebarBrand(isCollapsed: isCollapsed, onToggle: onToggle),
          const Divider(height: 1, color: AppColors.adminBorder),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              children: [
                for (var i = 0; i < groups.length; i++) ...[
                  if (!isCollapsed)
                    _SidebarGroupLabel(label: groups[i].label),
                  ...groups[i].items.map((item) => _SidebarNavTile(
                        item: item,
                        isActive: item.match(currentPath),
                        isCollapsed: isCollapsed,
                      )),
                  if (i < groups.length - 1) AppSpacing.gapMd,
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.adminBorder),
          // Logout pinned at bottom
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _SidebarNavTile(
              item: const _NavItem(
                icon: Icons.logout_rounded,
                label: 'Đăng xuất',
                route: '/',
                match: _MatchExact.admin, // never matches since path is /admin
              ),
              isActive: false,
              isCollapsed: isCollapsed,
              danger: true,
              onTapOverride: () => _handleLogout(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarBrand extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;
  const _SidebarBrand({required this.isCollapsed, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? AppSpacing.sm : AppSpacing.lg,
      ),
      child: Row(
        mainAxisAlignment: isCollapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        children: [
          if (!isCollapsed)
            Row(
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
                AppSpacing.gapSm,
                const Text(
                  'Doan Admin',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          Tooltip(
            message: isCollapsed ? 'Mở rộng' : 'Thu gọn',
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Icon(
                  isCollapsed
                      ? Icons.chevron_right_rounded
                      : Icons.chevron_left_rounded,
                  size: 20,
                  color: AppColors.neutral500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarGroupLabel extends StatelessWidget {
  final String label;
  const _SidebarGroupLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: AppColors.adminGroupLabel,
        ),
      ),
    );
  }
}

class _SidebarNavTile extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final bool isCollapsed;
  final bool danger;
  final VoidCallback? onTapOverride;

  const _SidebarNavTile({
    required this.item,
    required this.isActive,
    required this.isCollapsed,
    this.danger = false,
    this.onTapOverride,
  });

  @override
  State<_SidebarNavTile> createState() => _SidebarNavTileState();
}

class _SidebarNavTileState extends State<_SidebarNavTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final fg = widget.isActive
        ? AppColors.adminActiveFg
        : (widget.danger ? AppColors.error : AppColors.adminIdleFg);

    final bg = widget.isActive
        ? AppColors.adminActiveBg
        : (_hover
            ? (widget.danger
                ? AppColors.errorContainer
                : AppColors.surfaceMuted)
            : Colors.transparent);

    final tile = Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTapOverride ??
              () => context.go(widget.item.route),
          borderRadius: BorderRadius.circular(AppRadius.md),
          onHover: (v) => setState(() => _hover = v),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 0 : AppSpacing.md,
              vertical: 9,
            ),
            child: Row(
              mainAxisAlignment: widget.isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(widget.item.icon, size: 18, color: fg),
                if (!widget.isCollapsed) ...[
                  AppSpacing.gapSm,
                  Expanded(
                    child: Text(
                      widget.item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.isActive
                            ? AppColors.adminActiveFg
                            : (widget.danger
                                ? AppColors.error
                                : AppColors.textPrimary),
                        fontSize: 13.5,
                        fontWeight: widget.isActive
                            ? FontWeight.w600
                            : FontWeight.w500,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.isCollapsed) {
      return Tooltip(message: widget.item.label, child: tile);
    }
    return tile;
  }
}

// ---------------------------------------------------------------------------
// Mobile drawer
// ---------------------------------------------------------------------------

class _AdminDrawer extends StatelessWidget {
  final VoidCallback onItemSelected;
  const _AdminDrawer({required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final groups = _buildNavGroups();

    return Drawer(
      backgroundColor: AppColors.adminSidebarBg,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            // Brand header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.adminBorder),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary500,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  AppSpacing.gapMd,
                  const Text(
                    'Doan Admin',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                children: [
                  for (var i = 0; i < groups.length; i++) ...[
                    _SidebarGroupLabel(label: groups[i].label),
                    ...groups[i].items.map(
                      (item) => _SidebarNavTile(
                        item: item,
                        isActive: item.match(currentPath),
                        isCollapsed: false,
                        onTapOverride: () {
                          context.go(item.route);
                          onItemSelected();
                        },
                      ),
                    ),
                    if (i < groups.length - 1) AppSpacing.gapMd,
                  ],
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.adminBorder),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _SidebarNavTile(
                item: const _NavItem(
                  icon: Icons.logout_rounded,
                  label: 'Đăng xuất',
                  route: '/',
                  match: _MatchExact.admin,
                ),
                isActive: false,
                isCollapsed: false,
                danger: true,
                onTapOverride: () async {
                  onItemSelected();
                  await _handleLogout(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
