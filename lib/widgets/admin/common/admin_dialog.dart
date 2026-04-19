import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';

/// Vỏ Dialog chuẩn cho admin – Modern Minimal.
///
/// Bố cục: header (icon + title + subtitle + close) → divider → body scroll
/// → divider → footer (action buttons).
class AdminDialogShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconBg;
  final Color? iconFg;
  final Widget body;
  final Widget? footer;
  final double maxWidth;
  final bool showClose;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry? bodyPadding;

  const AdminDialogShell({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.icon,
    this.iconBg,
    this.iconFg,
    this.footer,
    this.maxWidth = 520,
    this.showClose = true,
    this.onClose,
    this.bodyPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl2),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(
              title: title,
              subtitle: subtitle,
              icon: icon,
              iconBg: iconBg,
              iconFg: iconFg,
              showClose: showClose,
              onClose: onClose ?? () => Navigator.of(context).pop(),
            ),
            const Divider(height: 1, color: AppColors.adminBorder),
            Flexible(
              child: SingleChildScrollView(
                padding: bodyPadding ??
                    const EdgeInsets.all(AppSpacing.xl),
                child: body,
              ),
            ),
            if (footer != null) ...[
              const Divider(height: 1, color: AppColors.adminBorder),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                child: footer!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconBg;
  final Color? iconFg;
  final bool showClose;
  final VoidCallback onClose;

  const _Header({
    required this.title,
    required this.onClose,
    this.subtitle,
    this.icon,
    this.iconBg,
    this.iconFg,
    this.showClose = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg ?? AppColors.primary50,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconFg ?? AppColors.primary600,
              ),
            ),
            AppSpacing.gapMd,
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                    height: 1.25,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
          if (showClose)
            IconButton(
              tooltip: 'Đóng',
              icon: const Icon(
                Icons.close_rounded,
                size: 20,
                color: AppColors.neutral500,
              ),
              onPressed: onClose,
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Field shortcuts dùng chung trong dialog – đồng nhất với form sản phẩm
// ---------------------------------------------------------------------------

/// Label nhỏ phía trên field – có thể đánh dấu required (*).
class AdminFieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  final EdgeInsetsGeometry padding;

  const AdminFieldLabel({
    super.key,
    required this.label,
    this.required = false,
    this.padding = const EdgeInsets.only(bottom: 6),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (required) ...[
            const SizedBox(width: 3),
            const Text(
              '*',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Border helper – tone Modern Minimal.
OutlineInputBorder adminFieldBorder(Color color, {double width = 1}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: BorderSide(color: color, width: width),
  );
}

/// Decoration sẵn cho input chuẩn.
InputDecoration adminInputDecoration({
  String? hintText,
  String? helperText,
  Widget? prefixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      fontSize: 13.5,
      color: AppColors.neutral400,
    ),
    helperText: helperText,
    helperStyle: const TextStyle(
      fontSize: 11.5,
      color: AppColors.textSecondary,
    ),
    isDense: true,
    filled: true,
    fillColor: AppColors.surface,
    prefixIcon: prefixIcon,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 11,
    ),
    border: adminFieldBorder(AppColors.adminBorder),
    enabledBorder: adminFieldBorder(AppColors.adminBorder),
    focusedBorder: adminFieldBorder(AppColors.primary500, width: 1.5),
    errorBorder: adminFieldBorder(AppColors.error),
    focusedErrorBorder: adminFieldBorder(AppColors.error, width: 1.5),
    errorStyle: const TextStyle(fontSize: 11.5, height: 1.2),
  );
}
