import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/product_model.dart';
import 'buy_action_bar.dart';
import 'quantity_selector.dart';
import 'variant_selector.dart';

/// Khu vực thông tin + chọn variant + nút mua – Modern Minimal with enhanced UI/UX
class ProductInfoPanel extends StatefulWidget {
  final ProductModel product;
  final int currentPrice;
  final int currentOriginalPrice;
  final int discount;
  final double averageRating;
  final int reviewCount;

  final String? selectedVersion;
  final String? selectedColor;
  final ValueChanged<String> onVersionSelected;
  final ValueChanged<String> onColorSelected;
  final bool Function(String version) isVersionAvailable;
  final bool Function(String color) isColorAvailable;
  final int currentStock;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  final bool isLoading;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final bool stackedActions;

  const ProductInfoPanel({
    super.key,
    required this.product,
    required this.currentPrice,
    required this.currentOriginalPrice,
    required this.discount,
    required this.averageRating,
    required this.reviewCount,
    required this.selectedVersion,
    required this.selectedColor,
    required this.onVersionSelected,
    required this.onColorSelected,
    required this.isVersionAvailable,
    required this.isColorAvailable,
    required this.currentStock,
    required this.quantity,
    required this.onQuantityChanged,
    required this.isLoading,
    required this.onAddToCart,
    required this.onBuyNow,
    this.stackedActions = false,
  });

  @override
  State<ProductInfoPanel> createState() => _ProductInfoPanelState();
}

