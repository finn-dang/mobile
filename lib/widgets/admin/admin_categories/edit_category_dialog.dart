import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/category_model.dart';
import '../../../services/image_service.dart';
import '../common/admin_dialog.dart';
import '../common/admin_page_header.dart';
import 'create_category_dialog.dart';

/// Sửa danh mục – Modern Minimal.
///
/// Dùng lại [CategoryFormFields] và [CategorySubmitButton] từ
/// [CreateCategoryDialog] để 2 dialog hoàn toàn nhất quán.
class EditCategoryDialog extends StatefulWidget {
  final CategoryModel category;
  final List<CategoryModel> allCategories;
  final Function(CategoryModel) onSave;

  const EditCategoryDialog({
    super.key,
    required this.category,
    required this.allCategories,
    required this.onSave,
  });

  @override
  State<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final _imageService = ImageService();

  late String? _selectedStatus;
  late String? _selectedParentId;
  late String? _currentImageUrl;
  PlatformFile? _selectedImageFile;
  bool _imageChanged = false;
  bool _isUploading = false;

  List<CategoryModel> get _parentCategories => widget.allCategories
      .where((c) => c.parentId == null && c.id != widget.category.id)
      .toList();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _descriptionController =
        TextEditingController(text: widget.category.description ?? '');
    _selectedStatus = widget.category.status;
    _selectedParentId = widget.category.parentId;
    _currentImageUrl = widget.category.imageUrl;
  }

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
        setState(() {
          _selectedImageFile = file;
          _imageChanged = true;
        });
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

  void _clearImage() {
    setState(() {
      _selectedImageFile = null;
      _currentImageUrl = null;
      _imageChanged = true;
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);
    try {
      String? finalImageUrl = _currentImageUrl;

      if (_imageChanged && _selectedImageFile != null) {
        if (widget.category.imageUrl != null) {
          await _imageService.deleteCategoryImage(widget.category.imageUrl!);
        }
        finalImageUrl = await _imageService.uploadCategoryImage(
          _selectedImageFile!,
          categoryId: widget.category.id,
        );
      }

      final updated = widget.category.copyWith(
        name: _nameController.text.trim(),
        imageUrl: finalImageUrl,
        parentId: _selectedParentId,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        status: _selectedStatus,
        updatedAt: DateTime.now(),
      );

      widget.onSave(updated);
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
      title: 'Chỉnh sửa danh mục',
      subtitle: 'Cập nhật thông tin danh mục thời trang "${widget.category.name}".',
      icon: Icons.edit_outlined,
      maxWidth: 540,
      onClose: _isUploading ? () {} : null,
      body: Form(
        key: _formKey,
        child: CategoryFormFields(
          nameController: _nameController,
          descriptionController: _descriptionController,
          selectedStatus: _selectedStatus,
          selectedParentId: _selectedParentId,
          parentOptions: _parentCategories,
          selectedImageFile: _selectedImageFile,
          existingImageUrl: _currentImageUrl,
          isUploading: _isUploading,
          onPickImage: _pickImage,
          onClearImage: _clearImage,
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
          CategorySubmitButton(
            label: 'Lưu thay đổi',
            isLoading: _isUploading,
            onPressed: _handleSave,
          ),
        ],
      ),
    );
  }
}
