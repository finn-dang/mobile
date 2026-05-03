import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../common/admin_card.dart';

/// Search & Filter cho News – Modern Minimal.
class NewsSearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onClearFilters;

  const NewsSearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
    required this.onClearFilters,
  });

  bool get _hasFilter =>
      selectedCategory != 'Tất cả' || searchController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    return AdminCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: isMobile
          ? Column(
              children: [
                _buildSearchField(),
                AppSpacing.gapSm,
                _buildCategoryDropdown(),
                if (_hasFilter) ...[
                  AppSpacing.gapSm,
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: onClearFilters,
                      icon: const Icon(Icons.filter_alt_off_outlined,
                          size: 16),
                      label: const Text('Xoá bộ lọc'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          side: const BorderSide(color: AppColors.adminBorder),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            )
          : Row(
              children: [
                Expanded(flex: 3, child: _buildSearchField()),
                AppSpacing.gapMd,
                Expanded(flex: 2, child: _buildCategoryDropdown()),
                if (_hasFilter) ...[
                  AppSpacing.gapSm,
                  _ClearButton(onPressed: onClearFilters),
                ],
              ],
            ),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: searchController,
        style:
            const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Tìm theo tiêu đề, tóm tắt, tác giả...',
          hintStyle: const TextStyle(
            fontSize: 13.5,
            color: AppColors.neutral400,
          ),
          isDense: true,
          filled: true,
          fillColor: AppColors.surface,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 10, right: 4),
            child: Icon(
              Icons.search_rounded,
              size: 18,
              color: AppColors.neutral400,
            ),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 32, minHeight: 32),
          suffixIcon: searchController.text.isNotEmpty
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: _border(AppColors.adminBorder),
          enabledBorder: _border(AppColors.adminBorder),
          focusedBorder: _border(AppColors.primary500, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return SizedBox(
      height: 40,
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 18,
          color: AppColors.neutral500,
        ),
        style:
            const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AppColors.surface,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 10, right: 4),
            child: Icon(
              Icons.category_outlined,
              size: 14,
              color: AppColors.neutral500,
            ),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 30, minHeight: 32),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: _border(AppColors.adminBorder),
          enabledBorder: _border(AppColors.adminBorder),
          focusedBorder: _border(AppColors.primary500, width: 1.5),
        ),
        items: categories
            .map(
              (c) => DropdownMenuItem(value: c, child: Text(c)),
            )
            .toList(),
        onChanged: (v) {
          if (v != null) onCategoryChanged(v);
        },
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: color, width: width),
      );
}

class _ClearButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ClearButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Xoá bộ lọc',
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
