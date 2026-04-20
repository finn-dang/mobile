import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../web_safe_network_image.dart';

/// Gallery sản phẩm – Modern Minimal.
///
/// Desktop/tablet: thumb dọc bên trái + ảnh chính lớn bên phải.
/// Mobile: ảnh chính lớn + thumb ngang ở dưới.
class ProductGallery extends StatelessWidget {
  final List<String> images;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const ProductGallery({
    super.key,
    required this.images,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    if (images.isEmpty) {
      return _MainImageBox(
        height: isMobile ? 320 : 480,
        child: const _ImagePlaceholder(),
      );
    }

    if (isMobile) {
      return Column(
        children: [
          _MainImageBox(
            height: 320,
            child: _MainImage(url: images[selectedIndex]),
          ),
          if (images.length > 1) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => _Thumb(
                  url: images[i],
                  size: 64,
                  isActive: i == selectedIndex,
                  onTap: () => onSelected(i),
                ),
              ),
            ),
          ],
        ],
      );
    }

    // Desktop / Tablet: thumb dọc trái + ảnh chính phải
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.length > 1) ...[
          SizedBox(
            width: 72,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < images.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _Thumb(
                      url: images[i],
                      size: 64,
                      isActive: i == selectedIndex,
                      onTap: () => onSelected(i),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: _MainImageBox(
            height: 480,
            child: _MainImage(url: images[selectedIndex]),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _MainImageBox extends StatelessWidget {
  final double height;
  final Widget child;
  const _MainImageBox({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.adminBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _MainImage extends StatelessWidget {
  final String url;
  const _MainImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return WebSafeNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      placeholder: (_, __) => const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary500,
          ),
        ),
      ),
      errorWidget: (_, __, ___) => const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.image_outlined,
        size: 48,
        color: AppColors.neutral400,
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String url;
  final double size;
  final bool isActive;
  final VoidCallback onTap;

  const _Thumb({
    required this.url,
    required this.size,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isActive ? AppColors.primary500 : AppColors.adminBorder,
            width: isActive ? 1.6 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: WebSafeNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
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
          errorWidget: (_, __, ___) => const Center(
            child: Icon(
              Icons.image_outlined,
              size: 18,
              color: AppColors.neutral400,
            ),
          ),
        ),
      ),
    );
  }
}
