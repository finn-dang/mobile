import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';

/// Section title nhỏ phía trên variant chips.
class VariantSectionTitle extends StatelessWidget {
  final String label;
  final String? trailing;

  const VariantSectionTitle({
    super.key,
    required this.label,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: -0.1,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          Text(
            trailing!,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Chip chọn phiên bản – Modern Minimal.
///
/// Active: nền `primary50` + viền cam + chữ cam đậm.
/// Disabled: opacity giảm + label "Hết".
class VersionChip extends StatelessWidget {
  final String version;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback? onTap;

  const VersionChip({
    super.key,
    required this.version,
    required this.isSelected,
    required this.isAvailable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = !isAvailable;
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary50 : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? AppColors.primary500
                : (disabled ? AppColors.neutral200 : AppColors.adminBorder),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              version,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: disabled
                    ? AppColors.neutral400
                    : (isSelected
                        ? AppColors.primary600
                        : AppColors.textPrimary),
                letterSpacing: -0.1,
                decoration: disabled
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: AppColors.neutral400,
              ),
            ),
            if (disabled) ...[
              const SizedBox(width: 6),
              const Text(
                'Hết',
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Option chọn màu – Modern Minimal.
///
/// Hiển thị: vòng tròn màu lớn 28px + tên + (nếu hết) X chéo.
/// Active: outer ring cam.
///
/// Đặt tên `ColorOption` (không phải `ColorSwatch`) để tránh conflict với
/// `ColorSwatch<T>` có sẵn trong `flutter/material.dart`.
class ColorOption extends StatelessWidget {
  final String name;
  final Color color;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback? onTap;

  const ColorOption({
    super.key,
    required this.name,
    required this.color,
    required this.isSelected,
    required this.isAvailable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = !isAvailable;
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Swatch tròn
            Container(
              width: 30,
              height: 30,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary500
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.adminBorder,
                    width: 0.5,
                  ),
                ),
                child: disabled
                    ? const Center(
                        child: Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: disabled
                    ? AppColors.neutral400
                    : (isSelected
                        ? AppColors.primary700
                        : AppColors.textPrimary),
                decoration: disabled
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: AppColors.neutral400,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
