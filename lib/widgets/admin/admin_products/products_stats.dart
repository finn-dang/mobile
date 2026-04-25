import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/product_model.dart';
import '../common/admin_card.dart';

/// Stats grid – Modern Minimal.
///
/// 4 ô đều nhau, dùng chung [AdminStatCard] với accent màu theo trạng thái:
/// • Tổng sản phẩm – info
/// • Còn hàng       – success
/// • Hết hàng       – error
/// • Tổng giá trị  – primary
class ProductsStats extends StatelessWidget {
  final List<ProductModel> products;
  final bool isTablet;
  final String Function(int) formatPrice;

  const ProductsStats({
    super.key,
    required this.products,
    required this.isTablet,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final total = products.length;
    final inStock =
        products.where((p) => p.calculatedStatus == 'Còn hàng').length;
    final outOfStock =
        products.where((p) => p.calculatedStatus == 'Hết hàng').length;
    final totalValue = products.fold<int>(
      0,
      (sum, p) => sum + (p.price * p.quantity),
    );

    final inStockPct = total == 0 ? 0 : ((inStock / total) * 100).round();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isTablet ? 2 : 4,
      crossAxisSpacing: AppSpacing.lg,
      mainAxisSpacing: AppSpacing.lg,
      childAspectRatio: isTablet ? 2.4 : 2.0,
      children: [
        AdminStatCard(
          title: 'Tổng sản phẩm',
          value: total.toString(),
          icon: Icons.inventory_2_outlined,
          accent: AppColors.info,
        ),
        AdminStatCard(
          title: 'Còn hàng',
          value: inStock.toString(),
          icon: Icons.check_circle_outline_rounded,
          accent: AppColors.success,
          hint: '$inStockPct%',
          hintFg: AppColors.successDark,
          hintBg: AppColors.successContainer,
        ),
        AdminStatCard(
          title: 'Hết hàng',
          value: outOfStock.toString(),
          icon: Icons.remove_circle_outline_rounded,
          accent: AppColors.error,
        ),
        AdminStatCard(
          title: 'Tổng giá trị',
          value: '${formatPrice(totalValue)} đ',
          icon: Icons.account_balance_wallet_outlined,
          accent: AppColors.primary500,
        ),
      ],
    );
  }
}
