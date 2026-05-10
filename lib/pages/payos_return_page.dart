import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/order_model.dart';
import '../models/order_payment_status.dart';
import '../services/order_service.dart';
import '../widgets/pages/checkout/order_success_dialog.dart';

/// Trang PayOS redirect về sau khi thanh toán; chờ webhook cập nhật `paymentStatus`.
class PayOsReturnPage extends StatefulWidget {
  final String orderId;

  const PayOsReturnPage({
    super.key,
    required this.orderId,
  });

  @override
  State<PayOsReturnPage> createState() => _PayOsReturnPageState();
}

class _PayOsReturnPageState extends State<PayOsReturnPage> {
  final _orderService = OrderService();
  StreamSubscription<OrderModel?>? _sub;
  OrderModel? _order;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    if (widget.orderId.isEmpty) return;
    _sub = _orderService.watchOrder(widget.orderId).listen(_onSnapshot);
  }

  void _onSnapshot(OrderModel? order) {
    if (!mounted) return;
    setState(() => _order = order);

    if (order == null || _dialogShown) return;
    if (order.paymentStatus != OrderPaymentStatus.paid) return;
    _dialogShown = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => OrderSuccessDialog(order: order),
      );
      if (mounted) context.go('/');
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orderId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thanh toán')),
        body: const Center(child: Text('Thiếu mã đơn hàng.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Đang xác nhận thanh toán')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _order == null
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Đang tải đơn hàng...'),
                  ],
                )
              : _order!.paymentStatus == OrderPaymentStatus.paid
                  ? const Text(
                      'Thanh toán đã được ghi nhận. Đang mở chi tiết đơn...',
                      textAlign: TextAlign.center,
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 24),
                        Text(
                          'Đơn ${_order!.orderCode}: đang chờ PayOS xác nhận. '
                          'Thường chỉ vài giây — vui lòng giữ trang này mở.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.go('/orders'),
                          child: const Text('Xem đơn hàng của tôi'),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
