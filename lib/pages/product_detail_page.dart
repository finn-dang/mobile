import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../config/colors.dart';
import '../config/spacing.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../services/review_service.dart';
import '../widgets/footer.dart';
import '../widgets/pages/product_detail/product_description.dart';
import '../widgets/pages/product_detail/product_gallery.dart';
import '../widgets/pages/product_detail/product_info_panel.dart';

/// Trang chi tiết sản phẩm – Modern Minimal.
///
/// Layout: gallery trái + info panel phải (desktop), stacked (mobile).
/// Bên dưới: tabs Mô tả / Thông số / Đánh giá.
class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _productService = ProductService();
  final _cartService = CartService();
  final _authService = AuthService();
  final _reviewService = ReviewService();

  ProductModel? _product;
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _error;

  int _selectedImage = 0;
  String? _selectedVersion;
  String? _selectedColor;
  int _quantity = 1;

  double _avgRating = 0;
  int _reviewCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final product = await _productService.getProductById(widget.productId);
      if (!mounted) return;
      if (product == null) {
        setState(() {
          _isLoading = false;
          _error = 'Không tìm thấy sản phẩm';
        });
        return;
      }

      final stats = await _reviewService.getReviewStats(widget.productId);

      if (!mounted) return;
      setState(() {
        _product = product;
        _isLoading = false;
        if (product.versions != null && product.versions!.isNotEmpty) {
          _selectedVersion = product.versions!.first;
        }
        if (product.colors != null && product.colors!.isNotEmpty) {
          _selectedColor = product.colors!.first['name'] as String;
        }
        _avgRating =
            (stats['averageRating'] as double?) ?? product.rating;
        _reviewCount = stats['count'] as int? ?? 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  List<String> _images(ProductModel p) => [
        if (p.imageUrl != null) p.imageUrl!,
        ...?p.imageUrls,
      ];

  Map<String, dynamic>? _findOption(ProductModel p) {
    if (p.options == null) return null;
    for (final o in p.options!) {
      if (o['version'] == _selectedVersion &&
          o['colorName'] == _selectedColor) {
        return o;
      }
    }
    return null;
  }

  int _currentPrice(ProductModel p) {
    if (_selectedVersion == null || _selectedColor == null) return p.price;
    final opt = _findOption(p);
    if (opt == null) return p.price;
    final original = opt['originalPrice'] as int;
    final disc = opt['discount'] as int;
    return original - (original * disc ~/ 100);
  }

  int _currentOriginalPrice(ProductModel p) {
    if (_selectedVersion == null || _selectedColor == null) {
      return p.originalPrice;
    }
    final opt = _findOption(p);
    return opt == null ? p.originalPrice : opt['originalPrice'] as int;
  }

  int _currentStock(ProductModel p) {
    if (_selectedVersion == null || _selectedColor == null) return p.quantity;
    final opt = _findOption(p);
    return opt == null ? p.quantity : (opt['quantity'] as int? ?? 0);
  }

  bool _versionAvailable(String v) {
    final p = _product;
    if (p == null) return true;
    if (p.options == null) return true;
    if (_selectedColor == null) {
      // Có ít nhất 1 option với version = v và quantity > 0
      return p.options!.any(
        (o) =>
            o['version'] == v && (o['quantity'] as int? ?? 0) > 0,
      );
    }
    return p.options!.any(
      (o) =>
          o['version'] == v &&
          o['colorName'] == _selectedColor &&
          (o['quantity'] as int? ?? 0) > 0,
    );
  }

  bool _colorAvailable(String c) {
    final p = _product;
    if (p == null) return true;
    if (p.options == null) return true;
    if (_selectedVersion == null) {
      return p.options!.any(
        (o) =>
            o['colorName'] == c && (o['quantity'] as int? ?? 0) > 0,
      );
    }
    return p.options!.any(
      (o) =>
          o['colorName'] == c &&
          o['version'] == _selectedVersion &&
          (o['quantity'] as int? ?? 0) > 0,
    );
  }

  // ---------------------------------------------------------------------------
  // Cart actions
  // ---------------------------------------------------------------------------

  Future<void> _ensureLoggedIn(String message) async {
    if (_authService.isLoggedIn) return;
    if (!mounted) return;
    context.push('/login');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  CartItemModel _buildCartItem() {
    final p = _product!;
    final imgs = _images(p);
    return CartItemModel(
      productId: p.id,
      productName: p.name,
      imageUrl: imgs.isNotEmpty ? imgs.first : null,
      price: _currentPrice(p),
      originalPrice: _currentOriginalPrice(p),
      quantity: _quantity,
      selectedVersion: _selectedVersion,
      selectedColor: _selectedColor,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _handleAddToCart() async {
    if (!_authService.isLoggedIn) {
      await _ensureLoggedIn(
          'Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng');
      return;
    }
    if (_product == null) return;

    setState(() => _isProcessing = true);
    try {
      await _cartService.addToCart(_buildCartItem());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã thêm sản phẩm vào giỏ hàng'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleBuyNow() async {
    if (!_authService.isLoggedIn) {
      await _ensureLoggedIn('Vui lòng đăng nhập để mua hàng');
      return;
    }
    if (_product == null) return;

    setState(() => _isProcessing = true);
    try {
      final item = _buildCartItem();
      await _cartService.addToCart(item);
      final cartItems = await _cartService.getCartItemsOnce();
      final added = cartItems.firstWhere(
        (c) =>
            c.productId == item.productId &&
            c.selectedVersion == item.selectedVersion &&
            c.selectedColor == item.selectedColor,
        orElse: () => item,
      );
      if (!mounted) return;
      context.go('/checkout', extra: [added]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    if (_isLoading) {
      return _shell(
        const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppColors.primary500,
            ),
          ),
        ),
      );
    }

    if (_error != null || _product == null) {
      return _shell(_ErrorState(
        message: _error ?? 'Không tìm thấy sản phẩm',
        onBack: () => context.go('/products'),
      ));
    }

    final product = _product!;
    final images = _images(product);
    final price = _currentPrice(product);
    final originalPrice = _currentOriginalPrice(product);
    final discount = originalPrice > price
        ? ((originalPrice - price) / originalPrice * 100).round()
        : 0;
    final stock = _currentStock(product);
    final quantity = _quantity.clamp(1, stock == 0 ? 1 : stock);

    final infoPanel = ProductInfoPanel(
      product: product,
      currentPrice: price,
      currentOriginalPrice: originalPrice,
      discount: discount,
      averageRating: _avgRating,
      reviewCount: _reviewCount,
      selectedVersion: _selectedVersion,
      selectedColor: _selectedColor,
      onVersionSelected: (v) => setState(() => _selectedVersion = v),
      onColorSelected: (c) => setState(() => _selectedColor = c),
      isVersionAvailable: _versionAvailable,
      isColorAvailable: _colorAvailable,
      currentStock: stock,
      quantity: quantity,
      onQuantityChanged: (v) => setState(() => _quantity = v),
      isLoading: _isProcessing,
      onAddToCart: _handleAddToCart,
      onBuyNow: _handleBuyNow,
      stackedActions: isMobile,
    );

    final gallery = ProductGallery(
      images: images,
      selectedIndex: _selectedImage,
      onSelected: (i) => setState(() => _selectedImage = i),
    );

    final padding = isMobile
        ? AppSpacing.lg
        : (isTablet ? AppSpacing.xl2 : AppSpacing.xl3);

    return Container(
      color: AppColors.surface,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _Breadcrumb(
              product: product,
              padding: padding,
              onBack: () => context.go('/products'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: AppSpacing.lg,
              ),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        gallery,
                        AppSpacing.gapXl,
                        infoPanel,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: gallery),
                        AppSpacing.gapXl2,
                        Expanded(flex: 4, child: infoPanel),
                      ],
                    ),
            ),
            ProductDescription(
              productId: widget.productId,
              product: product,
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _shell(Widget child) {
    return Container(
      color: AppColors.surface,
      height: 600,
      alignment: Alignment.center,
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Breadcrumb
// ---------------------------------------------------------------------------

class _Breadcrumb extends StatelessWidget {
  final ProductModel product;
  final double padding;
  final VoidCallback onBack;

  const _Breadcrumb({
    required this.product,
    required this.padding,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.neutral50,
        border: Border(
          bottom: BorderSide(color: AppColors.adminBorder),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Sản phẩm',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.chevron_right_rounded,
            size: 14,
            color: AppColors.neutral400,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onBack;
  const _ErrorState({required this.message, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              borderRadius: BorderRadius.circular(AppRadius.xl3),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 28,
              color: AppColors.errorDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Không thể hiển thị sản phẩm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Material(
            color: AppColors.primary500,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Quay lại danh sách',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
