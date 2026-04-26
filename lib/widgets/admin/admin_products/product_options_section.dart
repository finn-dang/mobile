import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../common/admin_card.dart';
import '../common/admin_page_header.dart';
import 'product_dropdown_field.dart';
import 'product_text_field.dart';

/// Section "Biến thể sản phẩm" – Modern Minimal.
///
/// Gồm 3 phần con: Size/Form, Màu sắc, Biến thể (kết hợp).
class ProductOptionsSection extends StatelessWidget {
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
  final Function(int)? onEditOption;
  final VoidCallback? onCancelEditOption;
  final Function(int) onRemoveOption;
  final int? editingOptionIndex;
  final bool isTablet;
  final bool isMobile;

  const ProductOptionsSection({
    super.key,
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
    this.onEditOption,
    this.onCancelEditOption,
    required this.onRemoveOption,
    this.editingOptionIndex,
    required this.isTablet,
    required this.isMobile,
  });

  static String _formatPrice(int price) =>
      price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );

  static Color _hexToColor(String hex) {
    final code = hex.replaceAll('#', '');
    if (code.length == 6) return Color(int.parse('FF$code', radix: 16));
    if (code.length == 3) {
      final r = code[0] * 2;
      final g = code[1] * 2;
      final b = code[2] * 2;
      return Color(int.parse('FF$r$g$b', radix: 16));
    }
    return AppColors.neutral400;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _versionsCard(),
        AppSpacing.gapLg,
        _colorsCard(),
        AppSpacing.gapLg,
        _optionsCard(),
      ],
    );
  }

  // ---------- Sizes / Forms ----------

  Widget _versionsCard() {
    return AdminCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionTitle(
            title: 'Size / Form',
            description: 'Ví dụ: S, M, L, XL hoặc Slim fit, Regular fit.',
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: ProductTextField(
                  controller: versionController,
                  label: 'Tên size/form',
                  hint: 'Ví dụ: M hoặc Regular fit',
                  isTablet: isTablet,
                ),
              ),
              AppSpacing.gapMd,
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: AdminPrimaryButton(
                  icon: Icons.add_rounded,
                  label: 'Thêm',
                  onPressed: onAddVersion,
                ),
              ),
            ],
          ),
          if (versions.isNotEmpty) ...[
            AppSpacing.gapMd,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < versions.length; i++)
                  _RemovableChip(
                    label: versions[i],
                    onRemove: () => onRemoveVersion(i),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ---------- Colors ----------

  Widget _colorsCard() {
    return AdminCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionTitle(
            title: 'Màu sắc',
            description: 'Tên màu hiển thị + mã hex để render swatch trên storefront.',
          ),
          if (isMobile) ...[
            ProductTextField(
              controller: colorNameController,
              label: 'Tên màu',
              hint: 'Ví dụ: Đỏ',
              isTablet: isTablet,
            ),
            AppSpacing.gapMd,
            ProductTextField(
              controller: colorHexController,
              label: 'Mã hex',
              hint: '#FF0000',
              isTablet: isTablet,
            ),
            AppSpacing.gapMd,
            SizedBox(
              width: double.infinity,
              child: AdminPrimaryButton(
                icon: Icons.add_rounded,
                label: 'Thêm màu',
                onPressed: onAddColor,
              ),
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: ProductTextField(
                    controller: colorNameController,
                    label: 'Tên màu',
                    hint: 'Ví dụ: Đỏ',
                    isTablet: isTablet,
                  ),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: ProductTextField(
                    controller: colorHexController,
                    label: 'Mã hex',
                    hint: '#FF0000',
                    isTablet: isTablet,
                  ),
                ),
                AppSpacing.gapMd,
                Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: AdminPrimaryButton(
                    icon: Icons.add_rounded,
                    label: 'Thêm',
                    onPressed: onAddColor,
                  ),
                ),
              ],
            ),
          ],
          if (colors.isNotEmpty) ...[
            AppSpacing.gapMd,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < colors.length; i++)
                  _ColorChip(
                    name: colors[i]['name'] as String,
                    color: _hexToColor(colors[i]['hex'] as String),
                    onRemove: () => onRemoveColor(i),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ---------- Options ----------

  Widget _optionsCard() {
    final canAddOption = versions.isNotEmpty && colors.isNotEmpty;
    final isEditing = editingOptionIndex != null;

    return AdminCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminSectionTitle(
            title: 'Tuỳ chọn sản phẩm',
            description:
                'Mỗi biến thể = size/form + màu sắc. Giá cơ bản: ${_formatPrice(basePrice)} ₫.',
          ),
          if (!canAddOption)
            AdminInlineNotice.warning(
              'Vui lòng thêm ít nhất một size/form và một màu sắc để có thể tạo biến thể.',
            )
          else ...[
            // Form thêm/sửa option
            if (isMobile) ...[
              ProductDropdownField<String>(
                value: selectedVersionForOption,
                label: 'Size / Form',
                required: true,
                items: versions,
                onChanged: onVersionChanged,
                isTablet: isTablet,
                isMobile: isMobile,
              ),
              AppSpacing.gapMd,
              ProductDropdownField<String>(
                value: selectedColorForOption,
                label: 'Màu sắc',
                required: true,
                items: colors.map((c) => c['name'] as String).toList(),
                onChanged: onColorChanged,
                isTablet: isTablet,
                isMobile: isMobile,
              ),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ProductDropdownField<String>(
                      value: selectedVersionForOption,
                      label: 'Size / Form',
                      required: true,
                      items: versions,
                      onChanged: onVersionChanged,
                      isTablet: isTablet,
                      isMobile: isMobile,
                    ),
                  ),
                  AppSpacing.gapMd,
                  Expanded(
                    child: ProductDropdownField<String>(
                      value: selectedColorForOption,
                      label: 'Màu sắc',
                      required: true,
                      items: colors.map((c) => c['name'] as String).toList(),
                      onChanged: onColorChanged,
                      isTablet: isTablet,
                      isMobile: isMobile,
                    ),
                  ),
                ],
              ),
            ],
            AppSpacing.gapMd,
            if (isMobile) ...[
              ProductTextField(
                controller: optionOriginalPriceController,
                label: 'Giá gốc',
                hint: 'Để trống = dùng giá cơ bản',
                keyboardType: TextInputType.number,
                suffix: '₫',
                isTablet: isTablet,
              ),
              AppSpacing.gapMd,
              ProductTextField(
                controller: optionDiscountController,
                label: 'Giảm giá (%)',
                hint: '0-100',
                keyboardType: TextInputType.number,
                isTablet: isTablet,
              ),
              AppSpacing.gapMd,
              ProductTextField(
                controller: optionQuantityController,
                label: 'Số lượng',
                hint: '0',
                required: true,
                keyboardType: TextInputType.number,
                isTablet: isTablet,
              ),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ProductTextField(
                      controller: optionOriginalPriceController,
                      label: 'Giá gốc',
                      hint: 'Để trống = dùng giá cơ bản',
                      keyboardType: TextInputType.number,
                      suffix: '₫',
                      isTablet: isTablet,
                    ),
                  ),
                  AppSpacing.gapMd,
                  Expanded(
                    child: ProductTextField(
                      controller: optionDiscountController,
                      label: 'Giảm giá (%)',
                      hint: '0-100',
                      keyboardType: TextInputType.number,
                      isTablet: isTablet,
                    ),
                  ),
                  AppSpacing.gapMd,
                  Expanded(
                    child: ProductTextField(
                      controller: optionQuantityController,
                      label: 'Số lượng',
                      hint: '0',
                      required: true,
                      keyboardType: TextInputType.number,
                      isTablet: isTablet,
                    ),
                  ),
                ],
              ),
            ],
            AppSpacing.gapMd,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isEditing && onCancelEditOption != null) ...[
                  AdminSecondaryButton(
                    icon: Icons.close_rounded,
                    label: 'Huỷ',
                    onPressed: onCancelEditOption!,
                  ),
                  AppSpacing.gapSm,
                ],
                AdminPrimaryButton(
                  icon: isEditing
                      ? Icons.save_outlined
                      : Icons.add_rounded,
                  label: isEditing ? 'Cập nhật biến thể' : 'Thêm biến thể',
                  onPressed: onAddOption,
                ),
              ],
            ),
          ],
          if (options.isNotEmpty) ...[
            AppSpacing.gapLg,
            Row(
              children: [
                Text(
                  'Danh sách biến thể',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.gapSm,
                AdminStatusPill.neutral(options.length.toString()),
              ],
            ),
            AppSpacing.gapMd,
            for (var i = 0; i < options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _OptionItem(
                  option: options[i],
                  isEditing: editingOptionIndex == i,
                  isMobile: isMobile,
                  onEdit: onEditOption == null
                      ? null
                      : () => onEditOption!(i),
                  onRemove: () => onRemoveOption(i),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _RemovableChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _RemovableChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          AppSpacing.gapSm,
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: AppColors.neutral100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 12,
                color: AppColors.neutral600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  final String name;
  final Color color;
  final VoidCallback onRemove;
  const _ColorChip({
    required this.name,
    required this.color,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 5, 6, 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.adminBorder, width: 0.5),
            ),
          ),
          AppSpacing.gapSm,
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: AppColors.neutral100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 12,
                color: AppColors.neutral600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final Map<String, dynamic> option;
  final bool isEditing;
  final bool isMobile;
  final VoidCallback? onEdit;
  final VoidCallback onRemove;

  const _OptionItem({
    required this.option,
    required this.isEditing,
    required this.isMobile,
    required this.onRemove,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final version = option['version'] as String;
    final colorName = option['colorName'] as String;
    final colorHex = option['colorHex'] as String;
    final originalPrice = option['originalPrice'] as int;
    final discount = option['discount'] as int;
    final quantity = option['quantity'] as int? ?? 0;
    final finalPrice = originalPrice - (originalPrice * discount ~/ 100);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isEditing ? AppColors.primary50 : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isEditing ? AppColors.primary300 : AppColors.adminBorder,
          width: isEditing ? 1.2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: ProductOptionsSection._hexToColor(colorHex),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.adminBorder, width: 0.5),
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '$version • $colorName',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isEditing) ...[
                      AppSpacing.gapSm,
                      AdminStatusPill(
                        label: 'Đang sửa',
                        fg: Colors.white,
                        bg: AppColors.primary500,
                        icon: Icons.edit_outlined,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${ProductOptionsSection._formatPrice(finalPrice)} ₫',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary600,
                      ),
                    ),
                    if (discount > 0)
                      Text(
                        '${ProductOptionsSection._formatPrice(originalPrice)} ₫',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.neutral400,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.neutral400,
                        ),
                      ),
                    if (discount > 0)
                      AdminStatusPill.danger('-$discount%'),
                    Text(
                      'SL: $quantity',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.gapSm,
          if (onEdit != null)
            _MiniIconButton(
              icon: Icons.edit_outlined,
              tooltip: 'Sửa',
              color: AppColors.primary600,
              onPressed: onEdit!,
            ),
          AppSpacing.gapXs,
          _MiniIconButton(
            icon: Icons.delete_outline_rounded,
            tooltip: 'Xoá',
            color: AppColors.error,
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _MiniIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;

  const _MiniIconButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_MiniIconButton> createState() => _MiniIconButtonState();
}

class _MiniIconButtonState extends State<_MiniIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: SizedBox(
        width: 30,
        height: 30,
        child: Material(
          color: _hover
              ? widget.color.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: InkWell(
            onTap: widget.onPressed,
            onHover: (v) => setState(() => _hover = v),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Icon(widget.icon, size: 16, color: widget.color),
          ),
        ),
      ),
    );
  }
}
