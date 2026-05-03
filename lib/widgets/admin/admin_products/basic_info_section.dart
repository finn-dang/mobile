import 'package:flutter/material.dart';
import '../../../config/spacing.dart';
import '../../../models/category_model.dart';
import '../common/admin_card.dart';
import 'product_dropdown_field.dart';
import 'product_text_field.dart';

class BasicInfoSection extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController originalPriceController;
  final TextEditingController quantityController;
  final String? selectedParentCategoryId;
  final String? selectedChildCategoryId;
  final String? selectedStatus;
  final List<CategoryModel> parentCategories;
  final List<CategoryModel> childCategories;
  final ValueChanged<String?> onParentCategoryChanged;
  final ValueChanged<String?> onChildCategoryChanged;
  final ValueChanged<String?> onStatusChanged;
  final List<Map<String, dynamic>> options;
  final bool isTablet;
  final bool isMobile;

  const BasicInfoSection({
    super.key,
    required this.nameController,
    required this.priceController,
    required this.originalPriceController,
    required this.quantityController,
    required this.selectedParentCategoryId,
    required this.selectedChildCategoryId,
    required this.selectedStatus,
    required this.parentCategories,
    required this.childCategories,
    required this.onParentCategoryChanged,
    required this.onChildCategoryChanged,
    required this.onStatusChanged,
    this.options = const [],
    required this.isTablet,
    this.isMobile = false,
  });

  @override
  State<BasicInfoSection> createState() => _BasicInfoSectionState();
}

