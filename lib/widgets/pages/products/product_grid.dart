import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import 'product_card.dart';

/// Product grid customer – Modern Minimal.
///
/// Responsive: 2 cột mobile, 3 cột tablet, 4 cột desktop (4 nếu có sidebar
/// thì 3). Có empty state đẹp và breakpoint cho compact mode.
class ProductGrid extends StatelessWidget {
  final List<ProductModel> products;
  final List<CategoryModel> allCategories;
  final ValueChanged<ProductModel> onTap;
  final bool hasSidebar;

  const ProductGrid({
    super.key,
    required this.products,
    required this.allCategories,
    required this.onTap,
    this.hasSidebar = false,
  });

  String? _categoryName(String id) {
    try {
      return allCategories.firstWhere((c) => c.id == id).name;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const _EmptyState();
    }

    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    int cols;
    double aspectRatio;
    if (isMobile) {
      cols = 2;
      aspectRatio = 0.62;
    } else if (isTablet) {
      cols = 2;
      aspectRatio = 0.78;
    } else {
      cols = hasSidebar ? 3 : 4;
      aspectRatio = 0.78;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: aspectRatio,
      ),
      itemCount: products.length,
      cacheExtent: 600,
      itemBuilder: (_, i) {
        final p = products[i];
        return ProductCard(
          product: p,
          categoryName: _categoryName(p.categoryId),
          onTap: () => onTap(p),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl5,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(AppRadius.xl3),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 30,
              color: AppColors.primary600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Không tìm thấy sản phẩm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Thử bỏ bớt bộ lọc hoặc nhập từ khoá khác.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
