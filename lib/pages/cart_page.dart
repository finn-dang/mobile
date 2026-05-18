import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../config/colors.dart';
import '../config/spacing.dart';
import '../models/cart_model.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../widgets/footer.dart';
import '../widgets/pages/cart/cart_item_card.dart';
import '../widgets/pages/cart/cart_summary_card.dart';
import '../widgets/pages/cart/empty_cart.dart';

/// Trang giỏ hàng – Modern Minimal.
///
/// Layout: 2 cột desktop (items 2/3 + summary 1/3 sticky); stacked mobile.
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _cartService = CartService();
  final _authService = AuthService();
  final _productService = ProductService();

  // Cache stock results to avoid hitting Firestore on every rebuild.
  final Map<String, int> _stockCache = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStockAvailability();
    });
  }

  // ---------------------------------------------------------------------------
  // Stock helpers
  // ---------------------------------------------------------------------------

  String _stockKey(CartItemModel item) =>
      '${item.productId}|${item.selectedVersion}|${item.selectedColor}';

  Future<int> _fetchAvailableQuantity(CartItemModel item) async {
    final key = _stockKey(item);
    if (_stockCache.containsKey(key)) return _stockCache[key]!;

    try {
      final product = await _productService.getProductById(item.productId);
      if (product == null) {
        _stockCache[key] = 0;
        return 0;
      }
      if (item.selectedVersion != null || item.selectedColor != null) {
        if (product.options != null && product.options!.isNotEmpty) {
          final opt = product.options!.firstWhere(
            (o) =>
                o['version'] == item.selectedVersion &&
                o['colorName'] == item.selectedColor,
            orElse: () => {},
          );
          final qty = opt.isNotEmpty ? (opt['quantity'] as int? ?? 0) : 0;
          _stockCache[key] = qty;
          return qty;
        }
        _stockCache[key] = 0;
        return 0;
      }
      final qty = product.actualQuantity;
      _stockCache[key] = qty;
      return qty;
    } catch (_) {
      _stockCache[key] = 0;
      return 0;
    }
  }

  Future<bool> _hasOutOfStockItems(List<CartItemModel> items) async {
    for (final item in items) {
      final qty = await _fetchAvailableQuantity(item);
      if (qty == 0) return true;
    }
    return false;
  }

  Future<void> _checkStockAvailability() async {
    try {
      final items = await _cartService.getCartItemsOnce();
      final updates = <Map<String, dynamic>>[];
      for (final item in items) {
        final qty = await _fetchAvailableQuantity(item);
        if (qty > 0 && item.quantity > qty) {
          updates.add({'id': item.id, 'quantity': qty});
        }
      }
      for (final u in updates) {
        await _cartService.updateQuantity(u['id'], u['quantity']);
      }
      if (!mounted) return;
      if (updates.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã cập nhật số lượng ${updates.length} sản phẩm để khớp tồn kho.',
            ),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (_) {
      // Silent fail – để StreamBuilder render bình thường.
    }
  }

  // ---------------------------------------------------------------------------
  // Cart actions
  // ---------------------------------------------------------------------------

  Future<void> _updateQuantity(String itemId, int newQty) async {
    if (newQty < 1) return;
    try {
      final items = await _cartService.getCartItemsOnce();
      final item = items.firstWhere(
        (i) => i.id == itemId,
        orElse: () => throw Exception('Không tìm thấy sản phẩm'),
      );
      final available = await _fetchAvailableQuantity(item);
      final finalQty = newQty > available ? available : newQty;
      if (finalQty != newQty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chỉ còn $available sản phẩm.'),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      await _cartService.updateQuantity(itemId, finalQty);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _removeItem(String itemId) async {
    try {
      await _cartService.removeFromCart(itemId);
      _stockCache.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xoá sản phẩm khỏi giỏ hàng'),
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
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final padding = isMobile
        ? AppSpacing.lg
        : (isTablet ? AppSpacing.xl2 : AppSpacing.xl3);

    if (!_authService.isLoggedIn) {
      return Container(
        color: AppColors.surface,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                _PageHeader(itemCount: 0),
                AppSpacing.gapXl,
                EmptyCart(
                  isLoggedIn: false,
                  onAction: () => context.push('/login'),
                ),
                const SizedBox(height: AppSpacing.xl3),
                const Footer(),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      color: AppColors.surface,
      child: StreamBuilder<List<CartItemModel>>(
        stream: _cartService.getCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingState();
          }
          if (snapshot.hasError) {
            return _ErrorState(message: snapshot.error.toString());
          }

          final items = snapshot.data ?? const <CartItemModel>[];
          final subtotal = items.fold<int>(
            0,
            (sum, i) => sum + i.totalPrice,
          );
          final totalItems = items.fold<int>(0, (sum, i) => sum + i.quantity);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    padding,
                    AppSpacing.xl,
                    padding,
                    AppSpacing.lg,
                  ),
                  child: _PageHeader(itemCount: totalItems),
                ),
                if (items.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: EmptyCart(
                      isLoggedIn: true,
                      onAction: () => context.go('/products'),
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: isMobile
                        ? _MobileBody(
                            items: items,
                            subtotal: subtotal,
                            fetchStock: _fetchAvailableQuantity,
                            onIncrement: _updateQuantity,
                            onDecrement: _updateQuantity,
                            onRemove: _removeItem,
                            hasOutOfStockFuture: _hasOutOfStockItems(items),
                            onCheckout: () => context.push('/checkout'),
                          )
                        : _DesktopBody(
                            items: items,
                            subtotal: subtotal,
                            fetchStock: _fetchAvailableQuantity,
                            onIncrement: _updateQuantity,
                            onDecrement: _updateQuantity,
                            onRemove: _removeItem,
                            hasOutOfStockFuture: _hasOutOfStockItems(items),
                            onCheckout: () => context.push('/checkout'),
                          ),
                  ),
                const SizedBox(height: AppSpacing.xl3),
                const Footer(),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page header
// ---------------------------------------------------------------------------

class _PageHeader extends StatelessWidget {
  final int itemCount;
  const _PageHeader({required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.shopping_bag_outlined,
            size: 18,
            color: AppColors.primary600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Giỏ hàng',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.4,
                        height: 1.2,
                      ),
                    ),
                    if (itemCount > 0)
                      TextSpan(
                        text: '  ($itemCount sản phẩm)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          height: 1.2,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Kiểm tra sản phẩm và tiến hành thanh toán an toàn.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop body – items + sticky summary
// ---------------------------------------------------------------------------

class _DesktopBody extends StatelessWidget {
  final List<CartItemModel> items;
  final int subtotal;
  final Future<int> Function(CartItemModel) fetchStock;
  final void Function(String, int) onIncrement;
  final void Function(String, int) onDecrement;
  final void Function(String) onRemove;
  final Future<bool> hasOutOfStockFuture;
  final VoidCallback onCheckout;

  const _DesktopBody({
    required this.items,
    required this.subtotal,
    required this.fetchStock,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.hasOutOfStockFuture,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _ItemWithStock(
                    item: item,
                    fetchStock: fetchStock,
                    onIncrement: () =>
                        onIncrement(item.id, item.quantity + 1),
                    onDecrement: () =>
                        onDecrement(item.id, item.quantity - 1),
                    onRemove: () => onRemove(item.id),
                  ),
                ),
            ],
          ),
        ),
        AppSpacing.gapXl,
        SizedBox(
          width: 320,
          child: FutureBuilder<bool>(
            future: hasOutOfStockFuture,
            builder: (_, snap) {
              return CartSummaryCard(
                subtotal: subtotal,
                shipping: 0,
                itemCount:
                    items.fold<int>(0, (sum, i) => sum + i.quantity),
                hasOutOfStock: snap.data ?? false,
                isLoading: snap.connectionState == ConnectionState.waiting,
                onCheckout: onCheckout,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile body – stacked
// ---------------------------------------------------------------------------

class _MobileBody extends StatelessWidget {
  final List<CartItemModel> items;
  final int subtotal;
  final Future<int> Function(CartItemModel) fetchStock;
  final void Function(String, int) onIncrement;
  final void Function(String, int) onDecrement;
  final void Function(String) onRemove;
  final Future<bool> hasOutOfStockFuture;
  final VoidCallback onCheckout;

  const _MobileBody({
    required this.items,
    required this.subtotal,
    required this.fetchStock,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.hasOutOfStockFuture,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _ItemWithStock(
              item: item,
              fetchStock: fetchStock,
              onIncrement: () => onIncrement(item.id, item.quantity + 1),
              onDecrement: () => onDecrement(item.id, item.quantity - 1),
              onRemove: () => onRemove(item.id),
            ),
          ),
        AppSpacing.gapMd,
        FutureBuilder<bool>(
          future: hasOutOfStockFuture,
          builder: (_, snap) {
            return CartSummaryCard(
              subtotal: subtotal,
              shipping: 0,
              itemCount: items.fold<int>(0, (sum, i) => sum + i.quantity),
              hasOutOfStock: snap.data ?? false,
              isLoading: snap.connectionState == ConnectionState.waiting,
              onCheckout: onCheckout,
            );
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// FutureBuilder wrapper cho 1 cart item (load stock)
// ---------------------------------------------------------------------------

class _ItemWithStock extends StatelessWidget {
  final CartItemModel item;
  final Future<int> Function(CartItemModel) fetchStock;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _ItemWithStock({
    required this.item,
    required this.fetchStock,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: fetchStock(item),
      builder: (_, snap) {
        return CartItemCard(
          item: item,
          availableQuantity: snap.data ?? item.quantity,
          isLoadingStock:
              snap.connectionState == ConnectionState.waiting,
          onIncrement: onIncrement,
          onDecrement: onDecrement,
          onRemove: onRemove,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// State widgets
// ---------------------------------------------------------------------------

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 400,
      child: Center(
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
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(AppRadius.xl2),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 26,
                color: AppColors.errorDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Không thể tải giỏ hàng',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
