import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../config/spacing.dart';
import '../../../models/category_model.dart';
import '../common/admin_card.dart';
import 'basic_info_section.dart';
import 'product_images_section.dart';
import 'product_text_field.dart';

class ProductInfoTab extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController originalPriceController;
  final TextEditingController quantityController;
  final TextEditingController descriptionController;
  final String? selectedParentCategoryId;
  final String? selectedChildCategoryId;
  final String? selectedStatus;
  final List<CategoryModel> parentCategories;
  final List<CategoryModel> childCategories;
  final ValueChanged<String?> onParentCategoryChanged;
  final ValueChanged<String?> onChildCategoryChanged;
  final ValueChanged<String?> onStatusChanged;
  final List<PlatformFile> selectedImageFiles;
  final List<String> imageUrls;
  final VoidCallback onPickImages;
  final Function(int) onRemoveImage;
  final List<Map<String, dynamic>> options;
  final bool isUploading;
  final bool isTablet;
  final bool isMobile;

  const ProductInfoTab({
    super.key,
    required this.nameController,
    required this.priceController,
    required this.originalPriceController,
    required this.quantityController,
    required this.descriptionController,
    required this.selectedParentCategoryId,
    required this.selectedChildCategoryId,
    required this.selectedStatus,
    required this.parentCategories,
    required this.childCategories,
    required this.onParentCategoryChanged,
    required this.onChildCategoryChanged,
    required this.onStatusChanged,
    required this.selectedImageFiles,
    required this.imageUrls,
    required this.onPickImages,
    required this.onRemoveImage,
    this.options = const [],
    required this.isUploading,
    required this.isTablet,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final basicInfo = BasicInfoSection(
      nameController: nameController,
      priceController: priceController,
      originalPriceController: originalPriceController,
      quantityController: quantityController,
      selectedParentCategoryId: selectedParentCategoryId,
      selectedChildCategoryId: selectedChildCategoryId,
      selectedStatus: selectedStatus,
      parentCategories: parentCategories,
      childCategories: childCategories,
      onParentCategoryChanged: onParentCategoryChanged,
      onChildCategoryChanged: onChildCategoryChanged,
      onStatusChanged: onStatusChanged,
      options: options,
      isTablet: isTablet,
      isMobile: isMobile,
    );

    final descriptionCard = AdminCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionTitle(
            title: 'Mô tả sản phẩm',
            description: 'Mô tả kiểu dáng, chất liệu, form và cách phối đồ.',
          ),
          ProductTextField(
            controller: descriptionController,
            label: 'Mô tả',
            hint: 'Ví dụ: Chất linen thoáng mát, form regular dễ phối cùng quần tây hoặc jeans.',
            maxLines: 8,
            isTablet: isTablet,
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile)
          basicInfo
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: basicInfo),
              AppSpacing.gapLg,
              Expanded(flex: 1, child: descriptionCard),
            ],
          ),
        if (isMobile) ...[
          AppSpacing.gapLg,
          descriptionCard,
        ],
        AppSpacing.gapLg,
        ProductImagesSection(
          selectedImageFiles: selectedImageFiles,
          imageUrls: imageUrls,
          onPickImages: onPickImages,
          onRemoveImage: onRemoveImage,
          isUploading: isUploading,
          isTablet: isTablet,
        ),
      ],
    );
  }
}