class _ProductInfoPanelState extends State<ProductInfoPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatPrice(int p) => p.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );

  Color _hexToColor(String hex) {
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

  void _showStockWarning() {
    if (widget.currentStock <= 5 && widget.currentStock > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.inventory_2_outlined, size: 20, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Chỉ còn ${widget.currentStock} sản phẩm trong kho!',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          margin: const EdgeInsets.all(AppSpacing.md),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final versions = widget.product.versions ?? const [];
    final colors = widget.product.colors ?? const [];
    final isOutOfStock = widget.currentStock == 0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + sold + rating
            _buildTitleSection(),
            const SizedBox(height: AppSpacing.lg),

            // Price block with animation
            _PriceBlock(
              currentPrice: widget.currentPrice,
              originalPrice: widget.currentOriginalPrice,
              discount: widget.discount,
              formatPrice: _formatPrice,
            ),

            // Stock indicator
            if (widget.currentStock > 0 && widget.currentStock <= 10)
              _StockIndicator(stock: widget.currentStock),

            // Versions
            if (versions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              _buildVariantSection(
                title: 'Phiên bản',
                selected: widget.selectedVersion,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final v in versions)
                    VersionChip(
                      version: v,
                      isSelected: widget.selectedVersion == v,
                      isAvailable: widget.isVersionAvailable(v),
                      onTap: () {
                        widget.onVersionSelected(v);
                        _animationController.forward(from: 0);
                      },
                    ),
                ],
              ),
            ],

            // Colors
            if (colors.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildVariantSection(
                title: 'Màu sắc',
                selected: widget.selectedColor,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in colors)
                    ColorOption(
                      name: c['name'] as String,
                      color: _hexToColor(c['hex'] as String),
                      isSelected: widget.selectedColor == c['name'],
                      isAvailable: widget.isColorAvailable(c['name'] as String),
                      onTap: () {
                        widget.onColorSelected(c['name'] as String);
                        _animationController.forward(from: 0);
                      },
                    ),
                ],
              ),
            ],

            // Quantity selector with animated counter
            const SizedBox(height: AppSpacing.xl),
            _buildQuantitySection(isOutOfStock),
            const SizedBox(height: AppSpacing.xl),

            // Action buttons with loading state
            BuyActionBar(
              isOutOfStock: isOutOfStock,
              isLoading: widget.isLoading,
              onAddToCart: () {
                if (!isOutOfStock) {
                  _showStockWarning();
                  widget.onAddToCart();
                }
              },
              onBuyNow: () {
                if (!isOutOfStock) widget.onBuyNow();
              },
              stacked: widget.stackedActions || isMobile,
            ),

            // Trust badges
            const SizedBox(height: AppSpacing.lg),
            const _TrustBadges(),

            // Free shipping threshold
            if (widget.currentPrice < 500000) ...[
              const SizedBox(height: AppSpacing.md),
              _FreeShippingThreshold(currentPrice: widget.currentPrice),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            // Rating
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    widget.averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.reviewCount} đánh giá',
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
            // Divider
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              width: 1,
              height: 12,
              color: AppColors.neutral200,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_outlined,
                  size: 14,
                  color: AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  'Đã bán ${widget.product.sold}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVariantSection({
    required String title,
    required String? selected,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (selected != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              selected,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuantitySection(bool isOutOfStock) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Số lượng',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            if (widget.currentStock > 0 && widget.currentStock <= 5)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 12,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Chỉ còn ${widget.currentStock}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        QuantitySelector(
          value: widget.quantity,
          max: widget.currentStock,
          enabled: !isOutOfStock,
          onChanged: (value) {
            widget.onQuantityChanged(value);
            if (value == widget.currentStock && widget.currentStock <= 5) {
              _showStockWarning();
            }
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Enhanced Price block with animation
// ---------------------------------------------------------------------------

class _PriceBlock extends StatefulWidget {
  final int currentPrice;
  final int originalPrice;
  final int discount;
  final String Function(int) formatPrice;

  const _PriceBlock({
    required this.currentPrice,
    required this.originalPrice,
    required this.discount,
    required this.formatPrice,
  });

  @override
  State<_PriceBlock> createState() => _PriceBlockState();
}

class _PriceBlockState extends State<_PriceBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(_PriceBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPrice != widget.currentPrice) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary50,
                  AppColors.primary50.withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.primary200, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary200.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Giá bán',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.formatPrice(widget.currentPrice)} ₫',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary600,
                          letterSpacing: -0.7,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.discount > 0) ...[
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.error.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'GIẢM -${widget.discount}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${widget.formatPrice(widget.originalPrice)} ₫',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.neutral500,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.neutral400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Stock indicator
// ---------------------------------------------------------------------------

class _StockIndicator extends StatelessWidget {
  final int stock;

  const _StockIndicator({required this.stock});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: stock <= 2 ? AppColors.errorContainer : AppColors.warningContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: stock <= 2 ? AppColors.error : AppColors.warning,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            stock <= 2 ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
            size: 16,
            color: stock <= 2 ? AppColors.error : AppColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              stock <= 2
                  ? '⚠️ Sắp hết hàng! Chỉ còn $stock sản phẩm.'
                  : '🔥 Hàng hot! Chỉ còn $stock sản phẩm trong kho.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: stock <= 2 ? AppColors.error : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Free shipping threshold
// ---------------------------------------------------------------------------

class _FreeShippingThreshold extends StatelessWidget {
  final int currentPrice;

  const _FreeShippingThreshold({required this.currentPrice});

  @override
  Widget build(BuildContext context) {
    final remaining = 500000 - currentPrice;
    final progress = (currentPrice / 500000).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_shipping_outlined,
                size: 16,
                color: AppColors.primary600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  remaining > 0
                      ? 'Thêm ${(remaining / 1000).toStringAsFixed(0)}k để được miễn phí vận chuyển'
                      : '🎉 Bạn đã được miễn phí vận chuyển!',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.neutral200,
              color: AppColors.primary500,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Enhanced Trust badges
// ---------------------------------------------------------------------------

class _TrustBadges extends StatelessWidget {
  const _TrustBadges();

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    if (isMobile) {
      return Column(
        children: const [
          _TrustItem(
            icon: Icons.local_shipping_outlined,
            title: 'Miễn phí vận chuyển',
            subtitle: 'Cho đơn từ 500K',
          ),
          SizedBox(height: 8),
          _TrustItem(
            icon: Icons.verified_outlined,
            title: 'Chính hãng 100%',
            subtitle: 'Hoàn tiền nếu lỗi',
          ),
          SizedBox(height: 8),
          _TrustItem(
            icon: Icons.assignment_return_outlined,
            title: 'Đổi trả 30 ngày',
            subtitle: 'Cho hàng lỗi',
          ),
        ],
      );
    }
    
    return Row(
      children: const [
        Expanded(child: _TrustItem(
          icon: Icons.local_shipping_outlined,
          title: 'Miễn phí vận chuyển',
          subtitle: 'Cho đơn từ 500K',
        )),
        SizedBox(width: 8),
        Expanded(child: _TrustItem(
          icon: Icons.verified_outlined,
          title: 'Chính hãng 100%',
          subtitle: 'Hoàn tiền nếu lỗi',
        )),
        SizedBox(width: 8),
        Expanded(child: _TrustItem(
          icon: Icons.assignment_return_outlined,
          title: 'Đổi trả 30 ngày',
          subtitle: 'Cho hàng lỗi',
        )),
      ],
    );
  }
}

class _TrustItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TrustItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  State<_TrustItem> createState() => _TrustItemState();
}

class _TrustItemState extends State<_TrustItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.primary50 : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _isHovered ? AppColors.primary200 : AppColors.adminBorder,
            width: 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: AppColors.primary200.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                widget.icon,
                size: 18,
                color: AppColors.primary600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _isHovered ? AppColors.primary600 : AppColors.textPrimary,
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}