import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../config/colors.dart';
import '../config/spacing.dart';
import '../models/cart_model.dart';
import '../models/payment_method.dart';
import '../services/cart_service.dart';
import '../widgets/pages/checkout/checkout_step_indicator.dart';
import '../widgets/pages/checkout/confirmation_step.dart';
import '../widgets/pages/checkout/delivery_info_step.dart';
import '../widgets/pages/checkout/payment_step.dart';

/// Trang Checkout – Modern Minimal.
///
/// Wizard 4 bước (Cart → Delivery → Payment → Confirm).
class CheckoutPage extends StatefulWidget {
  /// Items cụ thể để checkout (nếu null thì lấy tất cả từ cart).
  final List<CartItemModel>? specificItems;

  const CheckoutPage({super.key, this.specificItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _cartService = CartService();
  bool _orderPlaced = false;
  int _currentStep = 2;

  String? _deliveryFullName;
  String? _deliveryPhone;
  String? _deliveryAddress;
  String? _deliveryNotes;
  PaymentMethod? _paymentMethod;

  Future<bool> _handleBack() async {
    if (_orderPlaced) return true;
    if (widget.specificItems != null && widget.specificItems!.isNotEmpty) {
      try {
        for (final item in widget.specificItems!) {
          if (item.id.isNotEmpty) {
            await _cartService.removeFromCart(item.id);
          }
        }
      } catch (e) {
        debugPrint('Lỗi khi xoá item tạm: $e');
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final padding = isMobile
        ? AppSpacing.lg
        : (isTablet ? AppSpacing.xl2 : AppSpacing.xl3);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final shouldPop = await _handleBack();
          if (shouldPop && mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          surfaceTintColor: AppColors.surface,
          shape: const Border(
            bottom: BorderSide(color: AppColors.adminBorder, width: 1),
          ),
          title: const Text(
            'Thanh toán',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            onPressed: () async {
              final shouldPop = await _handleBack();
              if (shouldPop && mounted) Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckoutStepIndicator(currentStep: _currentStep),
                AppSpacing.gapXl,
                _buildStepContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 2:
        return DeliveryInfoStep(
          onNext: (fullName, phone, address, notes) {
            setState(() {
              _deliveryFullName = fullName;
              _deliveryPhone = phone;
              _deliveryAddress = address;
              _deliveryNotes = notes;
              _currentStep = 3;
            });
          },
        );
      case 3:
        return PaymentStep(
          onBack: () => setState(() => _currentStep = 2),
          onNext: (method) {
            setState(() {
              _paymentMethod = method;
              _currentStep = 4;
            });
          },
          fullName: _deliveryFullName,
          phone: _deliveryPhone,
          address: _deliveryAddress,
        );
      case 4:
        return ConfirmationStep(
          onBack: () => setState(() => _currentStep = 3),
          onOrderPlaced: () => setState(() => _orderPlaced = true),
          fullName: _deliveryFullName,
          phone: _deliveryPhone,
          address: _deliveryAddress,
          notes: _deliveryNotes,
          paymentMethod: _paymentMethod,
          specificItems: widget.specificItems,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
