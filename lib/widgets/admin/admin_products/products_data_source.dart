import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/product_model.dart';
import '../../../models/category_model.dart';
import '../common/admin_card.dart';

class ProductsDataSource extends DataTableSource {
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final BuildContext context;
  final Function(ProductModel) onView;
  final Function(ProductModel) onEdit;
  final Function(ProductModel) onDelete;
  final String Function(int) formatPrice;

  ProductsDataSource({
    required this.products,
    required this.categories,
    required this.context,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.formatPrice,
  });

  String? _getCategoryName(String categoryId) {
    try {
      return categories.firstWhere((cat) => cat.id == categoryId).name;
    } catch (_) {
      return null;
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= products.length) return null;

    final product = products[index];
    final calculatedStatus = product.calculatedStatus;
    final isInStock = calculatedStatus == 'Còn hàng';
    final discount = product.discount;
    final categoryName = _getCategoryName(product.categoryId);

    return DataRow2(
      cells: [
        // Image
        DataCell(_ProductThumb(imageUrl: product.imageUrl)),

        // Name + discount badge
        DataCell(_NameCell(name: product.name, discountPercent: discount)),

        // Category
        DataCell(
          categoryName == null
              ? const Text(
                  '—',
                  style: TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 13,
                  ),
                )
              : AdminStatusPill.info(categoryName),
        ),

        // Price
        DataCell(
          Text(
            '${formatPrice(product.price)} ₫',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // Original price (lined-through if discounted)
        DataCell(
          product.originalPrice > product.price
              ? Text(
                  '${formatPrice(product.originalPrice)} ₫',
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColors.neutral400,
                    color: AppColors.neutral500,
                    fontSize: 12.5,
                  ),
                )
              : const Text(
                  '—',
                  style: TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 13,
                  ),
                ),
        ),

        // Quantity
        DataCell(_QuantityCell(quantity: product.quantity)),

        // Status pill
        DataCell(
          isInStock
              ? AdminStatusPill.success(calculatedStatus)
              : AdminStatusPill.danger(calculatedStatus),
        ),

        // Actions
        DataCell(
          _RowActions(
            onView: () => onView(product),
            onEdit: () => onEdit(product),
            onDelete: () => onDelete(product),
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => products.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

// ---------------------------------------------------------------------------
// Cell components
// ---------------------------------------------------------------------------

class _ProductThumb extends StatelessWidget {
  final String? imageUrl;
  const _ProductThumb({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: AppColors.primary500,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => const Icon(
                  Icons.image_outlined,
                  size: 18,
                  color: AppColors.neutral400,
                ),
              )
            : const Icon(
                Icons.image_outlined,
                size: 18,
                color: AppColors.neutral400,
              ),
      ),
    );
  }
}

class _NameCell extends StatelessWidget {
  final String name;
  final int discountPercent;
  const _NameCell({required this.name, required this.discountPercent});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
            color: AppColors.textPrimary,
            letterSpacing: -0.1,
          ),
        ),
        if (discountPercent > 0) ...[
          const SizedBox(height: 4),
          AdminStatusPill.danger('-$discountPercent%'),
        ],
      ],
    );
  }
}

class _QuantityCell extends StatelessWidget {
  final int quantity;
  const _QuantityCell({required this.quantity});

  @override
  Widget build(BuildContext context) {
    final low = quantity < 10;
    return Text(
      quantity.toString(),
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13.5,
        color: low ? AppColors.errorDark : AppColors.textPrimary,
      ),
    );
  }
}

class _RowActions extends StatelessWidget {
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RowActions({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconAction(
          icon: Icons.visibility_outlined,
          tooltip: 'Xem chi tiết',
          color: AppColors.info,
          onPressed: onView,
        ),
        AppSpacing.gapXs,
        _IconAction(
          icon: Icons.edit_outlined,
          tooltip: 'Chỉnh sửa',
          color: AppColors.primary600,
          onPressed: onEdit,
        ),
        AppSpacing.gapXs,
        _IconAction(
          icon: Icons.delete_outline_rounded,
          tooltip: 'Xóa',
          color: AppColors.error,
          onPressed: onDelete,
        ),
      ],
    );
  }
}

class _IconAction extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;

  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_IconAction> createState() => _IconActionState();
}

class _IconActionState extends State<_IconAction> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: SizedBox(
        width: 30,
        height: 30,
        child: Material(
          color: _hover
              ? widget.color.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: InkWell(
            onTap: widget.onPressed,
            onHover: (v) => setState(() => _hover = v),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Icon(widget.icon, size: 16, color: widget.color),
          ),
        ),
      ),
    );
  }
}
