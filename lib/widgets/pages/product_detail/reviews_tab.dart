import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/review_model.dart';
import '../../../services/review_service.dart';
import 'review_card.dart';

/// Tab "Đánh giá" – Modern Minimal.
///
/// Header tổng quan: avg rating to + breakdown bar 1-5 sao.
/// Body: list ReviewCard.
class ReviewsTab extends StatefulWidget {
  final bool isMobile;
  final String productId;

  const ReviewsTab({
    super.key,
    required this.isMobile,
    required this.productId,
  });

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  final ReviewService _reviewService = ReviewService();

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) return 'Vừa xong';
        return '${diff.inMinutes} phút trước';
      }
      return '${diff.inHours} giờ trước';
    }
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} tuần trước';
    }
    if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()} tháng trước';
    }
    return '${(diff.inDays / 365).floor()} năm trước';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ReviewModel>>(
      stream: _reviewService.getReviews(widget.productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary500,
                ),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xl3),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(AppRadius.xl2),
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      size: 26,
                      color: AppColors.errorDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Không thể tải đánh giá',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final reviews = snapshot.data ?? const <ReviewModel>[];
        return SingleChildScrollView(
          padding:
              EdgeInsets.all(widget.isMobile ? AppSpacing.md : AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reviews.isNotEmpty) ...[
                _RatingSummary(reviews: reviews, isMobile: widget.isMobile),
                AppSpacing.gapLg,
              ],
              if (reviews.isEmpty)
                _EmptyState()
              else
                Column(
                  children: [
                    for (final r in reviews)
                      ReviewCard(
                        review: r,
                        isMobile: widget.isMobile,
                        formatDate: _formatDate,
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RatingSummary extends StatelessWidget {
  final List<ReviewModel> reviews;
  final bool isMobile;

  const _RatingSummary({required this.reviews, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final total = reviews.length;
    final avg = total == 0
        ? 0.0
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / total;

    final breakdown = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final r in reviews) {
      breakdown[r.rating] = (breakdown[r.rating] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.primary100),
      ),
      child: isMobile
          ? Column(
              children: [
                _AverageBlock(avg: avg, total: total),
                AppSpacing.gapMd,
                _BreakdownBars(breakdown: breakdown, total: total),
              ],
            )
          : Row(
              children: [
                Expanded(child: _AverageBlock(avg: avg, total: total)),
                AppSpacing.gapXl,
                Expanded(
                  flex: 2,
                  child: _BreakdownBars(
                    breakdown: breakdown,
                    total: total,
                  ),
                ),
              ],
            ),
    );
  }
}

class _AverageBlock extends StatelessWidget {
  final double avg;
  final int total;

  const _AverageBlock({required this.avg, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          avg.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: AppColors.primary600,
            height: 1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 5; i++)
              Icon(
                i < avg.floor()
                    ? Icons.star_rounded
                    : (i < avg
                        ? Icons.star_half_rounded
                        : Icons.star_outline_rounded),
                size: 18,
                color: i < avg ? AppColors.warning : AppColors.neutral300,
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '$total đánh giá',
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _BreakdownBars extends StatelessWidget {
  final Map<int, int> breakdown;
  final int total;

  const _BreakdownBars({required this.breakdown, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var s = 5; s >= 1; s--)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Text(
                  '$s',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.star_rounded,
                  size: 12,
                  color: AppColors.warning,
                ),
                AppSpacing.gapSm,
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: total == 0
                          ? 0
                          : (breakdown[s] ?? 0) / total,
                      minHeight: 6,
                      backgroundColor: AppColors.neutral100,
                      color: AppColors.warning,
                    ),
                  ),
                ),
                AppSpacing.gapSm,
                SizedBox(
                  width: 28,
                  child: Text(
                    '${breakdown[s] ?? 0}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl3),
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
            child: const Icon(
              Icons.reviews_outlined,
              size: 24,
              color: AppColors.neutral400,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Chưa có đánh giá nào',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Trở thành người đầu tiên đánh giá sản phẩm này.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
