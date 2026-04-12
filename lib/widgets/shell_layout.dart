import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../config/colors.dart';
import 'header.dart';
import 'product_chatbot/chat_dock_scope.dart';
import 'product_chatbot/product_chatbot_body.dart';
import 'product_chatbot/product_chatbot_dock.dart';

class ShellLayout extends StatefulWidget {
  final Widget child;

  const ShellLayout({
    super.key,
    required this.child,
  });

  @override
  State<ShellLayout> createState() => _ShellLayoutState();
}

class _ShellLayoutState extends State<ShellLayout> {
  bool _chatDockOpen = false;

  int? _getCurrentNavIndex(String path) {
    switch (path) {
      case '/':
        return 0;
      case '/products':
        return 1;
      case '/news':
        return 2;
      case '/orders':
        return 3;
      default:
        return null;
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/products');
        break;
      case 2:
        context.go('/news');
        break;
      case 3:
        context.go('/orders');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final currentPath = GoRouterState.of(context).uri.path;
    final currentNavIndex = _getCurrentNavIndex(currentPath);
    final media = MediaQuery.of(context);
    final fabBottom = isMobile ? 88.0 + media.padding.bottom : 24.0;
    final panelW = ProductChatbotDockLayout.panelWidth(media.size.width);
    final panelH = ProductChatbotDockLayout.panelHeight(media.size.height);
    final keyboardInset = media.viewInsets.bottom;
    final showDockChrome = currentPath != '/chat';
    final dockOpen = showDockChrome && _chatDockOpen;

    return ChatDockScope(
      openDock: () {
        if (GoRouterState.of(context).uri.path == '/chat') return;
        setState(() => _chatDockOpen = true);
      },
      child: Scaffold(
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                const Header(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 0 : (isTablet ? 0 : 50),
                    ),
                    child: widget.child,
                  ),
                ),
              ],
            ),
            if (dockOpen)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _chatDockOpen = false),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.08),
                  ),
                ),
              ),
            if (showDockChrome)
              Positioned(
                right: 16,
                bottom: fabBottom + keyboardInset,
                child: dockOpen
                    ? Material(
                        elevation: 16,
                        shadowColor: Colors.black38,
                        borderRadius: BorderRadius.circular(16),
                        clipBehavior: Clip.antiAlias,
                        color: Theme.of(context).colorScheme.surface,
                        child: SizedBox(
                          width: panelW,
                          height: panelH,
                          child: ProductChatbotBody(
                            displayMode: ChatDisplayMode.dock,
                            onDockClose: () =>
                                setState(() => _chatDockOpen = false),
                          ),
                        ),
                      )
                    : Material(
                        elevation: 6,
                        shadowColor: Colors.black45,
                        shape: const CircleBorder(),
                        color: AppColors.primary,
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => setState(() => _chatDockOpen = true),
                          child: const SizedBox(
                            width: 56,
                            height: 56,
                            child: Icon(
                              Icons.chat_bubble_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
              ),
          ],
        ),
        bottomNavigationBar: isMobile
            ? Container(
                decoration: BoxDecoration(
                  color: AppColors.headerBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _BottomNavItem(
                          icon: Icons.home_outlined,
                          activeIcon: Icons.home,
                          label: 'Trang chủ',
                          isActive: currentNavIndex == 0,
                          onTap: () => _onItemTapped(0, context),
                        ),
                        _BottomNavItem(
                          icon: Icons.phone_android_outlined,
                          activeIcon: Icons.phone_android,
                          label: 'Sản phẩm',
                          isActive: currentNavIndex == 1,
                          onTap: () => _onItemTapped(1, context),
                        ),
                        _BottomNavItem(
                          icon: Icons.newspaper_outlined,
                          activeIcon: Icons.newspaper,
                          label: 'Tin tức',
                          isActive: currentNavIndex == 2,
                          onTap: () => _onItemTapped(2, context),
                        ),
                        _BottomNavItem(
                          icon: Icons.receipt_long_outlined,
                          activeIcon: Icons.receipt_long,
                          label: 'Đơn hàng',
                          isActive: currentNavIndex == 3,
                          onTap: () => _onItemTapped(3, context),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: AppColors.headerText,
                  size: isActive ? 24 : 22,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isActive ? 11 : 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: AppColors.headerText,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
