import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/review_model.dart';
import '../../../models/product_model.dart';
import '../../../services/review_service.dart';
import '../../../services/product_service.dart';
import 'reply_review_dialog.dart';
import 'product_info_section.dart';

class ReviewDetailDialog extends StatefulWidget {
  final ReviewModel review;

  const ReviewDetailDialog({
    super.key,
    required this.review,
  });

  @override
  State<ReviewDetailDialog> createState() => _ReviewDetailDialogState();
}

class _ReviewDetailDialogState extends State<ReviewDetailDialog> {
  late ReviewModel _review;
  final ReviewService _reviewService = ReviewService();
  final ProductService _productService = ProductService();
  ProductModel? _product;
  bool _isLoadingProduct = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _review = widget.review;
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final product = await _productService.getProductById(_review.productId);
      if (mounted) {
        setState(() {
          _product = product;
          _isLoadingProduct = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProduct = false;
        });
      }
    }
  }

  Future<void> _handleReply() async {
    final reply = await showDialog<String>(
      context: context,
      builder: (context) => ReplyReviewDialog(
        reviewId: _review.id,
        existingReply: _review.adminReply,
      ),
    );

    if (reply == null) return; // User cancelled

    try {
      await _reviewService.updateAdminReply(_review.id, reply);
      
      // Refresh review data
      final updatedReview = await _reviewService.getReviewById(_review.id);
      if (updatedReview != null && mounted) {
        setState(() {
          _review = updatedReview;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật phản hồi thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteReply() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa phản hồi'),
        content: const Text('Bạn có chắc chắn muốn xóa phản hồi này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _reviewService.deleteAdminReply(_review.id);
      
      // Refresh review data
      final updatedReview = await _reviewService.getReviewById(_review.id);
      if (updatedReview != null && mounted) {
        setState(() {
          _review = updatedReview;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa phản hồi thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteReview() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa đánh giá'),
        content: const Text('Bạn có chắc chắn muốn xóa đánh giá này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await _reviewService.deleteReview(_review.id);
      
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate deletion
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa đánh giá thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Dialog(
      insetPadding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 700,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Chi tiết đánh giá',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: isMobile ? 24 : 30,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            _review.userName.isNotEmpty
                                ? _review.userName[0].toUpperCase()
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
                                _review.userName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  ...List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < _review.rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 18,
                                      color: Colors.amber,
                                    );
                                  }),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatDate(_review.createdAt),
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
                    const SizedBox(height: 16),
                    // Product Info
                    Text(
                      'Thông tin sản phẩm',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoadingProduct)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_product == null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, size: 16, color: Colors.red[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Không tìm thấy sản phẩm',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[700],
                                ),
                              ),
                            ),
                            Text(
                              _review.productId,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ProductInfoSection(
                        product: _product!,
                        isMobile: isMobile,
                      ),
                    const SizedBox(height: 16),
                    // Comment
                    Text(
                      'Nội dung đánh giá',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _review.comment,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                    // Images
                    if (_review.imageUrls.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Hình ảnh (${_review.imageUrls.length})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _review.imageUrls.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                // Show full screen image
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: CachedNetworkImage(
                                            imageUrl: _review.imageUrls[index],
                                            fit: BoxFit.contain,
                                            placeholder: (context, url) => const Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                            errorWidget: (context, url, error) => const Icon(
                                              Icons.image_not_supported,
                                              size: 64,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: IconButton(
                                            icon: const Icon(Icons.close, color: Colors.white),
                                            onPressed: () => Navigator.of(context).pop(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: _review.imageUrls[index],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(strokeWidth: 1),
                                    ),
                                    errorWidget: (context, url, error) => const Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    // Admin reply
                    if (_review.adminReply != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.admin_panel_settings, size: 16, color: Colors.blue[700]),
                                const SizedBox(width: 6),
                                Text(
                                  'Phản hồi từ quản trị viên',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[700],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _review.adminReplyAt != null
                                      ? _formatDate(_review.adminReplyAt!)
                                      : '',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _review.adminReply!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[900],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_review.adminReply == null)
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              icon: const Icon(Icons.reply),
                              label: const Text('Phản hồi'),
                              onPressed: _isDeleting ? null : _handleReply,
                            ),
                          )
                        else ...[
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              icon: const Icon(Icons.edit),
                              label: const Text('Sửa phản hồi'),
                              onPressed: _isDeleting ? null : _handleReply,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Xóa phản hồi'),
                              style: TextButton.styleFrom(foregroundColor: Colors.orange),
                              onPressed: _isDeleting ? null : _handleDeleteReply,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            icon: _isDeleting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.delete),
                            label: const Text('Xóa đánh giá'),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            onPressed: _isDeleting ? null : _handleDeleteReview,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_review.adminReply == null)
                          TextButton.icon(
                            icon: const Icon(Icons.reply),
                            label: const Text('Phản hồi'),
                            onPressed: _isDeleting ? null : _handleReply,
                          )
                        else ...[
                          TextButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Sửa phản hồi'),
                            onPressed: _isDeleting ? null : _handleReply,
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Xóa phản hồi'),
                            style: TextButton.styleFrom(foregroundColor: Colors.orange),
                            onPressed: _isDeleting ? null : _handleDeleteReply,
                          ),
                        ],
                        const SizedBox(width: 8),
                        TextButton.icon(
                          icon: _isDeleting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.delete),
                          label: const Text('Xóa đánh giá'),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          onPressed: _isDeleting ? null : _handleDeleteReview,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

