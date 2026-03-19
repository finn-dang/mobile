import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';

/// Tab "Thông số kỹ thuật" – Modern Minimal.
///
/// Hiển thị dạng table 2 cột (label / value) với divider mảnh.
class SpecificationsTab extends StatelessWidget {
  final bool isMobile;
  final List<Map<String, String>>? specifications;

  const SpecificationsTab({
    super.key,
    required this.isMobile,
    this.specifications,
  });

  @override
  Widget build(BuildContext context) {
    final specs = specifications ?? const <Map<String, String>>[];
    if (specs.isEmpty) {
      return _EmptyState(
        icon: Icons.list_alt_rounded,
        message: 'Chưa có thông số kỹ thuật.',
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.adminBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < specs.length; i++) ...[
              if (i > 0)
                const Divider(height: 1, color: AppColors.neutral100),
              _SpecRow(
                label: specs[i]['label'] ?? '',
                value: specs[i]['value'] ?? '',
                isMobile: isMobile,
                isAlt: i.isOdd,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMobile;
  final bool isAlt;

  const _SpecRow({
    required this.label,
    required this.value,
    required this.isMobile,
    required this.isAlt,
  });

  @override
  Widget build(BuildContext context) {
    final labelText = Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.05,
      ),
    );
    final valueText = Text(
      value,
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );

    return Container(
      color: isAlt ? AppColors.surfaceMuted : AppColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.md : AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                labelText,
                const SizedBox(height: 4),
                valueText,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 200, child: labelText),
                AppSpacing.gapMd,
                Expanded(child: valueText),
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.xl2),
            ),
            child: Icon(icon, size: 24, color: AppColors.neutral400),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
