import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/category_model.dart';
import '../common/admin_card.dart';

/// Stats grid cho Categories – Modern Minimal.
class CategoriesStats extends StatelessWidget {
  final List<CategoryModel> categories;
  final bool isTablet;

  const CategoriesStats({
    super.key,
    required this.categories,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final total = categories.length;
    final visible = categories.where((c) => c.status == 'Hiển thị').length;
    final hidden = categories.where((c) => c.status == 'Ẩn').length;
    final totalProducts = categories.fold<int>(
      0,
      (sum, c) => sum + c.productCount,
    );

    final visiblePct = total == 0 ? 0 : ((visible / total) * 100).round();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isTablet ? 2 : 4,
      crossAxisSpacing: AppSpacing.lg,
      mainAxisSpacing: AppSpacing.lg,
      childAspectRatio: isTablet ? 2.4 : 2.0,
      children: [
        AdminStatCard(
          title: 'Tổng danh mục',
          value: total.toString(),
          icon: Icons.category_outlined,
          accent: AppColors.info,
        ),
        AdminStatCard(
          title: 'Đang hiển thị',
          value: visible.toString(),
          icon: Icons.visibility_outlined,
          accent: AppColors.success,
          hint: '$visiblePct%',
          hintFg: AppColors.successDark,
          hintBg: AppColors.successContainer,
        ),
        AdminStatCard(
          title: 'Đang ẩn',
          value: hidden.toString(),
          icon: Icons.visibility_off_outlined,
          accent: AppColors.warning,
        ),
        AdminStatCard(
          title: 'Tổng sản phẩm',
          value: _formatNumber(totalProducts),
          icon: Icons.inventory_2_outlined,
          accent: AppColors.primary500,
        ),
      ],
    );
  }

  static String _formatNumber(int n) => n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
}

/// Wrapper backward-compat: nhiều file mobile có thể vẫn import [CategoryStatCard].
class CategoryStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isTablet;

  const CategoryStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return AdminStatCard(
      title: title,
      value: value,
      icon: icon,
      accent: color,
    );
  }
}
