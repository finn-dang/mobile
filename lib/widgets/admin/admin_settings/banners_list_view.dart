import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/banner_model.dart';
import '../common/admin_card.dart';

/// Lưới danh sách banner – Modern Minimal.
class BannersListView extends StatelessWidget {
  final List<BannerModel> banners;
  final Function(BannerModel) onEdit;
  final Function(BannerModel) onDelete;

  const BannersListView({
    super.key,
    required this.banners,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    if (isMobile) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: banners.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, i) => _BannerCard(
          banner: banners[i],
          onEdit: () => onEdit(banners[i]),
          onDelete: () => onDelete(banners[i]),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 2 : 3,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
        childAspectRatio: 1.6,
      ),
      itemCount: banners.length,
      itemBuilder: (_, i) => _BannerCard(
        banner: banners[i],
        onEdit: () => onEdit(banners[i]),
        onDelete: () => onDelete(banners[i]),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final BannerModel banner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BannerCard({
    required this.banner,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _timeRangeText() {
    if (banner.startDate == null && banner.endDate == null) {
      return 'Luôn hiển thị';
    }
    final start =
        banner.startDate != null ? _formatDate(banner.startDate!) : '';
    final end = banner.endDate != null ? _formatDate(banner.endDate!) : '';
    if (start.isNotEmpty && end.isNotEmpty) return '$start  →  $end';
    if (start.isNotEmpty) return 'Từ $start';
    if (end.isNotEmpty) return 'Đến $end';
    return 'Luôn hiển thị';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.adminBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 7,
                child: Container(
                  color: AppColors.neutral100,
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
              Positioned(
                top: 8,
                left: 8,
                child: banner.isActive
                    ? AdminStatusPill.success(
                        'Active',
                        icon: Icons.check_circle_outline_rounded,
                      )
                    : AdminStatusPill.warning(
                        'Tạm tắt',
                        icon: Icons.toggle_off_outlined,
                      ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: AdminStatusPill.neutral(
                  '#${banner.order}',
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _timeRangeText(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (banner.link != null && banner.link!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.link_rounded,
                        size: 12,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          banner.link!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.infoDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _IconAction(
                      icon: Icons.edit_outlined,
                      tooltip: 'Sửa',
                      color: AppColors.primary600,
                      onPressed: onEdit,
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
          ),
        ],
      ),
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
        width: 30,
        height: 30,
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
