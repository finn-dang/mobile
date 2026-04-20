// Modern Minimal – Dialog chỉnh sửa đánh giá đã đăng của khách hàng.
// Tái sử dụng AdminDialogShell + ReviewFormBody/ReviewSubmitButton từ
// write_review_dialog.dart. Logic update + service calls được giữ nguyên.

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/review_model.dart';
import '../../../services/image_service.dart';
import '../../../services/review_service.dart';
import '../../admin/common/admin_dialog.dart';
import '../../admin/common/admin_page_header.dart';
import '../../web_safe_network_image.dart';
import 'write_review_dialog.dart';

class EditReviewDialog extends StatefulWidget {
  final ReviewModel review;
  final VoidCallback onReviewUpdated;

  const EditReviewDialog({
    super.key,
    required this.review,
    required this.onReviewUpdated,
  });

  @override
  State<EditReviewDialog> createState() => _EditReviewDialogState();
}

class _EditReviewDialogState extends State<EditReviewDialog> {
  static const int _maxImages = 10;

  final ReviewService _reviewService = ReviewService();
  final ImageService _imageService = ImageService();
  late int _rating;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final List<PlatformFile> _newImages = [];
  List<String> _existingImageUrls = [];
  final List<String> _removedImageUrls = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.review.rating;
    _commentController.text = widget.review.comment;
    _nameController.text = widget.review.userName;
    _existingImageUrls = List.from(widget.review.imageUrls);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  int get _totalImages => _existingImageUrls.length + _newImages.length;

  Future<void> _pickImages() async {
    try {
      final images = await _imageService.pickMultipleImages();
      if (images.isNotEmpty) {
        setState(() {
          final remain = _maxImages - _totalImages;
          _newImages.addAll(images.take(remain));
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

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      final removedUrl = _existingImageUrls.removeAt(index);
      _removedImageUrls.add(removedUrl);
    });
  }

  Future<void> _updateReview() async {
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
          ? widget.review.userName
          : _nameController.text.trim();

      await _reviewService.updateUserReview(
        reviewId: widget.review.id,
        userName: userName,
        rating: _rating,
        comment: _commentController.text.trim(),
        newImageFiles: _newImages.isNotEmpty ? _newImages : null,
        existingImageUrls: _existingImageUrls,
        removedImageUrls:
            _removedImageUrls.isNotEmpty ? _removedImageUrls : null,
      );

      if (mounted) {
        widget.onReviewUpdated();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật đánh giá thành công'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
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
      title: 'Chỉnh sửa đánh giá',
      subtitle: 'Cập nhật nội dung, số sao hoặc hình ảnh đánh giá của bạn',
      icon: Icons.edit_note_rounded,
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
        imagesSection: _EditImagesSection(
          existingImageUrls: _existingImageUrls,
          newImages: _newImages,
          totalImages: _totalImages,
          maxImages: _maxImages,
          isSubmitting: _isSubmitting,
          onPickImages: _pickImages,
          onRemoveExisting: _removeExistingImage,
          onRemoveNew: _removeNewImage,
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
            label: 'Lưu thay đổi',
            icon: Icons.check_rounded,
            isLoading: _isSubmitting,
            onPressed: _updateReview,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Khu vực ảnh cho Edit – kết hợp ảnh cũ (URL) + ảnh mới (PlatformFile).
// ---------------------------------------------------------------------------

class _EditImagesSection extends StatelessWidget {
  final List<String> existingImageUrls;
  final List<PlatformFile> newImages;
  final int totalImages;
  final int maxImages;
  final bool isSubmitting;
  final VoidCallback onPickImages;
  final ValueChanged<int> onRemoveExisting;
  final ValueChanged<int> onRemoveNew;

  const _EditImagesSection({
    required this.existingImageUrls,
    required this.newImages,
    required this.totalImages,
    required this.maxImages,
    required this.isSubmitting,
    required this.onPickImages,
    required this.onRemoveExisting,
    required this.onRemoveNew,
  });

  @override
  Widget build(BuildContext context) {
    if (totalImages == 0) {
      return _Dropzone(
        onTap: isSubmitting ? null : onPickImages,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ...existingImageUrls.asMap().entries.map(
                  (entry) => _ImageThumb(
                    child: WebSafeNetworkImage(
                      imageUrl: entry.value,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary500,
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        size: 24,
                        color: AppColors.neutral400,
                      ),
                    ),
                    onRemove: isSubmitting
                        ? null
                        : () => onRemoveExisting(entry.key),
                  ),
                ),
            ...newImages.asMap().entries.map(
                  (entry) => _ImageThumb(
                    child: _buildLocalPreview(entry.value),
                    onRemove:
                        isSubmitting ? null : () => onRemoveNew(entry.key),
                  ),
                ),
            if (totalImages < maxImages)
              _AddMoreTile(onTap: isSubmitting ? null : onPickImages),
          ],
        ),
        AppSpacing.gapSm,
        Text(
          'Đã có $totalImages / $maxImages hình ảnh',
          style: const TextStyle(
            fontSize: 11.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLocalPreview(PlatformFile file) {
    if (kIsWeb) {
      if (file.bytes == null) {
        return const Icon(Icons.image, size: 24, color: AppColors.neutral400);
      }
      return Image.memory(file.bytes!, fit: BoxFit.cover);
    }
    if (file.path == null) {
      return const Icon(Icons.image, size: 24, color: AppColors.neutral400);
    }
    return Image.file(File(file.path!), fit: BoxFit.cover);
  }
}

// ---------------------------------------------------------------------------
// Thumb 80x80 + nút xóa tròn đen mờ ở góc trên-phải.
// ---------------------------------------------------------------------------

class _ImageThumb extends StatelessWidget {
  final Widget child;
  final VoidCallback? onRemove;

  const _ImageThumb({required this.child, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.adminBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
          if (onRemove != null)
            Positioned(
              top: -6,
              right: -6,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  onTap: onRemove,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.neutral900.withValues(alpha: 0.78),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.2),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddMoreTile extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddMoreTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.primary50,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.primary200,
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.add_photo_alternate_outlined,
          color: AppColors.primary600,
          size: 22,
        ),
      ),
    );
  }
}

class _Dropzone extends StatelessWidget {
  final VoidCallback? onTap;

  const _Dropzone({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: DottedDashContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.primary200),
                ),
                child: const Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 20,
                  color: AppColors.primary600,
                ),
              ),
              AppSpacing.gapSm,
              const Text(
                'Thêm hình ảnh cho đánh giá',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'PNG, JPG – tối đa 10 ảnh',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Container với border dashed nhẹ – mô phỏng dropzone.
class DottedDashContainer extends StatelessWidget {
  final Widget child;

  const DottedDashContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.primary200,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
