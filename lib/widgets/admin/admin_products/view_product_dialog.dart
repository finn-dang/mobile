import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import '../common/admin_card.dart';
import '../common/admin_page_header.dart';

/// View Product Dialog – Modern Minimal.
///
/// Layout:
///   [Header] tên + danh mục + nút đóng
///   [Body]   ảnh chính lớn + thumb dải | bảng "definition list" thông tin
///            -> Mô tả -> Phiên bản & Màu -> Tuỳ chọn -> Thông số
///   [Footer] nút "Đóng" outline + (option) "Chỉnh sửa" primary
class ViewProductDialog extends StatelessWidget {
  final ProductModel product;
  final List<CategoryModel> categories;
  final String Function(int) formatPrice;
  final bool isMobile;
  final VoidCallback? onEdit;

  const ViewProductDialog({
    super.key,
    required this.product,
    required this.categories,
    required this.formatPrice,
    this.isMobile = false,
    this.onEdit,
  });

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String? _getCategoryName(String? id) {
    if (id == null) return null;
    try {
      return categories.firstWhere((c) => c.id == id).name;
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static Color _hexToColor(String hex) {
    final code = hex.replaceAll('#', '');
    if (code.length == 6) return Color(int.parse('FF$code', radix: 16));
    if (code.length == 3) {
      final r = code[0] * 2;
      final g = code[1] * 2;
      final b = code[2] * 2;
      return Color(int.parse('FF$r$g$b', radix: 16));
    }
    return AppColors.neutral400;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final categoryName = _getCategoryName(product.categoryId);
    final childCategoryName = _getCategoryName(product.childCategoryId);
    final isInStock = product.calculatedStatus == 'Còn hàng';
    final discount = product.discount;

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.lg : AppSpacing.xl3,
        vertical: AppSpacing.xl2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl2),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 920,
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogHeader(
              productName: product.name,
              categoryPath: [categoryName, childCategoryName]
                  .whereType<String>()
                  .join(' › '),
              isInStock: isInStock,
              onClose: () => Navigator.of(context).pop(),
            ),
            const Divider(height: 1, color: AppColors.adminBorder),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  isMobile ? AppSpacing.lg : AppSpacing.xl,
                ),
                child: isMobile
                    ? _buildMobileBody(
                        categoryName: categoryName,
                        childCategoryName: childCategoryName,
                        isInStock: isInStock,
                        discount: discount,
                      )
                    : _buildDesktopBody(
                        categoryName: categoryName,
                        childCategoryName: childCategoryName,
                        isInStock: isInStock,
                        discount: discount,
                      ),
              ),
            ),
            const Divider(height: 1, color: AppColors.adminBorder),
            _DialogFooter(
              onClose: () => Navigator.of(context).pop(),
              onEdit: onEdit,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Body layouts
  // ---------------------------------------------------------------------------

  Widget _buildDesktopBody({
    required String? categoryName,
    required String? childCategoryName,
    required bool isInStock,
    required int discount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: _GallerySection(product: product)),
            AppSpacing.gapXl,
            Expanded(
              flex: 4,
              child: _BasicInfoSection(
                product: product,
                categoryName: categoryName,
                childCategoryName: childCategoryName,
                isInStock: isInStock,
                discount: discount,
                formatPrice: formatPrice,
                formatDate: _formatDate,
              ),
            ),
          ],
        ),
        if (product.description != null && product.description!.isNotEmpty) ...[
          AppSpacing.gapLg,
          _DescriptionSection(text: product.description!),
        ],
        if ((product.versions ?? const []).isNotEmpty ||
            (product.colors ?? const []).isNotEmpty) ...[
          AppSpacing.gapLg,
          _VariantsSection(product: product),
        ],
        if ((product.options ?? const []).isNotEmpty) ...[
          AppSpacing.gapLg,
          _OptionsSection(product: product, formatPrice: formatPrice),
        ],
        if ((product.specifications ?? const []).isNotEmpty) ...[
          AppSpacing.gapLg,
          _SpecificationsSection(product: product),
        ],
      ],
    );
  }

  Widget _buildMobileBody({
    required String? categoryName,
    required String? childCategoryName,
    required bool isInStock,
    required int discount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GallerySection(product: product, isMobile: true),
        AppSpacing.gapLg,
        _BasicInfoSection(
          product: product,
          categoryName: categoryName,
          childCategoryName: childCategoryName,
          isInStock: isInStock,
          discount: discount,
          formatPrice: formatPrice,
          formatDate: _formatDate,
        ),
        if (product.description != null && product.description!.isNotEmpty) ...[
          AppSpacing.gapLg,
          _DescriptionSection(text: product.description!),
        ],
        if ((product.versions ?? const []).isNotEmpty ||
            (product.colors ?? const []).isNotEmpty) ...[
          AppSpacing.gapLg,
          _VariantsSection(product: product),
        ],
        if ((product.options ?? const []).isNotEmpty) ...[
          AppSpacing.gapLg,
          _OptionsSection(product: product, formatPrice: formatPrice),
        ],
        if ((product.specifications ?? const []).isNotEmpty) ...[
          AppSpacing.gapLg,
          _SpecificationsSection(product: product),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Header / Footer
// ---------------------------------------------------------------------------

class _DialogHeader extends StatelessWidget {
  final String productName;
  final String categoryPath;
  final bool isInStock;
  final VoidCallback onClose;

  const _DialogHeader({
    required this.productName,
    required this.categoryPath,
    required this.isInStock,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Chi tiết sản phẩm',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.4,
                      ),
                    ),
                    AppSpacing.gapSm,
                    isInStock
                        ? AdminStatusPill.success('Còn hàng')
                        : AdminStatusPill.danger('Hết hàng'),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                    height: 1.25,
                  ),
                ),
                if (categoryPath.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    categoryPath,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Đóng',
            icon: const Icon(
              Icons.close_rounded,
              size: 20,
              color: AppColors.neutral500,
            ),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _DialogFooter extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback? onEdit;
  const _DialogFooter({required this.onClose, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AdminSecondaryButton(
            icon: Icons.close_rounded,
            label: 'Đóng',
            onPressed: onClose,
          ),
          if (onEdit != null) ...[
            AppSpacing.gapMd,
            AdminPrimaryButton(
              icon: Icons.edit_outlined,
              label: 'Chỉnh sửa',
              onPressed: onEdit!,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gallery (main image + thumbs)
// ---------------------------------------------------------------------------

class _GallerySection extends StatefulWidget {
  final ProductModel product;
  final bool isMobile;
  const _GallerySection({required this.product, this.isMobile = false});

  @override
  State<_GallerySection> createState() => _GallerySectionState();
}

class _GallerySectionState extends State<_GallerySection> {
  late int _activeIndex;
  late List<String> _allImages;

  @override
  void initState() {
    super.initState();
    _allImages = [
      if (widget.product.imageUrl != null) widget.product.imageUrl!,
      ...?widget.product.imageUrls,
    ];
    _activeIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_allImages.isEmpty) {
      return AdminCard(
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: widget.isMobile ? 220 : 320,
          width: double.infinity,
          child: const _ImageError(),
        ),
      );
    }

    return Column(
      children: [
        // Main image
        Container(
          height: widget.isMobile ? 240 : 360,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.adminBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: CachedNetworkImage(
              imageUrl: _allImages[_activeIndex],
              fit: BoxFit.contain,
              placeholder: (_, __) => const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary500,
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => const _ImageError(),
            ),
          ),
        ),
        if (_allImages.length > 1) ...[
          AppSpacing.gapMd,
          SizedBox(
            height: widget.isMobile ? 64 : 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _allImages.length,
              separatorBuilder: (_, __) => AppSpacing.gapSm,
              itemBuilder: (_, i) => _Thumb(
                url: _allImages[i],
                isActive: i == _activeIndex,
                size: widget.isMobile ? 64 : 76,
                onTap: () => setState(() => _activeIndex = i),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  final String url;
  final bool isActive;
  final double size;
  final VoidCallback onTap;

  const _Thumb({
    required this.url,
    required this.isActive,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isActive ? AppColors.primary500 : AppColors.adminBorder,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md - 1),
          child: CachedNetworkImage(
            imageUrl: url,
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
            errorWidget: (_, __, ___) => const _ImageError(),
          ),
        ),
      ),
    );
  }
}

class _ImageError extends StatelessWidget {
  const _ImageError();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.image_outlined,
        size: 22,
        color: AppColors.neutral400,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Basic info – Definition list
// ---------------------------------------------------------------------------

class _BasicInfoSection extends StatelessWidget {
  final ProductModel product;
  final String? categoryName;
  final String? childCategoryName;
  final bool isInStock;
  final int discount;
  final String Function(int) formatPrice;
  final String Function(DateTime) formatDate;

  const _BasicInfoSection({
    required this.product,
    required this.categoryName,
    required this.childCategoryName,
    required this.isInStock,
    required this.discount,
    required this.formatPrice,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price block
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${formatPrice(product.price)} ₫',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary600,
                  letterSpacing: -0.6,
                  height: 1.1,
                ),
              ),
              if (product.originalPrice > product.price) ...[
                AppSpacing.gapSm,
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    '${formatPrice(product.originalPrice)} ₫',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.neutral400,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppColors.neutral400,
                    ),
                  ),
                ),
              ],
              if (discount > 0) ...[
                AppSpacing.gapSm,
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: AdminStatusPill.danger('-$discount%'),
                ),
              ],
            ],
          ),
          AppSpacing.gapMd,
          const Divider(height: 1, color: AppColors.neutral100),
          // Definition list
          _DLRow(label: 'Danh mục', value: categoryName ?? '—'),
          if (childCategoryName != null)
            _DLRow(label: 'Danh mục con', value: childCategoryName!),
          _DLRow(label: 'Số lượng', value: product.quantity.toString()),
          _DLRow(
            label: 'Trạng thái',
            valueWidget: isInStock
                ? AdminStatusPill.success('Còn hàng')
                : AdminStatusPill.danger('Hết hàng'),
          ),
          _DLRow(
            label: 'Đánh giá',
            valueWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 3),
                Text(
                  product.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  ' /5',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _DLRow(label: 'Đã bán', value: product.sold.toString()),
          _DLRow(label: 'Tạo ngày', value: formatDate(product.createdAt)),
          _DLRow(label: 'Cập nhật', value: formatDate(product.updatedAt)),
        ],
      ),
    );
  }
}

