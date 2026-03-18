// Modern Minimal – Dialog viết đánh giá sản phẩm cho khách hàng.
// Dùng AdminDialogShell + design tokens (colors/spacing) để đồng bộ với phần
// còn lại của app. Logic submit + service calls được giữ nguyên.

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../services/review_service.dart';
import '../../../services/image_service.dart';
import '../../admin/common/admin_dialog.dart';
import '../../admin/common/admin_page_header.dart';
import 'review_images_picker.dart';

class WriteReviewDialog extends StatefulWidget {
  final String productId;
  final String defaultUserName;
  final VoidCallback onReviewSubmitted;

  const WriteReviewDialog({
    super.key,
    required this.productId,
    required this.defaultUserName,
    required this.onReviewSubmitted,
  });

  @override
  State<WriteReviewDialog> createState() => _WriteReviewDialogState();
}

class _WriteReviewDialogState extends State<WriteReviewDialog> {
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
    return AdminDialogShell(
      title: 'Đánh giá sản phẩm',
      subtitle: 'Chia sẻ trải nghiệm của bạn về sản phẩm này',
      icon: Icons.rate_review_outlined,
      maxWidth: 540,
      onClose: _isSubmitting ? () {} : null,
      body: ReviewFormBody(
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
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AdminSecondaryButton(
            label: 'Hủy',
            onPressed: _isSubmitting
                ? () {}
                : () => Navigator.of(context).pop(),
          ),
          AppSpacing.gapMd,
          ReviewSubmitButton(
            label: 'Gửi đánh giá',
            icon: Icons.send_rounded,
            isLoading: _isSubmitting,
            onPressed: _submitReview,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body chia sẻ giữa Write/Edit dialog và Bottom sheet – Modern Minimal.
// ---------------------------------------------------------------------------

class ReviewFormBody extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onRatingChanged;
  final TextEditingController nameController;
  final TextEditingController commentController;
  final bool isSubmitting;
  final Widget imagesSection;
  final String? nameLabel;

  const ReviewFormBody({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    required this.nameController,
    required this.commentController,
    required this.isSubmitting,
    required this.imagesSection,
    this.nameLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AdminFieldLabel(label: nameLabel ?? 'Tên hiển thị'),
        TextField(
          controller: nameController,
          enabled: !isSubmitting,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textPrimary,
          ),
          decoration: adminInputDecoration(
            hintText: 'Để trống để dùng tên mặc định',
          ),
        ),
        AppSpacing.gapLg,
        const AdminFieldLabel(label: 'Đánh giá của bạn', required: true),
        _StarRating(
          value: rating,
          onChanged: onRatingChanged,
        ),
        AppSpacing.gapLg,
        const AdminFieldLabel(label: 'Nhận xét', required: true),
        TextField(
          controller: commentController,
          enabled: !isSubmitting,
          maxLines: 4,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textPrimary,
            height: 1.45,
          ),
          decoration: adminInputDecoration(
            hintText: 'Chia sẻ trải nghiệm của bạn về sản phẩm...',
          ),
        ),
        AppSpacing.gapLg,
        const AdminFieldLabel(label: 'Hình ảnh'),
        imagesSection,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Star rating – tap để chọn 1-5, active warning, inactive neutral300.
// ---------------------------------------------------------------------------

class _StarRating extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged;

  const _StarRating({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final filled = index < value;
        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.xs),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: onChanged == null ? null : () => onChanged!(index + 1),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.star_rounded,
                size: 36,
                color: filled ? AppColors.warning : AppColors.neutral300,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Submit button cam phẳng + loading state – chia sẻ cho mọi review dialog.
// ---------------------------------------------------------------------------

class ReviewSubmitButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback onPressed;
  final bool fullWidth;

  const ReviewSubmitButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Material(
      color: isLoading ? AppColors.primary300 : AppColors.primary500,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 11,
          ),
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                AppSpacing.gapSm,
              ] else if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.white),
                AppSpacing.gapSm,
              ],
              Text(
                isLoading ? 'Đang gửi...' : label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: child);
    }
    return child;
  }
}
