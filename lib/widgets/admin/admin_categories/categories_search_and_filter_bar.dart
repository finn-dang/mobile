import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../common/admin_card.dart';

/// Search & Filter cho Categories – Modern Minimal.
class CategoriesSearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClearFilters;
  final bool isTablet;

  const CategoriesSearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onClearFilters,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilter =
        selectedStatus != null || searchController.text.isNotEmpty;

    return AdminCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _MinimalTextField(
              controller: searchController,
              hintText: 'Tìm danh mục theo tên hoặc mô tả...',
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
                      constraints:
                          const BoxConstraints(minWidth: 28, minHeight: 28),
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
                  value: 'Hiển thị',
                  child: Text('Hiển thị'),
                ),
                DropdownMenuItem<String?>(
                  value: 'Ẩn',
                  child: Text('Đang ẩn'),
                ),
              ],
              onChanged: onStatusChanged,
            ),
          ),
          if (hasFilter) ...[
            AppSpacing.gapSm,
            _ClearFiltersButton(onPressed: onClearFilters),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets (đồng bộ với Products search bar)
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
          border: _border(AppColors.adminBorder),
          enabledBorder: _border(AppColors.adminBorder),
          focusedBorder: _border(AppColors.primary500, width: 1.5),
        ),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
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
          border: _border(AppColors.adminBorder),
          enabledBorder: _border(AppColors.adminBorder),
          focusedBorder: _border(AppColors.primary500, width: 1.5),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
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
