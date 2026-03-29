import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../models/order_model.dart';
import '../../web_safe_network_image.dart';
import '../../../models/order_status.dart';
import '../../../services/order_service.dart';
import '../../../services/review_service.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/pages/product_detail/write_review_dialog.dart';
import '../../../widgets/pages/product_detail/write_review_bottom_sheet.dart';
import '../../../config/colors.dart';
import 'cancel_order_dialog.dart';

class OrderDetailDialog extends StatefulWidget {
  final OrderModel order;

  const OrderDetailDialog({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailDialog> createState() => _OrderDetailDialogState();
}

class _OrderDetailDialogState extends State<OrderDetailDialog> {
  late OrderModel _order;
  final OrderService _orderService = OrderService();
  final ReviewService _reviewService = ReviewService();
  final AuthService _authService = AuthService();
  bool _isCancelling = false;
  final Map<String, bool> _hasReviewed = {}; // Cache để tránh query nhiều lần

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _checkReviews();
  }

  Future<void> _checkReviews() async {
    if (_order.status == OrderStatus.completed) {
      for (final item in _order.items) {
        final hasReviewed = await _reviewService.hasUserReviewedProduct(item.productId);
        setState(() {
          _hasReviewed[item.productId] = hasReviewed;
        });
      }
    }
  }

  Future<void> _showWriteReviewDialog(String productId, String productName) async {
    // Get user data for name
    final userData = await _authService.getCurrentUserData();
    final userName = userData?.displayName ?? 
                    _authService.currentUser?.displayName ?? 
                    _authService.currentUser?.email?.split('@').first ?? 
                    'Người dùng';

    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    if (isMobile) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => WriteReviewBottomSheet(
          productId: productId,
          defaultUserName: userName,
          onReviewSubmitted: () {
            // Update review status
            setState(() {
              _hasReviewed[productId] = true;
            });
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cảm ơn bạn đã đánh giá!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) => WriteReviewDialog(
          productId: productId,
          defaultUserName: userName,
          onReviewSubmitted: () {
            // Update review status
            setState(() {
              _hasReviewed[productId] = true;
            });
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cảm ơn bạn đã đánh giá!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      );
    }
  }

  bool get _canCancel {
    return _order.status == OrderStatus.pending ||
        _order.status == OrderStatus.confirmed ||
        _order.status == OrderStatus.processing;
  }

  Future<void> _handleCancelOrder() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => CancelOrderDialog(orderCode: _order.orderCode),
    );

    if (reason == null) return; // User cancelled

    setState(() {
      _isCancelling = true;
    });

    try {
      await _orderService.cancelOrder(_order.id, reason);
      
      // Refresh order data
      final updatedOrder = await _orderService.getOrderById(_order.id);
      if (updatedOrder != null) {
        setState(() {
          _order = updatedOrder;
          _isCancelling = false;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đơn hàng đã được hủy thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isCancelling = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }



enum PaymentMethod {
  creditCard,
  paypal,
  applePay,
  googlePay,
  bankTransfer,
}

class PaymentDetails {
  final PaymentMethod method;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String holderName;

  PaymentDetails({
    required this.method,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.holderName,
  });
}

class PaymentResult {
  final bool success;
  final String transactionId;
  final String message;
  final DateTime timestamp;

  PaymentResult({
    required this.success,
    required this.transactionId,
    required this.message,
    required this.timestamp,
  });
}

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  Future<PaymentResult> processPayment(PaymentDetails details) async {
    // Fake payment processing
    await Future.delayed(Duration(seconds: 2));
    
    return PaymentResult(
      success: true,
      transactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
      message: 'Payment processed successfully',
      timestamp: DateTime.now(),
    );
  }

  Future<bool> validateCard(String cardNumber) async {
    await Future.delayed(Duration(milliseconds: 300));
    return cardNumber.length == 16;
  }

  Future<List<String>> getSavedCards() async {
    await Future.delayed(Duration(milliseconds: 500));
    return ['**** **** **** 4242', '**** **** **** 5555'];
  }
}
