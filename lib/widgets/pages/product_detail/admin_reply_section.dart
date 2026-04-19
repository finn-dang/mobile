import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';

/// Section "Phản hồi từ quản trị viên" – Modern Minimal.
class AdminReplySection extends StatelessWidget {
  final String reply;
  final DateTime replyAt;
  final bool isMobile;
  final String Function(DateTime) formatDate;

  const AdminReplySection({
    super.key,
    required this.reply,
    required this.replyAt,
    required this.isMobile,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.infoContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.infoLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: 14,
                color: AppColors.infoDark,
              ),
              const SizedBox(width: 6),
              Text(
                'Phản hồi từ shop',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.infoDark,
                  letterSpacing: -0.05,
                ),
              ),
              const Spacer(),
              Text(
                formatDate(replyAt),
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            reply,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.infoDark,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
