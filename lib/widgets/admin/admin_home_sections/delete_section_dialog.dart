import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/home_section_model.dart';
import '../common/admin_card.dart';
import '../common/admin_dialog.dart';
import '../common/admin_page_header.dart';

/// Confirm dialog xoá bộ sưu tập – Modern Minimal.
class DeleteSectionDialog extends StatelessWidget {
  final HomeSectionModel section;

  const DeleteSectionDialog({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return AdminDialogShell(
      maxWidth: 460,
      title: 'Xoá bộ sưu tập?',
      subtitle:
          'Bộ sưu tập sẽ không còn hiển thị trên trang chủ. Hành động không thể hoàn tác.',
      icon: Icons.delete_outline_rounded,
      iconBg: AppColors.errorContainer,
      iconFg: AppColors.errorDark,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.adminBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.view_list_outlined,
                    size: 18,
                    color: AppColors.primary600,
                  ),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        section.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${section.productIds.length} sản phẩm • Thứ tự ${section.order}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapMd,
          AdminInlineNotice.danger(
            'Sau khi xoá, bộ sưu tập sẽ biến mất khỏi trang chủ ngay lập tức.',
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
              Icon(Icons.delete_outline_rounded, size: 16, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Xoá bộ sưu tập',
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
