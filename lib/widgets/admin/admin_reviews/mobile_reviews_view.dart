import 'package:flutter/material.dart';
import '../../../models/review_model.dart';
import 'review_detail_dialog.dart';
import 'reviews_search_and_filter_bar.dart';

class MobileReviewsView extends StatelessWidget {
  final List<ReviewModel> reviews;
  final TextEditingController searchController;
  final int? selectedRating;
  final bool? hasReply;
  final ValueChanged<int?> onRatingChanged;
  final ValueChanged<bool?> onReplyChanged;
  final VoidCallback onClearFilters;
  final Function(int, bool) onSort;
  final int sortColumnIndex;
  final bool sortAscending;
  final String Function(DateTime) formatDate;

  const MobileReviewsView({
    super.key,
    required this.reviews,
    required this.searchController,
    required this.selectedRating,
    required this.hasReply,
    required this.onRatingChanged,
    required this.onReplyChanged,
    required this.onClearFilters,
    required this.onSort,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quản lý đánh giá',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
          ),
          const SizedBox(height: 16),
          // Search and Filter
          ReviewsSearchAndFilterBar(
            searchController: searchController,
            selectedRating: selectedRating,
            hasReply: hasReply,
            onRatingChanged: onRatingChanged,
            onReplyChanged: onReplyChanged,
            onClearFilters: onClearFilters,
            isTablet: false,
          ),
          const SizedBox(height: 16),
          // Mobile list view
          ...reviews.map((review) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            review.userName.isNotEmpty
                                ? review.userName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  ...List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < review.rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 14,
                                      color: Colors.amber,
                                    );
                                  }),
                                  const SizedBox(width: 8),
                                  Text(
                                    formatDate(review.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mã SP: ${review.productId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.comment,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (review.imageUrls.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.image, size: 16, color: Colors.blue[700]),
                          const SizedBox(width: 4),
                          Text(
                            '${review.imageUrls.length} hình ảnh',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (review.adminReply != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                            const SizedBox(width: 4),
                            Text(
                              'Đã phản hồi',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('Xem chi tiết'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => ReviewDetailDialog(review: review),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

