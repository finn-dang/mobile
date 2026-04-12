import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/banner_model.dart';
import '../common/admin_card.dart';
import '../common/admin_dialog.dart';
import '../common/admin_page_header.dart';

/// Confirm dialog xoá banner – Modern Minimal.
class DeleteBannerDialog extends StatelessWidget {
  final BannerModel banner;

  const DeleteBannerDialog({super.key, required this.banner});

  @override
  Widget build(BuildContext context) {
    return AdminDialogShell(
      maxWidth: 460,
      title: 'Xoá banner?',
      subtitle:
          'Banner sẽ ngừng hiển thị trên trang chủ. Hành động không thể hoàn tác.',
      icon: Icons.delete_outline_rounded,
      iconBg: AppColors.errorContainer,
      iconFg: AppColors.errorDark,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner preview
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.adminBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: AspectRatio(
              aspectRatio: 16 / 6,
              child: CachedNetworkImage(
                imageUrl: banner.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.6,
                      color: AppColors.primary500,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 22,
                    color: AppColors.neutral400,
                  ),
                ),
              ),
            ),
          ),
          AppSpacing.gapMd,
          AdminInlineNotice.danger(
            'Sau khi xoá, banner sẽ biến mất khỏi trang chủ ngay lập tức.',
          ),
        ],
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AdminSecondaryButton(
            label: 'Hủy',
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AppSpacing.gapMd,
          _DangerButton(
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _DangerButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.error,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline_rounded,
                  size: 16, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Xoá banner',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
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
