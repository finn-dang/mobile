// Modern Minimal – Bottom sheet viết đánh giá sản phẩm trên mobile.
// Dùng DraggableScrollableSheet với handle + header + body scroll +
// footer sticky. Logic submit + service calls được giữ nguyên.

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../services/review_service.dart';
import '../../../services/image_service.dart';
import 'review_images_picker.dart';
import 'write_review_dialog.dart';

class WriteReviewBottomSheet extends StatefulWidget {
  final String productId;
  final String defaultUserName;
  final VoidCallback onReviewSubmitted;

  const WriteReviewBottomSheet({
    super.key,
    required this.productId,
    required this.defaultUserName,
    required this.onReviewSubmitted,
  });

  @override
  State<WriteReviewBottomSheet> createState() =>
      _WriteReviewBottomSheetState();
}

class _WriteReviewBottomSheetState extends State<WriteReviewBottomSheet> {
  final ReviewService _reviewService = ReviewService();
  final ImageService _imageService = ImageService();
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final List<PlatformFile> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.defaultUserName;
  }

  @override
  void dispose() {
    _commentController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final images = await _imageService.pickMultipleImages();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn số sao đánh giá'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung đánh giá'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userName = _nameController.text.trim().isEmpty
          ? widget.defaultUserName
          : _nameController.text.trim();

      await _reviewService.createReview(
        productId: widget.productId,
        userName: userName,
        rating: _rating,
        comment: _commentController.text.trim(),
        imageFiles: _selectedImages.isNotEmpty ? _selectedImages : null,
      );

      if (mounted) {
        widget.onReviewSubmitted();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl2),
            ),
          ),
          child: Column(
            children: [
              _SheetHeader(
                onClose: _isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
              ),
              const Divider(height: 1, color: AppColors.adminBorder),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: ReviewFormBody(
                    rating: _rating,
                    onRatingChanged: _isSubmitting
                        ? null
                        : (value) => setState(() => _rating = value),
                    nameController: _nameController,
                    commentController: _commentController,
                    isSubmitting: _isSubmitting,
                    imagesSection: ReviewImagesPicker(
                      selectedImages: _selectedImages,
                      onPickImages: _pickImages,
                      onRemoveImage: _removeImage,
                      isSubmitting: _isSubmitting,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.adminBorder),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.xl,
                    AppSpacing.md,
                  ),
                  child: ReviewSubmitButton(
                    label: 'Gửi đánh giá',
                    icon: Icons.send_rounded,
                    isLoading: _isSubmitting,
                    onPressed: _submitReview,
                    fullWidth: true,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Header bottom sheet: drag handle 40x4 + tiêu đề + close.
// ---------------------------------------------------------------------------

class _SheetHeader extends StatelessWidget {
  final VoidCallback? onClose;

  const _SheetHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.neutral200,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.rate_review_outlined,
                  size: 18,
                  color: AppColors.primary600,
                ),
              ),
              AppSpacing.gapMd,
              const Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đánh giá sản phẩm',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Chia sẻ trải nghiệm của bạn',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Đóng',
                icon: const Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: AppColors.neutral500,
                ),
                onPressed: onClose,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
