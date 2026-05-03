import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';

/// Pagination – Modern Minimal.
///
/// Hiển thị tối đa 5 ô số trang ở giữa, ... khi có nhiều trang.
class NewsPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const NewsPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  List<int> _visiblePages() {
    if (totalPages <= 7) {
      return List.generate(totalPages, (i) => i + 1);
    }
    final pages = <int>{};
    pages.add(1);
    pages.add(totalPages);
    pages.add(currentPage);
    pages.add(currentPage - 1);
    pages.add(currentPage + 1);
    return pages.where((p) => p >= 1 && p <= totalPages).toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final pages = _visiblePages();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.adminBorder, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NavButton(
            icon: Icons.chevron_left_rounded,
            onPressed: currentPage > 1
                ? () => onPageChanged(currentPage - 1)
                : null,
          ),
          const SizedBox(width: 6),
          for (var i = 0; i < pages.length; i++) ...[
            if (i > 0 && pages[i] - pages[i - 1] > 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '...',
                  style: TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 13,
                  ),
                ),
              ),
            _PageButton(
              page: pages[i],
              isActive: pages[i] == currentPage,
              onTap: () => onPageChanged(pages[i]),
            ),
          ],
          const SizedBox(width: 6),
          _NavButton(
            icon: Icons.chevron_right_rounded,
            onPressed: currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final int page;
  final bool isActive;
  final VoidCallback onTap;

  const _PageButton({
    required this.page,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isActive ? AppColors.primary500 : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary500 : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color:
                    isActive ? AppColors.primary500 : AppColors.adminBorder,
              ),
            ),
            child: Text(
              '$page',
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const _NavButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.adminBorder),
          ),
          child: Icon(
            icon,
            size: 18,
            color: disabled ? AppColors.neutral300 : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
