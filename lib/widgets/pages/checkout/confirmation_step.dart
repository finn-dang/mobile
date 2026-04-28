// Modern Minimal – Step 4 (Xác nhận đơn hàng) trong checkout customer.
//
// Desktop: 2 cột – Order summary 2/3 + Recipient/Payment 1/3.
// Mobile: stacked.
// Footer: nút Quay lại outline + nút Đặt hàng/Thanh toán PayOS primary cam.

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../../config/colors.dart';
import '../../../../config/spacing.dart';
import '../../../../models/cart_model.dart';
import '../../../../models/payment_method.dart';
import '../../../../services/cart_service.dart';
import '../../../../services/order_service.dart';
import '../../../../services/payment_callback_urls.dart';
import '../../../../services/payos_payment_service.dart';
import '../../../../services/payos_pending_order_store.dart';
import '../../../../utils/payos_launch.dart';
import 'order_success_dialog.dart';
import 'order_summary_section.dart';
import 'payment_method_display.dart';
import 'recipient_info_section.dart';

enum _PayOsRedirectStage {
  idle,
  creatingLink,
  redirecting,
}

class ConfirmationStep extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback? onOrderPlaced;
  final String? fullName;
  final String? phone;
  final String? address;
  final String? notes;
  final PaymentMethod? paymentMethod;
  final List<CartItemModel>? specificItems;

  const ConfirmationStep({
    super.key,
    required this.onBack,
    this.onOrderPlaced,
    this.fullName,
    this.phone,
    this.address,
    this.notes,
    this.paymentMethod,
    this.specificItems,
  });

  @override
  State<ConfirmationStep> createState() => _ConfirmationStepState();
}

class _ConfirmationStepState extends State<ConfirmationStep> {
  final _cartService = CartService();
  final _orderService = OrderService();
  bool _isPlacingOrder = false;
  _PayOsRedirectStage _payOsRedirectStage = _PayOsRedirectStage.idle;

  bool get _hasRecipient =>
      widget.fullName != null &&
      widget.phone != null &&
      widget.address != null;

