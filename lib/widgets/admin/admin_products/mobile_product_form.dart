import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../models/category_model.dart';
import 'product_info_tab.dart';
import 'product_options_section.dart';
import 'product_specifications_section.dart';

class MobileProductForm extends StatefulWidget {
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
  final bool isLoading;
  final bool isUploading;
  final VoidCallback onSubmit;
  final List<String> versions;
  final List<Map<String, dynamic>> colors;
  final List<Map<String, dynamic>> options;
  final TextEditingController versionController;
  final TextEditingController colorNameController;
  final TextEditingController colorHexController;
  final String? selectedVersionForOption;
  final String? selectedColorForOption;
  final TextEditingController optionOriginalPriceController;
  final TextEditingController optionDiscountController;
  final TextEditingController optionQuantityController;
  final int basePrice;
  final ValueChanged<String?> onVersionChanged;
  final ValueChanged<String?> onColorChanged;
  final VoidCallback onAddVersion;
  final Function(int) onRemoveVersion;
  final VoidCallback onAddColor;
  final Function(int) onRemoveColor;
  final VoidCallback onAddOption;
  final Function(int) onRemoveOption;
  final List<Map<String, String>> specifications;
  final TextEditingController specLabelController;
  final TextEditingController specValueController;
  final VoidCallback onAddSpecification;
  final Function(int) onRemoveSpecification;

  const MobileProductForm({
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
    required this.isLoading,
    required this.isUploading,
    required this.onSubmit,
    required this.versions,
    required this.colors,
    required this.options,
    required this.versionController,
    required this.colorNameController,
    required this.colorHexController,
    required this.selectedVersionForOption,
    required this.selectedColorForOption,
    required this.optionOriginalPriceController,
    required this.optionDiscountController,
    required this.optionQuantityController,
    required this.basePrice,
    required this.onVersionChanged,
    required this.onColorChanged,
    required this.onAddVersion,
    required this.onRemoveVersion,
    required this.onAddColor,
    required this.onRemoveColor,
    required this.onAddOption,
    required this.onRemoveOption,
    required this.specifications,
    required this.specLabelController,
    required this.specValueController,
    required this.onAddSpecification,
    required this.onRemoveSpecification,
  });

  @override
  State<MobileProductForm> createState() => _MobileProductFormState();
}

class _MobileProductFormState extends State<MobileProductForm>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Thông tin'),
            Tab(text: 'Option'),
            Tab(text: 'Thông số'),
          ],
        ),
        const SizedBox(height: 16),
        // Tab Bar View
        SizedBox(
          height: 600,
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Thông tin
              ProductInfoTab(
                nameController: widget.nameController,
                priceController: widget.priceController,
                originalPriceController: widget.originalPriceController,
                quantityController: widget.quantityController,
                descriptionController: widget.descriptionController,
                selectedParentCategoryId: widget.selectedParentCategoryId,
                selectedChildCategoryId: widget.selectedChildCategoryId,
                selectedStatus: widget.selectedStatus,
                parentCategories: widget.parentCategories,
                childCategories: widget.childCategories,
                onParentCategoryChanged: widget.onParentCategoryChanged,
                onChildCategoryChanged: widget.onChildCategoryChanged,
                onStatusChanged: widget.onStatusChanged,
                selectedImageFiles: widget.selectedImageFiles,
                imageUrls: widget.imageUrls,
                onPickImages: widget.onPickImages,
                onRemoveImage: widget.onRemoveImage,
                isUploading: widget.isUploading,
                isTablet: false,
                isMobile: true,
              ),
              // Tab 2: Option
              SingleChildScrollView(
                child: ProductOptionsSection(
                  versions: widget.versions,
                  colors: widget.colors,
                  options: widget.options,
                  versionController: widget.versionController,
                  colorNameController: widget.colorNameController,
                  colorHexController: widget.colorHexController,
                  selectedVersionForOption: widget.selectedVersionForOption,
                  selectedColorForOption: widget.selectedColorForOption,
                  optionOriginalPriceController: widget.optionOriginalPriceController,
                  optionDiscountController: widget.optionDiscountController,
                  optionQuantityController: widget.optionQuantityController,
                  basePrice: widget.basePrice,
                  onVersionChanged: widget.onVersionChanged,
                  onColorChanged: widget.onColorChanged,
                  onAddVersion: widget.onAddVersion,
                  onRemoveVersion: widget.onRemoveVersion,
                  onAddColor: widget.onAddColor,
                  onRemoveColor: widget.onRemoveColor,
                  onAddOption: widget.onAddOption,
                  onRemoveOption: widget.onRemoveOption,
                  isTablet: false,
                  isMobile: true,
                ),
              ),
              // Tab 3: Thông số
              SingleChildScrollView(
                child: ProductSpecificationsSection(
                  specifications: widget.specifications,
                  labelController: widget.specLabelController,
                  valueController: widget.specValueController,
                  onAddSpecification: widget.onAddSpecification,
                  onRemoveSpecification: widget.onRemoveSpecification,
                  isTablet: false,
                  isMobile: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

