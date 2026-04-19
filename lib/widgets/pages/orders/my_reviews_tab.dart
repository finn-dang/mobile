import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../models/review_model.dart';
import '../../web_safe_network_image.dart';
import '../../../services/review_service.dart';
import '../../../services/product_service.dart';
import '../../../models/product_model.dart';
import '../../../config/colors.dart';
import '../product_detail/review_images_section.dart';
import '../product_detail/admin_reply_section.dart';
import '../product_detail/edit_review_dialog.dart';

class MyReviewsTab extends StatefulWidget {
  const MyReviewsTab({super.key});

  @override
  State<MyReviewsTab> createState() => _MyReviewsTabState();
}

class _MyReviewsTabState extends State<MyReviewsTab> {

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} tuần trước';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else {
      return '${(difference.inDays / 365).floor()} năm trước';
    }
  }

  final ReviewService _reviewService = ReviewService();

  Future<void> _handleEditReview(ReviewModel review) async {
    await showDialog(
      context: context,
      builder: (context) => EditReviewDialog(
        review: review,
        onReviewUpdated: () {
          // Refresh will happen automatically via StreamBuilder
        },
      ),
    );
  }

  Future<void> _handleDeleteReview(ReviewModel review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa đánh giá này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _reviewService.deleteUserReview(review.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa đánh giá thành công'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final productService = ProductService();

    return StreamBuilder<List<ReviewModel>>(
      stream: _reviewService.getUserReviews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  'Lỗi khi tải đánh giá',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final reviews = snapshot.data ?? [];

        if (reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.rate_review_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Bạn chưa có đánh giá nào',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Các đánh giá của bạn sẽ hiển thị ở đây',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.rate_review,
                      color: AppColors.primary, size: isMobile ? 20 : 24),
                  const SizedBox(width: 8),
                  Text(
                    'Đánh giá của tôi (${reviews.length})',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ...reviews.map((review) {
                return FutureBuilder<ProductModel?>(
                  future: productService.getProductById(review.productId),
                  builder: (context, productSnapshot) {
                    final product = productSnapshot.data;
                    return _buildReviewCard(
                      context,
                      review,
                      product,
                      isMobile,
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewCard(
    BuildContext context,
    ReviewModel review,
    ProductModel? product,
    bool isMobile,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _handleEditReview(review),
                  tooltip: 'Chỉnh sửa',
                  color: AppColors.primary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _handleDeleteReview(review),
                  tooltip: 'Xóa',
                  color: Colors.red,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Product Info
            if (product != null) ...[
              InkWell(
                  onTap: () => context.go('/products/${product.id}'),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      // Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: WebSafeNetworkImage(
                          imageUrl: product.imageUrl ?? '',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Xem sản phẩm →',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const Divider(height: 32),
            ],
            // User info and rating
            Row(
              children: [
                CircleAvatar(
                  radius: isMobile ? 20 : 24,
                  backgroundColor: AppColors.primary,
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
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < review.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              size: isMobile ? 16 : 18,
                              color: Colors.amber,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(review.createdAt),
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
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
            const SizedBox(height: 16),
            // Comment
            Text(
              review.comment,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            // Review images
            if (review.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 16),
              ReviewImagesSection(
                imageUrls: review.imageUrls,
                isMobile: isMobile,
              ),
            ],
            // Admin reply
            if (review.adminReply != null) ...[
              const SizedBox(height: 16),
              AdminReplySection(
                reply: review.adminReply!,
                replyAt: review.adminReplyAt!,
                isMobile: isMobile,
                formatDate: _formatDate,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

