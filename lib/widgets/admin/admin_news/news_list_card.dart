import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/news_model.dart';
import '../common/admin_card.dart';

/// Card 1 bài viết – Modern Minimal.
class NewsListCard extends StatelessWidget {
  final NewsModel article;
  final VoidCallback onEdit;
  final VoidCallback onTogglePublish;
  final VoidCallback onDelete;
  final String Function(DateTime) formatDate;
  final bool isMobile;

  const NewsListCard({
    super.key,
    required this.article,
    required this.onEdit,
    required this.onTogglePublish,
    required this.onDelete,
    required this.formatDate,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.adminBorder),
      ),
      padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumb
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              width: isMobile ? 70 : 96,
              height: isMobile ? 56 : 72,
              color: AppColors.neutral100,
              child: CachedNetworkImage(
                imageUrl: article.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const Icon(
                  Icons.image_not_supported_outlined,
                  size: 22,
                  color: AppColors.neutral400,
                ),
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
              ),
            ),
          ),
          SizedBox(width: isMobile ? AppSpacing.md : AppSpacing.lg),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        article.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                    AppSpacing.gapSm,
                    article.isPublished
                        ? AdminStatusPill.success(
                            'Đã xuất bản',
                            icon: Icons.check_circle_outline_rounded,
                          )
                        : AdminStatusPill.warning(
                            'Bản nháp',
                            icon: Icons.edit_note_rounded,
                          ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  article.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    _MetaItem(
                      icon: Icons.person_outline,
                      text: article.author,
                    ),
                    _MetaItem(
                      icon: Icons.category_outlined,
                      text: article.category,
                    ),
                    _MetaItem(
                      icon: Icons.calendar_today_outlined,
                      text: formatDate(article.publishDate),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          AppSpacing.gapSm,
          isMobile
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _IconAction(
                      icon: Icons.edit_outlined,
                      tooltip: 'Sửa',
                      color: AppColors.primary600,
                      onPressed: onEdit,
                    ),
                    AppSpacing.gapXs,
                    _IconAction(
                      icon: article.isPublished
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      tooltip:
                          article.isPublished ? 'Ẩn bài viết' : 'Xuất bản',
                      color: article.isPublished
                          ? AppColors.warning
                          : AppColors.success,
                      onPressed: onTogglePublish,
                    ),
                    AppSpacing.gapXs,
                    _IconAction(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Xoá',
                      color: AppColors.error,
                      onPressed: onDelete,
                    ),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _IconAction(
                      icon: Icons.edit_outlined,
                      tooltip: 'Sửa',
                      color: AppColors.primary600,
                      onPressed: onEdit,
                    ),
                    AppSpacing.gapXs,
                    _IconAction(
                      icon: article.isPublished
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      tooltip:
                          article.isPublished ? 'Ẩn bài viết' : 'Xuất bản',
                      color: article.isPublished
                          ? AppColors.warning
                          : AppColors.success,
                      onPressed: onTogglePublish,
                    ),
                    AppSpacing.gapXs,
                    _IconAction(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Xoá',
                      color: AppColors.error,
                      onPressed: onDelete,
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.neutral400),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11.5,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _IconAction extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;

  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_IconAction> createState() => _IconActionState();
}

class _IconActionState extends State<_IconAction> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Material(
          color: _hover
              ? widget.color.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: InkWell(
            onTap: widget.onPressed,
            onHover: (v) => setState(() => _hover = v),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Icon(widget.icon, size: 16, color: widget.color),
          ),
        ),
      ),
    );
  }
}
