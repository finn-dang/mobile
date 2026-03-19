import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/category_model.dart';
import 'filter_sidebar.dart';

/// Bottom sheet hiển thị filter sidebar trên mobile.
class MobileFilterSheet extends StatelessWidget {
  final TextEditingController searchController;
  final List<CategoryModel> parentCategories;
  final List<CategoryModel> childCategories;
  final String? selectedParentId;
  final String? selectedChildId;
  final ValueChanged<String?> onParentSelected;
  final ValueChanged<String?> onChildSelected;
  final RangeValues priceRange;
  final double minPrice;
  final double maxPrice;
  final ValueChanged<RangeValues> onPriceChanged;
  final VoidCallback onReset;
  final int totalResults;

  const MobileFilterSheet({
    super.key,
    required this.searchController,
    required this.parentCategories,
    required this.childCategories,
    required this.selectedParentId,
    required this.selectedChildId,
    required this.onParentSelected,
    required this.onChildSelected,
    required this.priceRange,
    required this.minPrice,
    required this.maxPrice,
    required this.onPriceChanged,
    required this.onReset,
    required this.totalResults,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.xl2),
              topRight: Radius.circular(AppRadius.xl2),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Bộ lọc',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AppColors.neutral500,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.adminBorder),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: FilterSidebar(
                    searchController: searchController,
                    parentCategories: parentCategories,
                    childCategories: childCategories,
                    selectedParentId: selectedParentId,
                    selectedChildId: selectedChildId,
                    onParentSelected: onParentSelected,
                    onChildSelected: onChildSelected,
                    priceRange: priceRange,
                    minPrice: minPrice,
                    maxPrice: maxPrice,
                    onPriceChanged: onPriceChanged,
                    onReset: onReset,
                    totalResults: totalResults,
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: AppColors.primary500,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              'Xem $totalResults sản phẩm',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
