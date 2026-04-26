import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/category_model.dart';
import '../common/admin_card.dart';

/// Search & Filter bar – Modern Minimal:
/// • input không filled, border 1px – focus đổi sang primary
/// • dropdown cùng phong cách
/// • clear filter là icon button minimal
class ProductsSearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final String? selectedStatus;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClearFilters;
  final bool isTablet;

  const ProductsSearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.categories,
    required this.selectedCategoryId,
    required this.selectedStatus,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onClearFilters,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveFilter = selectedCategoryId != null ||
        selectedStatus != null ||
        searchController.text.isNotEmpty;

    return AdminCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Search field
          Expanded(
            flex: 3,
            child: _MinimalTextField(
              controller: searchController,
              hintText: 'Tìm sản phẩm theo tên, danh mục, chất liệu, phong cách...',
              prefix: const Icon(
                Icons.search_rounded,
                size: 18,
                color: AppColors.neutral400,
              ),
              suffix: searchController.text.isNotEmpty
                  ? IconButton(
                      iconSize: 16,
                      splashRadius: 16,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.neutral500,
                      ),
                      onPressed: () => searchController.clear(),
                    )
                  : null,
            ),
          ),
          AppSpacing.gapMd,
          // Category dropdown
          Expanded(
            flex: 2,
            child: _MinimalDropdown<String?>(
              value: selectedCategoryId,
              hint: 'Danh mục',
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Tất cả danh mục'),
                ),
                ...categories.map(
                  (c) => DropdownMenuItem<String?>(
                    value: c.id,
                    child: Text(c.name, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
              onChanged: onCategoryChanged,
            ),
          ),
          AppSpacing.gapMd,
          // Status dropdown
          Expanded(
            flex: 2,
            child: _MinimalDropdown<String?>(
              value: selectedStatus,
              hint: 'Trạng thái',
              items: const [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Tất cả trạng thái'),
                ),
                DropdownMenuItem<String?>(
                  value: 'Còn hàng',
                  child: Text('Còn hàng'),
                ),
                DropdownMenuItem<String?>(
                  value: 'Hết hàng',
                  child: Text('Hết hàng'),
                ),
              ],
              onChanged: onStatusChanged,
            ),
          ),
          if (hasActiveFilter) ...[
            AppSpacing.gapSm,
            _ClearFiltersButton(onPressed: onClearFilters),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets dùng nội bộ (có thể tách ra common/ sau)
// ---------------------------------------------------------------------------

class _MinimalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? prefix;
  final Widget? suffix;

  const _MinimalTextField({
    required this.controller,
    required this.hintText,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontSize: 13.5,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 13.5,
            color: AppColors.neutral400,
          ),
          isDense: true,
          filled: true,
          fillColor: AppColors.surface,
          prefixIcon: prefix == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(left: 10, right: 4),
                  child: prefix,
                ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.adminBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.adminBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(
              color: AppColors.primary500,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _MinimalDropdown<T> extends StatelessWidget {
  final T value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _MinimalDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 18,
          color: AppColors.neutral500,
        ),
        style: const TextStyle(
          fontSize: 13.5,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 13.5,
            color: AppColors.neutral400,
          ),
          isDense: true,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.adminBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.adminBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(
              color: AppColors.primary500,
              width: 1.5,
            ),
          ),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}

class _ClearFiltersButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ClearFiltersButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Xóa bộ lọc',
      child: SizedBox(
        height: 40,
        width: 40,
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.adminBorder),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.filter_alt_off_outlined,
                size: 18,
                color: AppColors.neutral600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