  Future<void> _handlePlaceOrder() async {
    if (!_hasRecipient || widget.paymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final List<CartItemModel> cartItems;
      if (widget.specificItems != null && widget.specificItems!.isNotEmpty) {
        cartItems = widget.specificItems!;
      } else {
        cartItems = await _cartService.getCartItemsOnce();
      }

      if (cartItems.isEmpty) {
        throw 'Giỏ hàng trống';
      }

      final subtotal =
          cartItems.fold<int>(0, (sum, i) => sum + i.totalPrice);
      const shippingFee = 30000;
      final itemsMap = cartItems.map((i) => i.toMap()).toList();

      final order = await _orderService.createOrder(
        fullName: widget.fullName!,
        phone: widget.phone!,
        address: widget.address!,
        notes: widget.notes,
        paymentMethod: widget.paymentMethod!,
        items: itemsMap,
        subtotal: subtotal,
        shippingFee: shippingFee,
      );

      final isPayOs = widget.paymentMethod == PaymentMethod.payos;
      if (!isPayOs) {
        // Clear cart
        if (widget.specificItems != null &&
            widget.specificItems!.isNotEmpty) {
          for (final item in widget.specificItems!) {
            if (item.id.isNotEmpty) {
              await _cartService.removeFromCart(item.id);
            }
          }
        } else {
          await _cartService.clearCart();
        }

        widget.onOrderPlaced?.call();

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => OrderSuccessDialog(order: order),
          ).then((_) {
            if (mounted) context.go('/');
          });
        }
      } else {
        widget.onOrderPlaced?.call();
        if (!mounted) return;

        final String checkoutUrl;
        try {
          if (kIsWeb) {
            setState(() => _payOsRedirectStage = _PayOsRedirectStage.creatingLink);
          }
          checkoutUrl = await PayosPaymentService.createPaymentLink(
            orderId: order.id,
            returnUrl:
                kIsWeb ? null : PaymentCallbackUrls.buildReturnUrl(order.id),
            cancelUrl:
                kIsWeb ? null : PaymentCallbackUrls.buildCancelUrl(order.id),
          );
          if (!kIsWeb) {
            await PayOsPendingOrderStore.setPendingOrderId(order.id);
          }
        } catch (e) {
          if (!kIsWeb) await PayOsPendingOrderStore.clear();
          rethrow;
        }
        if (!mounted) return;

        bool launched;
        if (kIsWeb) {
          setState(() => _payOsRedirectStage = _PayOsRedirectStage.redirecting);
          launched = launchPayOsCheckoutInSameTab(checkoutUrl);
        } else {
          launched = await launchPayOsCheckout(checkoutUrl);
        }

        if (!mounted) return;
        if (!launched) {
          if (!kIsWeb) await PayOsPendingOrderStore.clear();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.warning,
              content: const Text(
                'Không thể chuyển hướng thanh toán. Vui lòng thử lại hoặc nhấn "Mở link".',
              ),
              action: SnackBarAction(
                label: 'Mở link',
                textColor: Colors.white,
                onPressed: () => kIsWeb
                    ? launchPayOsCheckoutInSameTab(checkoutUrl)
                    : launchPayOsCheckout(checkoutUrl),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text(
                'Đã mở PayOS. Sau khi thanh toán, trang xác nhận sẽ mở tự động.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
          _payOsRedirectStage = _PayOsRedirectStage.idle;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    if (widget.specificItems != null && widget.specificItems!.isNotEmpty) {
      return _buildContent(isMobile, widget.specificItems!);
    }

    return StreamBuilder<List<CartItemModel>>(
      stream: _cartService.getCartItems(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl3),
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
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              'Lỗi: ${snap.error}',
              style: const TextStyle(color: AppColors.error),
            ),
          );
        }
        return _buildContent(isMobile, snap.data ?? const []);
      },
    );
  }

  Widget _buildContent(bool isMobile, List<CartItemModel> items) {
    final summary = OrderSummarySection(cartItems: items);
    final recipient = _hasRecipient
        ? RecipientInfoSection(
            fullName: widget.fullName!,
            phone: widget.phone!,
            address: widget.address!,
            notes: widget.notes,
          )
        : null;
    final paymentDisplay = widget.paymentMethod != null
        ? PaymentMethodDisplay(paymentMethod: widget.paymentMethod!)
        : null;

    final baseContent = isMobile
        ? Column(
            children: [
              if (recipient != null) ...[recipient, AppSpacing.gapLg],
              if (paymentDisplay != null) ...[paymentDisplay, AppSpacing.gapLg],
              summary,
              AppSpacing.gapLg,
              _ActionBar(
                isLoading: _isPlacingOrder,
                isPayOs: widget.paymentMethod == PaymentMethod.payos,
                onBack: widget.onBack,
                onPlaceOrder: _handlePlaceOrder,
              ),
            ],
          )
        : Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: summary),
                  AppSpacing.gapLg,
                  Expanded(
                    child: Column(
                      children: [
                        if (recipient != null) ...[recipient, AppSpacing.gapLg],
                        if (paymentDisplay != null) paymentDisplay,
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.gapXl,
              _ActionBar(
                isLoading: _isPlacingOrder,
                isPayOs: widget.paymentMethod == PaymentMethod.payos,
                onBack: widget.onBack,
                onPlaceOrder: _handlePlaceOrder,
              ),
            ],
          );

    final shouldShowPayOsWaitingOverlay =
        kIsWeb &&
        widget.paymentMethod == PaymentMethod.payos &&
        _payOsRedirectStage != _PayOsRedirectStage.idle;

    if (!shouldShowPayOsWaitingOverlay) return baseContent;

    return Stack(
      children: [
        baseContent,
        Positioned.fill(
          child: AbsorbPointer(
            child: Container(
              color: Colors.white.withValues(alpha: 0.82),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 340),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.adminBorder),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primary500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _payOsRedirectStage == _PayOsRedirectStage.creatingLink
                            ? 'Đang tạo phiên thanh toán...'
                            : 'Đang chuyển hướng thanh toán...',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Vui lòng chờ trong giây lát.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Action bar (Quay lại + Đặt hàng/Thanh toán PayOS)
// ---------------------------------------------------------------------------

class _ActionBar extends StatelessWidget {
  final bool isLoading;
  final bool isPayOs;
  final VoidCallback onBack;
  final VoidCallback onPlaceOrder;

  const _ActionBar({
    required this.isLoading,
    required this.isPayOs,
    required this.onBack,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SecondaryButton(
            icon: Icons.arrow_back_rounded,
            label: 'Quay lại',
            onPressed: isLoading ? () {} : onBack,
          ),
        ),
        AppSpacing.gapMd,
        Expanded(
          flex: 2,
          child: _PrimaryButton(
            icon: isPayOs
                ? Icons.qr_code_scanner_rounded
                : Icons.check_circle_outline_rounded,
            label: isPayOs ? 'Thanh toán PayOS' : 'Đặt hàng',
            isLoading: isLoading,
            onPressed: onPlaceOrder,
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isLoading
        ? AppColors.primary300
        : (_hover ? AppColors.primary600 : AppColors.primary500);
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: widget.isLoading ? null : widget.onPressed,
        onHover: (v) => setState(() => _hover = v),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                Icon(widget.icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.isLoading ? 'Đang xử lý...' : widget.label,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  State<_SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<_SecondaryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _hover ? AppColors.surfaceMuted : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: widget.onPressed,
        onHover: (v) => setState(() => _hover = v),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.adminBorder),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 16, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
