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
