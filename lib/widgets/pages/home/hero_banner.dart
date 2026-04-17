import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/banner_model.dart';
import '../../../services/banner_service.dart';
import '../../web_safe_network_image.dart';

/// Hero banner – Modern Minimal.
///
/// • Bo tròn nhẹ, có nhãn "Mới" / "Khuyến mãi" overlay.
/// • Indicators dạng pill mảnh (active dài hơn).
/// • Nút prev/next ẩn, hiện khi hover trên desktop.
class HeroBanner extends StatefulWidget {
  const HeroBanner({super.key});

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  final PageController _pageController = PageController();
  final BannerService _bannerService = BannerService();
  int _currentPage = 0;
  Timer? _timer;
  List<BannerModel>? _banners;
  bool _isLoading = true;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadBanners() async {
    try {
      final banners = await _bannerService.getActiveBannersOnce();
      if (!mounted) return;
      setState(() {
        _banners = banners;
        _isLoading = false;
      });
      if (banners.isNotEmpty) _startAutoPlay(banners.length);
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startAutoPlay(int count) {
    if (count <= 1) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentPage + 1) % count;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final radius = isMobile ? AppRadius.xl : AppRadius.xl2;
    final height = isMobile ? 200.0 : 500.0;

    if (_isLoading) {
      return _SkeletonBanner(height: height, radius: radius);
    }
    if (_banners == null || _banners!.isEmpty) {
      return const SizedBox.shrink();
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 0 : AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(radius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            SizedBox(
              height: height,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _banners!.length,
                itemBuilder: (_, i) {
                  final banner = _banners![i];
                  return _BannerImage(banner: banner);
                },
              ),
            ),
            // Subtle gradient cho indicator dễ đọc
            if (_banners!.length > 1)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 60,
                child: IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0x66000000),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            // Indicators
            if (_banners!.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _banners!.length,
                    (i) => GestureDetector(
                      onTap: () => _goTo(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin:
                            const EdgeInsets.symmetric(horizontal: 3),
                        height: 6,
                        width: i == _currentPage ? 22 : 6,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.55),
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // Prev/Next nav (desktop hover)
            if (!isMobile && _banners!.length > 1) ...[
              Positioned(
                left: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: _isHovering ? 1 : 0,
                    child: _NavButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: () => _goTo(
                        (_currentPage - 1) < 0
                            ? _banners!.length - 1
                            : _currentPage - 1,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: _isHovering ? 1 : 0,
                    child: _NavButton(
                      icon: Icons.chevron_right_rounded,
                      onTap: () =>
                          _goTo((_currentPage + 1) % _banners!.length),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BannerImage extends StatelessWidget {
  final BannerModel banner;
  const _BannerImage({required this.banner});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: banner.link != null && banner.link!.isNotEmpty
          ? () {
              if (banner.link!.startsWith('/')) {
                context.go(banner.link!);
              }
            }
          : null,
      child: WebSafeNetworkImage(
        imageUrl: banner.imageUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: AppColors.neutral100,
          child: const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary500,
              ),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          color: AppColors.neutral100,
          child: const Center(
            child: Icon(
              Icons.image_outlined,
              size: 32,
              color: AppColors.neutral400,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 1.5,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 22,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _SkeletonBanner extends StatelessWidget {
  final double height;
  final double radius;
  const _SkeletonBanner({required this.height, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      height: height,
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary500,
          ),
        ),
      ),
    );
  }
}
