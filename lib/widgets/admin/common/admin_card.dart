import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/spacing.dart';

/// Card chuẩn cho admin – Modern Minimal.
///
/// Phẳng, không shadow đậm, chỉ border 1px + radius lớn.
class AdminCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? radius;
  final BorderSide? borderOverride;

  const AdminCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.radius,
    this.borderOverride,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius ?? AppRadius.xl),
        border: borderOverride != null
            ? Border.fromBorderSide(borderOverride!)
            : Border.all(color: AppColors.adminBorder, width: 1),
      ),
      child: child,
    );
  }
}

/// Stat card – Modern Minimal:
/// • icon container nhỏ 36×36 cùng accent màu
/// • title nhỏ ở trên, giá trị to + badge phụ ở dưới
/// • border 1px, không shadow
class AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final String? hint;
  final Color? hintFg;
  final Color? hintBg;

  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    this.hint,
    this.hintFg,
    this.hintBg,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              AppSpacing.gapMd,
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.6,
                    height: 1.1,
                  ),
                ),
              ),
              if (hint != null) ...[
                AppSpacing.gapSm,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: hintBg ?? AppColors.neutral100,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    hint!,
                    style: TextStyle(
                      color: hintFg ?? AppColors.neutral600,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Tiêu đề con trong một AdminCard – Modern Minimal.
///
/// Dùng cho "Thông tin cơ bản", "Mô tả sản phẩm", "Phiên bản"...
/// Không to như page heading, không bold đậm – chỉ 14-15px w600.
class AdminSectionTitle extends StatelessWidget {
  final String title;
  final String? description;
  final IconData? icon;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const AdminSectionTitle({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.primary600),
            AppSpacing.gapSm,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                    height: 1.25,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Banner thông báo inline (success/warning/info/error) – Modern Minimal.
///
/// Tone nhạt + border 1px cùng tone đậm hơn, KHÔNG dùng `withOpacity`.
class AdminInlineNotice extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color fg;
  final Color bg;
  final Color border;
  final Widget? trailing;

  const AdminInlineNotice({
    super.key,
    required this.message,
    required this.icon,
    required this.fg,
    required this.bg,
    required this.border,
    this.trailing,
  });

  factory AdminInlineNotice.success(
    String message, {
    IconData icon = Icons.check_circle_outline_rounded,
    Widget? trailing,
  }) =>
      AdminInlineNotice(
        message: message,
        icon: icon,
        fg: AppColors.successDark,
        bg: AppColors.successContainer,
        border: AppColors.successLight,
        trailing: trailing,
      );

  factory AdminInlineNotice.warning(
    String message, {
    IconData icon = Icons.info_outline_rounded,
    Widget? trailing,
  }) =>
      AdminInlineNotice(
        message: message,
        icon: icon,
        fg: AppColors.warningDark,
        bg: AppColors.warningContainer,
        border: AppColors.warningLight,
        trailing: trailing,
      );

  factory AdminInlineNotice.info(
    String message, {
    IconData icon = Icons.info_outline_rounded,
    Widget? trailing,
  }) =>
      AdminInlineNotice(
        message: message,
        icon: icon,
        fg: AppColors.infoDark,
        bg: AppColors.infoContainer,
        border: AppColors.infoLight,
        trailing: trailing,
      );

  factory AdminInlineNotice.danger(
    String message, {
    IconData icon = Icons.error_outline_rounded,
    Widget? trailing,
  }) =>
      AdminInlineNotice(
        message: message,
        icon: icon,
        fg: AppColors.errorDark,
        bg: AppColors.errorContainer,
        border: AppColors.errorLight,
        trailing: trailing,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: fg),
          AppSpacing.gapSm,
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                color: fg,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (trailing != null) ...[
            AppSpacing.gapSm,
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Pill trạng thái dùng chung cho status cell, badges...
class AdminStatusPill extends StatelessWidget {
  final String label;
  final Color fg;
  final Color bg;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  const AdminStatusPill({
    super.key,
    required this.label,
    required this.fg,
    required this.bg,
    this.icon,
    this.padding,
  });

  /// Preset cho trạng thái "tích cực" (success/in stock/...)
  factory AdminStatusPill.success(String label, {IconData? icon}) =>
      AdminStatusPill(
        label: label,
        fg: AppColors.successDark,
        bg: AppColors.successContainer,
        icon: icon,
      );

  /// Preset cho trạng thái "lỗi/hết hàng"
  factory AdminStatusPill.danger(String label, {IconData? icon}) =>
      AdminStatusPill(
        label: label,
        fg: AppColors.errorDark,
        bg: AppColors.errorContainer,
        icon: icon,
      );

  /// Preset cho trạng thái "chờ/cảnh báo"
  factory AdminStatusPill.warning(String label, {IconData? icon}) =>
      AdminStatusPill(
        label: label,
        fg: AppColors.warningDark,
        bg: AppColors.warningContainer,
        icon: icon,
      );

  /// Preset cho neutral/info
  factory AdminStatusPill.info(String label, {IconData? icon}) =>
      AdminStatusPill(
        label: label,
        fg: AppColors.infoDark,
        bg: AppColors.infoContainer,
        icon: icon,
      );

  /// Preset trung tính
  factory AdminStatusPill.neutral(String label, {IconData? icon}) =>
      AdminStatusPill(
        label: label,
        fg: AppColors.neutral600,
        bg: AppColors.neutral100,
        icon: icon,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 3,
          ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.05,
            ),
          ),
        ],
      ),
    );
  }
}
