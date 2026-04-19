import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';

/// Tab "Mô tả" – Modern Minimal.
class DescriptionTab extends StatelessWidget {
  final bool isMobile;
  final String? description;

  const DescriptionTab({
    super.key,
    required this.isMobile,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final hasDescription = description != null && description!.trim().isNotEmpty;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.lg),
      child: hasDescription
          ? Text(
              description!,
              style: TextStyle(
                fontSize: isMobile ? 13.5 : 14,
                color: AppColors.textPrimary,
                height: 1.7,
              ),
            )
          : const _EmptyState(
              icon: Icons.description_outlined,
              message: 'Chưa có mô tả cho sản phẩm này.',
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
