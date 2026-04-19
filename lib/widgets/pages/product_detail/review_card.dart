import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/review_model.dart';
import 'admin_reply_section.dart';
import 'review_images_section.dart';

/// Card 1 đánh giá – Modern Minimal.
class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool isMobile;
  final String Function(DateTime) formatDate;

  const ReviewCard({
    super.key,
    required this.review,
    required this.isMobile,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(name: review.userName),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        for (var i = 0; i < 5; i++)
                          Icon(
                            i < review.rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 14,
                            color: i < review.rating
                                ? AppColors.warning
                                : AppColors.neutral300,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          formatDate(review.createdAt),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          if (review.imageUrls.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            ReviewImagesSection(
              imageUrls: review.imageUrls,
              isMobile: isMobile,
            ),
          ],
          if (review.adminReply != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AdminReplySection(
              reply: review.adminReply!,
              replyAt: review.adminReplyAt!,
              isMobile: isMobile,
              formatDate: formatDate,
            ),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: AppColors.primary600,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
