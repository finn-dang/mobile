import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../common/admin_page_header.dart';

/// Nhóm nút hành động cuối form (Hủy + Lưu) – Modern Minimal.
///
/// Khi đang loading sẽ hiển thị spinner trong nút Lưu.
class ActionButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final bool isMobile;
  final String submitLabel;

  const ActionButtons({
    super.key,
    required this.isLoading,
    required this.onSubmit,
    required this.onCancel,
    required this.isMobile,
    this.submitLabel = 'Lưu',
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: _PrimarySubmitButton(
              isLoading: isLoading,
              label: submitLabel,
              onPressed: onSubmit,
            ),
          ),
          AppSpacing.gapSm,
          SizedBox(
            width: double.infinity,
            child: AdminSecondaryButton(
              icon: Icons.close_rounded,
              label: 'Hủy',
              onPressed: isLoading ? () {} : onCancel,
            ),
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AdminSecondaryButton(
          label: 'Hủy',
          onPressed: isLoading ? () {} : onCancel,
        ),
        AppSpacing.gapMd,
        _PrimarySubmitButton(
          isLoading: isLoading,
          label: submitLabel,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

class _PrimarySubmitButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final VoidCallback onPressed;

  const _PrimarySubmitButton({
    required this.isLoading,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isLoading ? AppColors.primary300 : AppColors.primary500,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                AppSpacing.gapSm,
              ] else ...[
                const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                AppSpacing.gapSm,
              ],
              Text(
                isLoading ? 'Đang lưu...' : label,
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
