import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/category_model.dart';
import '../../../services/image_service.dart';
import '../common/admin_card.dart';
import '../common/admin_dialog.dart';
import '../common/admin_page_header.dart';

/// Tạo danh mục mới – Modern Minimal.
class CreateCategoryDialog extends StatefulWidget {
  final List<CategoryModel> allCategories;
  final Function(CategoryModel) onCreate;

  const CreateCategoryDialog({
    super.key,
    required this.allCategories,
    required this.onCreate,
  });

  @override
  State<CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<CreateCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageService = ImageService();

  String? _selectedStatus = 'Hiển thị';
  String? _selectedParentId;
  PlatformFile? _selectedImageFile;
  bool _isUploading = false;

  List<CategoryModel> get _parentCategories =>
      widget.allCategories.where((c) => c.parentId == null).toList();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final file = await _imageService.pickImage();
      if (file != null) {
        setState(() => _selectedImageFile = file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn hình ảnh cho danh mục'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      final imageUrl =
          await _imageService.uploadCategoryImage(_selectedImageFile!);
      final now = DateTime.now();
      final newCategory = CategoryModel(
        id: '',
        name: _nameController.text.trim(),
        imageUrl: imageUrl,
        parentId: _selectedParentId,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        productCount: 0,
        status: _selectedStatus!,
        createdAt: now,
        updatedAt: now,
      );

      widget.onCreate(newCategory);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminDialogShell(
      title: 'Thêm danh mục mới',
      subtitle: 'Tạo danh mục để nhóm sản phẩm thời trang theo phong cách hoặc đối tượng.',
      icon: Icons.create_new_folder_outlined,
      maxWidth: 540,
      onClose: _isUploading ? () {} : null,
      body: Form(
        key: _formKey,
        child: _CategoryFormFields(
          nameController: _nameController,
          descriptionController: _descriptionController,
          selectedStatus: _selectedStatus,
          selectedParentId: _selectedParentId,
          parentOptions: _parentCategories,
          selectedImageFile: _selectedImageFile,
          existingImageUrl: null,
          isUploading: _isUploading,
          onPickImage: _pickImage,
          onClearImage: () => setState(() => _selectedImageFile = null),
          onParentChanged: (v) => setState(() => _selectedParentId = v),
          onStatusChanged: (v) => setState(() => _selectedStatus = v),
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AdminSecondaryButton(
            label: 'Hủy',
            onPressed:
                _isUploading ? () {} : () => Navigator.of(context).pop(),
          ),
          AppSpacing.gapMd,
          _SubmitButton(
            label: 'Tạo danh mục',
            isLoading: _isUploading,
            onPressed: _handleCreate,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Form fields chia sẻ giữa Create và Edit
// ---------------------------------------------------------------------------

class _CategoryFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final String? selectedStatus;
  final String? selectedParentId;
  final List<CategoryModel> parentOptions;
  final PlatformFile? selectedImageFile;
  final String? existingImageUrl;
  final bool isUploading;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;
  final ValueChanged<String?> onParentChanged;
  final ValueChanged<String?> onStatusChanged;

  const _CategoryFormFields({
    required this.nameController,
    required this.descriptionController,
    required this.selectedStatus,
    required this.selectedParentId,
    required this.parentOptions,
    required this.selectedImageFile,
    required this.existingImageUrl,
    required this.isUploading,
    required this.onPickImage,
    required this.onClearImage,
    required this.onParentChanged,
    required this.onStatusChanged,
  });

  bool get _hasImage =>
      selectedImageFile != null || existingImageUrl != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const AdminFieldLabel(label: 'Hình ảnh danh mục', required: true),
        _ImagePicker(
          selectedImageFile: selectedImageFile,
          existingImageUrl: existingImageUrl,
          isUploading: isUploading,
          onTap: isUploading ? null : onPickImage,
          onRemove: isUploading || !_hasImage ? null : onClearImage,
        ),
        AppSpacing.gapMd,
        const AdminFieldLabel(label: 'Tên danh mục', required: true),
        TextFormField(
          controller: nameController,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textPrimary,
          ),
          decoration: adminInputDecoration(
            hintText: 'Ví dụ: Áo nữ, Quần nam, Váy dự tiệc...',
          ),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Vui lòng nhập tên danh mục' : null,
        ),
        AppSpacing.gapMd,
        const AdminFieldLabel(label: 'Mô tả'),
        TextFormField(
          controller: descriptionController,
          maxLines: 3,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
          decoration: adminInputDecoration(
            hintText: 'Mô tả ngắn về phong cách hoặc loại trang phục trong danh mục...',
          ),
        ),
        AppSpacing.gapMd,
        const AdminFieldLabel(label: 'Danh mục cha'),
        DropdownButtonFormField<String?>(
          value: selectedParentId,
          isExpanded: true,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textPrimary,
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppColors.neutral500,
          ),
          decoration: adminInputDecoration(
            hintText: 'Chọn danh mục cha hoặc để trống',
            helperText: 'Để trống nếu đây là danh mục cấp 1.',
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Không có (Danh mục cấp 1)'),
            ),
            ...parentOptions.map(
              (p) => DropdownMenuItem<String?>(
                value: p.id,
                child: Text(p.name, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          onChanged: onParentChanged,
        ),
        AppSpacing.gapMd,
        const AdminFieldLabel(label: 'Trạng thái', required: true),
        DropdownButtonFormField<String>(
          value: selectedStatus,
          isExpanded: true,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textPrimary,
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppColors.neutral500,
          ),
          decoration: adminInputDecoration(),
          items: const [
            DropdownMenuItem(
              value: 'Hiển thị',
              child: Text('Hiển thị'),
            ),
            DropdownMenuItem(
              value: 'Ẩn',
              child: Text('Đang ẩn'),
            ),
          ],
          onChanged: onStatusChanged,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Vui lòng chọn trạng thái' : null,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Image picker
// ---------------------------------------------------------------------------

class _ImagePicker extends StatelessWidget {
  final PlatformFile? selectedImageFile;
  final String? existingImageUrl;
  final bool isUploading;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const _ImagePicker({
    required this.selectedImageFile,
    required this.existingImageUrl,
    required this.isUploading,
    required this.onTap,
    required this.onRemove,
  });

  bool get _hasImage =>
      selectedImageFile != null || existingImageUrl != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            width: double.infinity,
            height: 168,
            decoration: BoxDecoration(
              color:
                  _hasImage ? AppColors.neutral100 : AppColors.primary50,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color:
                    _hasImage ? AppColors.adminBorder : AppColors.primary300,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg - 1),
              child: _buildContent(),
            ),
          ),
        ),
        if (_hasImage && onRemove != null) ...[
          AppSpacing.gapSm,
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 16,
                color: AppColors.error,
              ),
              label: const Text(
                'Xóa ảnh',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContent() {
    if (isUploading) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary500,
          ),
        ),
      );
    }

    if (selectedImageFile != null) {
      if (kIsWeb) {
        if (selectedImageFile!.bytes == null) return const _PickerError();
        return Image.memory(
          selectedImageFile!.bytes!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      }
      if (selectedImageFile!.path == null) return const _PickerError();
      return Image.file(
        File(selectedImageFile!.path!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (existingImageUrl != null) {
      return CachedNetworkImage(
        imageUrl: existingImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, __) => const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary500,
            ),
          ),
        ),
        errorWidget: (_, __, ___) => const _PickerError(),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
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
          'Tải ảnh đại diện danh mục',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'PNG, JPG, WebP – tối đa 5MB',
          style: TextStyle(
            fontSize: 11.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PickerError extends StatelessWidget {
  const _PickerError();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.broken_image_outlined,
        size: 28,
        color: AppColors.neutral400,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Submit button (giữ riêng để có loading state)
// ---------------------------------------------------------------------------

class _SubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isLoading ? AppColors.primary300 : AppColors.primary500,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
              ] else ...[
                const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                AppSpacing.gapSm,
              ],
              Text(
                isLoading ? 'Đang lưu...' : label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Re-export công cộng để Edit dialog dùng lại
class CategoryFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final String? selectedStatus;
  final String? selectedParentId;
  final List<CategoryModel> parentOptions;
  final PlatformFile? selectedImageFile;
  final String? existingImageUrl;
  final bool isUploading;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;
  final ValueChanged<String?> onParentChanged;
  final ValueChanged<String?> onStatusChanged;

  const CategoryFormFields({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.selectedStatus,
    required this.selectedParentId,
    required this.parentOptions,
    required this.selectedImageFile,
    required this.existingImageUrl,
    required this.isUploading,
    required this.onPickImage,
    required this.onClearImage,
    required this.onParentChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryFormFields(
      nameController: nameController,
      descriptionController: descriptionController,
      selectedStatus: selectedStatus,
      selectedParentId: selectedParentId,
      parentOptions: parentOptions,
      selectedImageFile: selectedImageFile,
      existingImageUrl: existingImageUrl,
      isUploading: isUploading,
      onPickImage: onPickImage,
      onClearImage: onClearImage,
      onParentChanged: onParentChanged,
      onStatusChanged: onStatusChanged,
    );
  }
}

class CategorySubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const CategorySubmitButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return _SubmitButton(
      label: label,
      isLoading: isLoading,
      onPressed: onPressed,
    );
  }
}
