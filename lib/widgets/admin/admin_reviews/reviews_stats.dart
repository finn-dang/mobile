import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/review_model.dart';
import '../common/admin_card.dart';

/// Stats grid cho Reviews – Modern Minimal.
class ReviewsStats extends StatelessWidget {
  final List<ReviewModel> reviews;
  final bool isTablet;

  const ReviewsStats({
    super.key,
    required this.reviews,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final total = reviews.length;
    final avg = reviews.isEmpty
        ? 0.0
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    final replied = reviews.where((r) => r.adminReply != null).length;
    final pending = total - replied;
    final repliedPct = total == 0 ? 0 : ((replied / total) * 100).round();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isTablet ? 2 : 4,
      crossAxisSpacing: AppSpacing.lg,
      mainAxisSpacing: AppSpacing.lg,
      childAspectRatio: isTablet ? 2.4 : 2.0,
      children: [
        AdminStatCard(
          title: 'Tổng đánh giá',
          value: total.toString(),
          icon: Icons.reviews_outlined,
          accent: AppColors.info,
        ),
        AdminStatCard(
          title: 'Điểm trung bình',
          value: avg.toStringAsFixed(1),
          icon: Icons.star_rounded,
          accent: AppColors.warning,
          hint: '/5.0',
          hintFg: AppColors.warningDark,
          hintBg: AppColors.warningContainer,
        ),
        AdminStatCard(
          title: 'Đã phản hồi',
          value: replied.toString(),
          icon: Icons.reply_rounded,
          accent: AppColors.success,
          hint: '$repliedPct%',
          hintFg: AppColors.successDark,
          hintBg: AppColors.successContainer,
        ),
        AdminStatCard(
          title: 'Chờ phản hồi',
          value: pending.toString(),
          icon: Icons.pending_actions_outlined,
          accent: AppColors.primary500,
        ),
      ],
    );
  }
}
