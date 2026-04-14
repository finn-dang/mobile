import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/category_model.dart';
import '../common/admin_card.dart';
import '../common/admin_dialog.dart';
import '../common/admin_page_header.dart';

/// Confirm dialog xoá danh mục – Modern Minimal.
class DeleteCategoryDialog extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onConfirm;

  const DeleteCategoryDialog({
    super.key,
    required this.category,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AdminDialogShell(
      maxWidth: 480,
      title: 'Xóa danh mục?',
      subtitle:
          'Hành động này không thể hoàn tác. Sản phẩm thuộc danh mục có thể bị ảnh hưởng.',
      icon: Icons.delete_outline_rounded,
      iconBg: AppColors.errorContainer,
      iconFg: AppColors.errorDark,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thông tin danh mục
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.adminBorder),
            ),
            child: Row(
              children: [
                _Thumb(imageUrl: category.imageUrl),
                AppSpacing.gapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        category.description?.trim().isNotEmpty == true
                            ? category.description!
                            : 'Không có mô tả',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapSm,
                AdminStatusPill.neutral(
                  '${category.productCount} sản phẩm',
                  icon: Icons.inventory_2_outlined,
                ),
              ],
            ),
          ),
          AppSpacing.gapMd,
          AdminInlineNotice.danger(
            'Sau khi xoá, danh mục sẽ không thể khôi phục.',
          ),
        ],
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AdminSecondaryButton(
            label: 'Hủy',
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppSpacing.gapMd,
          _DangerButton(
            label: 'Xóa danh mục',
            icon: Icons.delete_outline_rounded,
            onPressed: onConfirm,
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? imageUrl;
  const _Thumb({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
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
                  Icons.category_outlined,
                  size: 18,
                  color: AppColors.neutral400,
                ),
              )
            : const Icon(
                Icons.category_outlined,
                size: 18,
                color: AppColors.neutral400,
              ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _DangerButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.error,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              AppSpacing.gapSm,
              Text(
                label,
                style: const TextStyle(
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
