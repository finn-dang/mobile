import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../web_safe_network_image.dart';

/// Hàng ảnh trong review – Modern Minimal.
///
/// Click → full-screen viewer.
class ReviewImagesSection extends StatelessWidget {
  final List<String> imageUrls;
  final bool isMobile;

  const ReviewImagesSection({
    super.key,
    required this.imageUrls,
    required this.isMobile,
  });

  void _openViewer(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        child: Stack(
          children: [
            Center(
              child: WebSafeNetworkImage(
                imageUrl: imageUrls[index],
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => const Icon(
                  Icons.broken_image_outlined,
                  size: 56,
                  color: Colors.white54,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: AppColors.neutral900.withValues(alpha: 0.6),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pop(),
                  child: const SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = isMobile ? 64.0 : 76.0;
    return SizedBox(
      height: size,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => _Thumb(
          url: imageUrls[i],
          size: size,
          onTap: () => _openViewer(context, i),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String url;
  final double size;
  final VoidCallback onTap;

  const _Thumb({
    required this.url,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.adminBorder),
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
          errorWidget: (_, __, ___) => const Icon(
            Icons.image_outlined,
            size: 22,
            color: AppColors.neutral400,
          ),
        ),
      ),
    );
  }
}
