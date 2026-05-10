import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// PayOS redirect khi người dùng hủy trên cổng thanh toán.
class PayOsCancelPage extends StatelessWidget {
  final String orderId;

  const PayOsCancelPage({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán chưa hoàn tất')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.payment, size: 48),
              const SizedBox(height: 16),
              Text(
                orderId.isEmpty
                    ? 'Bạn đã hủy hoặc thoát khỏi cổng thanh toán.'
                    : 'Đơn vẫn lưu với trạng thái chưa thanh toán. '
                        'Bạn có thể thanh toán lại từ mục Đơn hàng hoặc đặt đơn mới.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/orders'),
                child: const Text('Đơn hàng của tôi'),
              ),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Về trang chủ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
