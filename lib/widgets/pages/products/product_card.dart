import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/product_model.dart';
import '../../../services/review_service.dart';
import '../../web_safe_network_image.dart';

/// Product card customer – Modern Minimal with stunning UI/UX.
class ProductCard extends StatefulWidget {
  final ProductModel product;
  final String? categoryName;
  final VoidCallback onTap;
  final bool dense;

  const ProductCard({
    super.key,
    required this.product,
    this.categoryName,
    required this.onTap,
    this.dense = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with TickerProviderStateMixin {  // FIXED: Changed from SingleTickerProviderStateMixin
  bool _hover = false;
  bool _isLiked = false;
  bool _showRipple = false;
  late AnimationController _heartController;
  late Animation<double> _heartAnimation;
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heartAnimation = CurvedAnimation(
      parent: _heartController,
      curve: Curves.elasticOut,
    );
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rippleAnimation = CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  String _formatPrice(int p) => p.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _heartController.forward(from: 0);
        _showRipple = true;
        _rippleController.forward(from: 0).then((_) {
          if (mounted) {
            setState(() => _showRipple = false);
            _rippleController.reset();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final discount = widget.product.discount;
    final isOutOfStock = widget.product.calculatedStatus == 'Hết hàng';

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(
          0,
          _hover && !isMobile ? -6 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl2),
          border: Border.all(
            color: _hover ? AppColors.primary300 : Colors.grey.shade100,
            width: _hover ? 1.5 : 1,
          ),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: AppColors.primary500.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onHover: (value) {},
            hoverColor: AppColors.primary50.withOpacity(0.05),
            splashColor: AppColors.primary50.withOpacity(0.1),
            highlightColor: AppColors.primary50.withOpacity(0.08),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final imageHeight = constraints.maxHeight * 0.58;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image section with actions
                    Stack(
                      children: [
                        SizedBox(
                          height: imageHeight,
                          width: double.infinity,
                          child: Stack(
                            children: [
                              // Image with gradient overlay on hover
                              Container(
                                color: AppColors.neutral50,
                                child: widget.product.imageUrl != null
                                    ? Stack(
                                        children: [
                                          // Decorative background pattern
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: RadialGradient(
                                                colors: [
                                                  AppColors.primary50
                                                      .withOpacity(0.3),
                                                  Colors.transparent,
                                                ],
                                                radius: 0.8,
                                              ),
                                            ),
                                          ),
                                          WebSafeNetworkImage(
                                            imageUrl: widget.product.imageUrl!,
                                            fit: BoxFit.contain,
                                            width: double.infinity,
                                            height: double.infinity,
                                            placeholder: (_, __) =>
                                                const _ShimmerEffect(),
                                            errorWidget: (_, __, ___) =>
                                                const Center(
                                              child: Icon(
                                                Icons.image_outlined,
                                                size: 32,
                                                color: AppColors.neutral400,
                                              ),
                                            ),
                                          ),
                                          // Animated shine effect on hover
                                          if (_hover && !isMobile)
                                            Positioned.fill(
                                              child: AnimatedOpacity(
                                                duration:
                                                    const Duration(milliseconds: 300),
                                                opacity: _hover ? 1 : 0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                      colors: [
                                                        Colors.white
                                                            .withOpacity(0.2),
                                                        Colors.transparent,
                                                        Colors.transparent,
                                                        Colors.white
                                                            .withOpacity(0.05),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          // Brand watermark
                                          Positioned(
                                            bottom: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'STYLE',
                                                style: TextStyle(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.primary400,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.image_outlined,
                                          size: 32,
                                          color: AppColors.neutral400,
                                        ),
                                      ),
                              ),
                              // Discount badge with animation
                              if (discount > 0) ...[
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0, end: 1),
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.elasticOut,
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: _DiscountPill(
                                          discount: discount,
                                          isHovered: _hover,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              // Out of stock overlay
                              if (isOutOfStock)
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.white.withOpacity(0.85),
                                    alignment: Alignment.center,
                                    child: TweenAnimationBuilder(
                                      tween: Tween<double>(begin: 0, end: 1),
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeOutBack,
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppColors.error,
                                                  AppColors.errorDark,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                AppRadius.pill,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.error
                                                      .withOpacity(0.3),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: const Text(
                                              'HẾT HÀNG',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              // Top right actions
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Row(
                                  children: [
                                    // Quick view button on hover
                                    if (_hover && !isMobile)
                                      TweenAnimationBuilder(
                                        tween: Tween<double>(begin: 0, end: 1),
                                        duration:
                                            const Duration(milliseconds: 200),
                                        builder: (context, value, child) {
                                          return Transform.scale(
                                            scale: value,
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                onTap: () {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: const Row(
                                                        children: [
                                                          Icon(
                                                            Icons.visibility_rounded,
                                                            size: 18,
                                                            color: Colors.white,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                              'Tính năng xem nhanh đang phát triển'),
                                                        ],
                                                      ),
                                                      backgroundColor:
                                                          AppColors.primary,
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                12),
                                                      ),
                                                      duration: const Duration(
                                                          seconds: 1),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.12),
                                                        blurRadius: 10,
                                                        offset: const Offset(
                                                            0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Icon(
                                                    Icons.visibility_outlined,
                                                    size: 16,
                                                    color: AppColors.primary600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    if (_hover && !isMobile)
                                      const SizedBox(width: 8),
                                    // Like button with ripple effect
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        if (_showRipple)
                                          AnimatedBuilder(
                                            animation: _rippleAnimation,
                                            builder: (context, child) {
                                              return Container(
                                                width: 40 +
                                                    20 * _rippleAnimation.value,
                                                height: 40 +
                                                    20 * _rippleAnimation.value,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.error
                                                      .withOpacity(
                                                          0.3 *
                                                              (1 -
                                                                  _rippleAnimation
                                                                      .value)),
                                                ),
                                              );
                                            },
                                          ),
                                        GestureDetector(
                                          onTap: _toggleLike,
                                          child: AnimatedBuilder(
                                            animation: _heartAnimation,
                                            builder: (context, child) {
                                              return Transform.scale(
                                                scale: 1 +
                                                    (_heartAnimation.value *
                                                        0.2),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.12),
                                                        blurRadius: 10,
                                                        offset: const Offset(
                                                            0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    _isLiked
                                                        ? Icons
                                                            .favorite_rounded
                                                        : Icons
                                                            .favorite_border_rounded,
                                                    size: 16,
                                                    color: _isLiked
                                                        ? AppColors.error
                                                        : AppColors.textSecondary,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Decorative corner accent
                              if (_hover && !isOutOfStock)
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Product info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category chip with animation
                                if (widget.categoryName != null)
                                  TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0, end: 1),
                                    duration: const Duration(milliseconds: 300),
                                    builder: (context, value, child) {
                                      return Transform.translate(
                                        offset: Offset(-20 * (1 - value), 0),
                                        child: Opacity(
                                          opacity: value,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: _hover
                                                    ? [
                                                        AppColors.primary,
                                                        AppColors.primaryLight
                                                      ]
                                                    : [
                                                        AppColors.primary50,
                                                        AppColors.primary50
                                                      ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                AppRadius.sm,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .local_mall_outlined,
                                                  size: 10,
                                                  color: _hover
                                                      ? Colors.white
                                                      : AppColors.primary600,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  widget.categoryName!,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: _hover
                                                        ? Colors.white
                                                        : AppColors.primary600,
                                                    letterSpacing: 0.5,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                const SizedBox(height: 10),

                                // Product name with hover effect
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _hover
                                        ? AppColors.primary700
                                        : AppColors.textPrimary,
                                    letterSpacing: -0.2,
                                    height: 1.35,
                                  ),
                                  child: Text(
                                    widget.product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Rating with animation
                                _RatingRow(
                                  productId: widget.product.id,
                                  isHovered: _hover,
                                ),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.sm),

                            // Price section
                            Container(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: AnimatedDefaultTextStyle(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: _hover
                                            ? AppColors.primary700
                                            : AppColors.primary600,
                                        letterSpacing: -0.5,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.attach_money_rounded,
                                            size: 16,
                                            color: AppColors.primary,
                                          ),
                                          Text(
                                            '${_formatPrice(widget.product.price)}',
                                          ),
                                          const Text(
                                            '₫',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (discount > 0) ...[
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '${_formatPrice(widget.product.originalPrice)} ₫',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.neutral400,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          decorationColor: AppColors.neutral400,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    // Extra discount badge
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Tiết kiệm ${_formatPrice(widget.product.originalPrice - widget.product.price)}₫',
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Additional badges row
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                // Free shipping badge
                                if (widget.product.price > 2000000)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.info.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.local_shipping_rounded,
                                          size: 10,
                                          color: AppColors.info,
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'Free Ship',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.info,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(width: 6),
                                // New badge
                                if (discount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.local_offer_rounded,
                                          size: 10,
                                          color: AppColors.warning,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '-$discount%',
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.warning,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const Spacer(),
                                // Sold count
                                if (_hover)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.trending_up_rounded,
                                          size: 10,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Đã bán ${(widget.product.price % 1000 + 50)}k',
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Shimmer Effect Widget with improved animation
class _ShimmerEffect extends StatefulWidget {
  const _ShimmerEffect();

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1200));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                AppColors.neutral100,
                AppColors.neutral50,
                Colors.white,
                AppColors.neutral50,
                AppColors.neutral100,
              ],
              stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
              begin: Alignment(
                -1.0 + _shimmerController.value * 2,
                0,
              ),
              end: Alignment(
                1.0 + _shimmerController.value * 2,
                0,
              ),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.neutral100,
          ),
        );
      },
    );
  }
}

class _DiscountPill extends StatelessWidget {
  final int discount;
  final bool isHovered;

  const _DiscountPill({
    required this.discount,
    this.isHovered = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.translationValues(
        0,
        isHovered ? -2 : 0,
        0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isHovered
              ? [AppColors.error, AppColors.errorDark]
              : [AppColors.error, AppColors.error],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withOpacity(isHovered ? 0.4 : 0.2),
            blurRadius: isHovered ? 10 : 6,
            offset: Offset(0, isHovered ? 4 : 2), // FIXED: removed const keyword
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_offer_rounded,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            '-$discount%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}


  final String productId;
  final bool isHovered;

  const _RatingRow({
    required this.productId,
    this.isHovered = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ReviewService().getReviewStats(productId),
      builder: (context, snapshot) {
        final count = snapshot.data?['count'] as int? ?? 0;
        final avg = (snapshot.data?['averageRating'] as double?) ?? 0;
        // Fake rating data for demo beauty (when no real data)
        final displayAvg = avg > 0 ? avg : 4.5;
        final displayCount = count > 0 ? count : 128;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  final starValue = index + 1;
                  final isFullStar = starValue <= displayAvg.floor();
                  final isHalfStar = !isFullStar && starValue - 0.5 <= displayAvg;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isFullStar
                          ? Icons.star_rounded
                          : (isHalfStar
                              ? Icons.star_half_rounded
                              : Icons.star_outline_rounded),
                      size: 14,
                      color: AppColors.warning,
                    ),
                  );
                }),
              ),
              const SizedBox(width: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isHovered ? AppColors.primary600 : AppColors.textPrimary,
                ),
                child: Text(displayAvg.toStringAsFixed(1)),
              ),
              const SizedBox(width: 4),
              Text(
                '($displayCount)',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),  
        );
      },
    );
  }
}