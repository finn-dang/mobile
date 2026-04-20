import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../common/admin_card.dart';

/// Search & Filter cho Reviews – Modern Minimal.
class ReviewsSearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final int? selectedRating;
  final bool? hasReply;
  final ValueChanged<int?> onRatingChanged;
  final ValueChanged<bool?> onReplyChanged;
  final VoidCallback onClearFilters;
  final bool isTablet;

  const ReviewsSearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.selectedRating,
    required this.hasReply,
    required this.onRatingChanged,
    required this.onReplyChanged,
    required this.onClearFilters,
    required this.isTablet,
  });

  bool get _hasFilter =>
      selectedRating != null ||
      hasReply != null ||
      searchController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return AdminCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: isMobile ? _buildMobile() : _buildDesktop(),
    );
  }

  Widget _buildDesktop() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _MinimalTextField(
            controller: searchController,
            hintText: 'Tìm theo tên, nội dung, mã sản phẩm...',
          ),
        ),
        AppSpacing.gapMd,
        Expanded(
          flex: 2,
          child: _RatingDropdown(
            value: selectedRating,
            onChanged: onRatingChanged,
          ),
        ),
        AppSpacing.gapMd,
        Expanded(
          flex: 2,
          child: _ReplyDropdown(value: hasReply, onChanged: onReplyChanged),
        ),
        if (_hasFilter) ...[
          AppSpacing.gapSm,
          _ClearButton(onPressed: onClearFilters),
        ],
      ],
    );
  }

  Widget _buildMobile() {
    return Column(
      children: [
        _MinimalTextField(
          controller: searchController,
          hintText: 'Tìm đánh giá...',
        ),
        AppSpacing.gapSm,
        Row(
          children: [
            Expanded(
              child: _RatingDropdown(
                value: selectedRating,
                onChanged: onRatingChanged,
              ),
            ),
            AppSpacing.gapSm,
            Expanded(
              child: _ReplyDropdown(value: hasReply, onChanged: onReplyChanged),
            ),
          ],
        ),
        if (_hasFilter) ...[
          AppSpacing.gapSm,
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
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
    );
  }
}

// ---------------------------------------------------------------------------
// Minimal field/dropdown helpers
// ---------------------------------------------------------------------------

OutlineInputBorder _border(Color color, {double width = 1}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );

class _MinimalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  const _MinimalTextField({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        style:
            const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
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
          suffixIcon: controller.text.isNotEmpty
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
                  onPressed: () => controller.clear(),
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
}

class _RatingDropdown extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;
  const _RatingDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: DropdownButtonFormField<int?>(
        value: value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 18,
          color: AppColors.neutral500,
        ),
        style:
            const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Đánh giá',
          isDense: true,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: _border(AppColors.adminBorder),
          enabledBorder: _border(AppColors.adminBorder),
          focusedBorder: _border(AppColors.primary500, width: 1.5),
        ),
        items: [
          const DropdownMenuItem<int?>(
            value: null,
            child: Text('Tất cả số sao'),
          ),
          ...List.generate(5, (i) {
            final stars = 5 - i;
            return DropdownMenuItem<int?>(
              value: stars,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var s = 0; s < 5; s++)
                    Icon(
                      s < stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 14,
                      color: AppColors.warning,
                    ),
                  const SizedBox(width: 6),
                  Text('$stars sao'),
                ],
              ),
            );
          }),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _ReplyDropdown extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?> onChanged;
  const _ReplyDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: DropdownButtonFormField<bool?>(
        value: value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 18,
          color: AppColors.neutral500,
        ),
        style:
            const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Phản hồi',
          isDense: true,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: _border(AppColors.adminBorder),
          enabledBorder: _border(AppColors.adminBorder),
          focusedBorder: _border(AppColors.primary500, width: 1.5),
        ),
        items: const [
          DropdownMenuItem<bool?>(
            value: null,
            child: Text('Tất cả phản hồi'),
          ),
          DropdownMenuItem<bool?>(
            value: true,
            child: Text('Đã phản hồi'),
          ),
          DropdownMenuItem<bool?>(
            value: false,
            child: Text('Chưa phản hồi'),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
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