/// Row "Label : Value" gọn gàng – chuẩn definition list.
class _DLRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _DLRow({required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: valueWidget ??
                Text(
                  value ?? '—',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Description
// ---------------------------------------------------------------------------

class _DescriptionSection extends StatelessWidget {
  final String text;
  const _DescriptionSection({required this.text});

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionTitle(
            title: 'Mô tả',
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
          ),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Variants (versions + colors)
// ---------------------------------------------------------------------------

class _VariantsSection extends StatelessWidget {
  final ProductModel product;
  const _VariantsSection({required this.product});

  @override
  Widget build(BuildContext context) {
    final versions = product.versions ?? const [];
    final colors = product.colors ?? const [];

    return AdminCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionTitle(
            title: 'Biến thể',
            description: 'Phiên bản và màu sắc có sẵn.',
            padding: EdgeInsets.only(bottom: AppSpacing.md),
          ),
          if (versions.isNotEmpty) ...[
            const Text(
              'Phiên bản',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final v in versions)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.adminBorder),
                    ),
                    child: Text(
                      v,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (versions.isNotEmpty && colors.isNotEmpty) AppSpacing.gapMd,
          if (colors.isNotEmpty) ...[
            const Text(
              'Màu sắc',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final c in colors)
                  Container(
                    padding: const EdgeInsets.fromLTRB(6, 5, 12, 5),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.adminBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: ViewProductDialog._hexToColor(
                              c['hex'] as String,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.adminBorder,
                              width: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          c['name'] as String,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Options table
// ---------------------------------------------------------------------------

class _OptionsSection extends StatelessWidget {
  final ProductModel product;
  final String Function(int) formatPrice;

  const _OptionsSection({required this.product, required this.formatPrice});

  @override
  Widget build(BuildContext context) {
    final options = product.options ?? const [];

    return AdminCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminSectionTitle(
            title: 'Tuỳ chọn',
            description: '${options.length} tổ hợp phiên bản × màu sắc.',
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
          ),
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, color: AppColors.neutral100),
            _OptionRow(option: options[i], formatPrice: formatPrice),
          ],
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final Map<String, dynamic> option;
  final String Function(int) formatPrice;
  const _OptionRow({required this.option, required this.formatPrice});

  @override
  Widget build(BuildContext context) {
    final version = option['version'] as String;
    final colorName = option['colorName'] as String;
    final colorHex = option['colorHex'] as String;
    final originalPrice = option['originalPrice'] as int;
    final discount = option['discount'] as int;
    final quantity = option['quantity'] as int? ?? 0;
    final finalPrice = originalPrice - (originalPrice * discount ~/ 100);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: ViewProductDialog._hexToColor(colorHex),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.adminBorder, width: 0.5),
            ),
          ),
          AppSpacing.gapSm,
          Expanded(
            child: Text(
              '$version • $colorName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          AppSpacing.gapSm,
          Text(
            '${formatPrice(finalPrice)} ₫',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary600,
            ),
          ),
          if (discount > 0) ...[
            AppSpacing.gapSm,
            AdminStatusPill.danger('-$discount%'),
          ],
          AppSpacing.gapMd,
          Text(
            'SL: $quantity',
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Specifications table
// ---------------------------------------------------------------------------

class _SpecificationsSection extends StatelessWidget {
  final ProductModel product;
  const _SpecificationsSection({required this.product});

  @override
  Widget build(BuildContext context) {
    final specs = product.specifications ?? const [];

    return AdminCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminSectionTitle(
            title: 'Thông số kỹ thuật',
            description: '${specs.length} thông số.',
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.adminBorder),
            ),
            child: Column(
              children: [
                for (var i = 0; i < specs.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, color: AppColors.neutral100),
                  _SpecRow(
                    label: specs[i]['label'] ?? '',
                    value: specs[i]['value'] ?? '',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;
  const _SpecRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