class _BasicInfoSectionState extends State<BasicInfoSection> {
  String _formatPrice(int price) => price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );

  @override
  void initState() {
    super.initState();
    widget.priceController.addListener(_updatePriceDisplay);
    widget.originalPriceController.addListener(_updatePriceDisplay);
  }

  @override
  void dispose() {
    widget.priceController.removeListener(_updatePriceDisplay);
    widget.originalPriceController.removeListener(_updatePriceDisplay);
    super.dispose();
  }

  void _updatePriceDisplay() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final price = int.tryParse(widget.priceController.text.trim()) ?? 0;
    final originalPriceText = widget.originalPriceController.text.trim();
    final originalPrice = originalPriceText.isNotEmpty
        ? (int.tryParse(originalPriceText) ?? 0)
        : price;
    final hasDiscount = originalPrice > price && price > 0;
    final discountPercent = hasDiscount
        ? ((originalPrice - price) / originalPrice * 100).round()
        : 0;

    return AdminCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionTitle(
            title: 'Thông tin cơ bản',
            description: 'Tên sản phẩm thời trang, danh mục, giá bán và tồn kho.',
          ),
          ProductTextField(
            controller: widget.nameController,
            label: 'Tên sản phẩm',
            hint: 'Ví dụ: Áo sơ mi linen nam tay dài',
            required: true,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Vui lòng nhập tên sản phẩm' : null,
            isTablet: widget.isTablet,
          ),
          AppSpacing.gapMd,
          ProductDropdownField<String>(
            value: widget.selectedParentCategoryId,
            label: 'Danh mục cha',
            required: true,
            items: widget.parentCategories.map((c) => c.id).toList(),
            itemLabels: widget.parentCategories.map((c) => c.name).toList(),
            onChanged: widget.onParentCategoryChanged,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Vui lòng chọn danh mục cha' : null,
            isTablet: widget.isTablet,
            isMobile: widget.isMobile,
          ),
          if (widget.selectedParentCategoryId != null &&
              widget.childCategories.isNotEmpty) ...[
            AppSpacing.gapMd,
            ProductDropdownField<String?>(
              value: widget.selectedChildCategoryId,
              label: 'Danh mục con',
              items: [
                null,
                ...widget.childCategories.map((c) => c.id),
              ],
              itemLabels: [
                'Không có',
                ...widget.childCategories.map((c) => c.name),
              ],
              onChanged: widget.onChildCategoryChanged,
              isTablet: widget.isTablet,
              isMobile: widget.isMobile,
            ),
          ],
          AppSpacing.gapMd,
          // Price row: 2 cột trên desktop/tablet, 1 cột trên mobile
          if (widget.isMobile) ...[
            ProductTextField(
              controller: widget.priceController,
              label: 'Giá bán',
              hint: 'Ví dụ: 490000',
              required: true,
              keyboardType: TextInputType.number,
              suffix: '₫',
              validator: _validatePrice,
              isTablet: widget.isTablet,
            ),
            AppSpacing.gapMd,
            ProductTextField(
              controller: widget.originalPriceController,
              label: 'Giá gốc',
              hint: 'Ví dụ: 690000 (để trống nếu không giảm giá)',
              keyboardType: TextInputType.number,
              suffix: '₫',
              validator: _validateOriginalPrice,
              isTablet: widget.isTablet,
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ProductTextField(
                    controller: widget.priceController,
                    label: 'Giá bán',
                    hint: 'Ví dụ: 490000',
                    required: true,
                    keyboardType: TextInputType.number,
                    suffix: '₫',
                    validator: _validatePrice,
                    isTablet: widget.isTablet,
                  ),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: ProductTextField(
                    controller: widget.originalPriceController,
                    label: 'Giá gốc',
                    hint: 'Ví dụ: 690000 (để trống nếu không giảm giá)',
                    keyboardType: TextInputType.number,
                    suffix: '₫',
                    validator: _validateOriginalPrice,
                    isTablet: widget.isTablet,
                  ),
                ),
              ],
            ),
          ],
          if (hasDiscount) ...[
            const SizedBox(height: AppSpacing.md),
            AdminInlineNotice.success(
              'Giảm $discountPercent% – giá gốc ${_formatPrice(originalPrice)} ₫ → ${_formatPrice(price)} ₫.',
              icon: Icons.local_offer_outlined,
            ),
          ],
          AppSpacing.gapMd,
          if (widget.isMobile) ...[
            ProductTextField(
              controller: widget.quantityController,
              label: 'Số lượng',
              hint: '0',
              required: true,
              keyboardType: TextInputType.number,
              validator: _validateQuantity,
              isTablet: widget.isTablet,
            ),
            AppSpacing.gapMd,
            ProductDropdownField<String>(
              value: widget.selectedStatus,
              label: 'Trạng thái',
              required: true,
              items: const ['Còn hàng', 'Hết hàng'],
              onChanged: widget.onStatusChanged,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Vui lòng chọn trạng thái' : null,
              isTablet: widget.isTablet,
              isMobile: widget.isMobile,
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ProductTextField(
                    controller: widget.quantityController,
                    label: 'Số lượng',
                    hint: '0',
                    required: true,
                    keyboardType: TextInputType.number,
                    validator: _validateQuantity,
                    isTablet: widget.isTablet,
                  ),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: ProductDropdownField<String>(
                    value: widget.selectedStatus,
                    label: 'Trạng thái',
                    required: true,
                    items: const ['Còn hàng', 'Hết hàng'],
                    onChanged: widget.onStatusChanged,
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Vui lòng chọn trạng thái'
                        : null,
                    isTablet: widget.isTablet,
                    isMobile: widget.isMobile,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Validators
  // ---------------------------------------------------------------------------

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập giá bán';
    final v = int.tryParse(value);
    if (v == null) return 'Giá bán phải là số';
    if (v < 0) return 'Giá bán phải lớn hơn 0';
    final originalText = widget.originalPriceController.text.trim();
    if (originalText.isNotEmpty) {
      final original = int.tryParse(originalText);
      if (original != null && original < v) return 'Giá gốc phải ≥ giá bán';
    }
    return null;
  }

  String? _validateOriginalPrice(String? value) {
    if (value == null || value.isEmpty) return null;
    final v = int.tryParse(value);
    if (v == null) return 'Giá gốc phải là số';
    if (v < 0) return 'Giá gốc phải lớn hơn 0';
    final priceText = widget.priceController.text.trim();
    if (priceText.isNotEmpty) {
      final p = int.tryParse(priceText);
      if (p != null && v < p) return 'Giá gốc phải ≥ giá bán';
    }
    return null;
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập số lượng';
    final q = int.tryParse(value);
    if (q == null) return 'Số lượng phải là số';
    if (q < 0) return 'Số lượng phải ≥ 0';
    if (widget.options.isNotEmpty) {
      final total = widget.options.fold<int>(
        0,
        (sum, o) => sum + (o['quantity'] as int? ?? 0),
      );
      if (total != q) {
        return 'Tổng số lượng options ($total) phải bằng số lượng ($q)';
      }
    }
    return null;
  }
}
