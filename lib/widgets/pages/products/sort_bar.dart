import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';

enum ProductSort {
  none('Mặc định', Icons.sort_rounded),
  nameAsc('Tên A → Z', Icons.sort_by_alpha_rounded),
  nameDesc('Tên Z → A', Icons.sort_by_alpha_rounded),
  priceAsc('Giá thấp → cao', Icons.arrow_upward_rounded),
  priceDesc('Giá cao → thấp', Icons.arrow_downward_rounded);

  final String label;
  final IconData icon;
  const ProductSort(this.label, this.icon);
}

/// Sort bar bên trên grid – Modern Minimal.
///
/// Hiển thị: số kết quả + dropdown sort + nút mở filter (mobile).
class SortBar extends StatelessWidget {
  final int totalResults;
  final ProductSort sortOption;
  final ValueChanged<ProductSort> onSortChanged;
  final VoidCallback? onOpenFilter;
  final bool showFilterButton;

  const SortBar({
    super.key,
    required this.totalResults,
    required this.sortOption,
    required this.onSortChanged,
    this.onOpenFilter,
    this.showFilterButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.adminBorder),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          if (showFilterButton) ...[
            _FilterButton(onPressed: onOpenFilter),
            AppSpacing.gapMd,
            Container(
              width: 1,
              height: 22,
              color: AppColors.neutral200,
            ),
            AppSpacing.gapMd,
          ],
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$totalResults',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const TextSpan(
                    text: ' sản phẩm',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.gapMd,
          _SortDropdown(value: sortOption, onChanged: onSortChanged),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const _FilterButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary50,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 16,
                color: AppColors.primary600,
              ),
              SizedBox(width: 6),
              Text(
                'Lọc',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  final ProductSort value;
  final ValueChanged<ProductSort> onChanged;

  const _SortDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ProductSort>(
      tooltip: 'Sắp xếp',
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.adminBorder),
      ),
      color: AppColors.surface,
      elevation: 4,
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final s in ProductSort.values)
          PopupMenuItem<ProductSort>(
            value: s,
            child: Row(
              children: [
                Icon(s.icon, size: 14, color: AppColors.neutral500),
                const SizedBox(width: 8),
                Text(
                  s.label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: s == value ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (s == value) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: AppColors.primary600,
                  ),
                ],
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.adminBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(value.icon, size: 14, color: AppColors.neutral500),
            const SizedBox(width: 8),
            Text(
              value.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppColors.neutral500,
            ),
          ],
        ),
      ),
    );
  }
}
