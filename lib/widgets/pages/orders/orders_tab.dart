import 'package:flutter/material.dart';
import '../../../models/order_status.dart';
import '../../../models/order_model.dart';
import '../../../services/order_service.dart';
import 'order_card.dart';

class OrdersTab extends StatelessWidget {
  final List<OrderStatus> statuses;

  const OrdersTab({
    super.key,
    required this.statuses,
  });

  @override
  Widget build(BuildContext context) {
    final _orderService = OrderService();

    return StreamBuilder<List<OrderModel>>(
      stream: _orderService.getOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Lỗi khi tải đơn hàng',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final allOrders = snapshot.data ?? [];
        // Filter orders by status
        final filteredOrders = allOrders.where((order) => statuses.contains(order.status)).toList();

        if (filteredOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Chưa có đơn hàng ',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Các đơn hàng ${statuses.map((status) => status.customerDisplayName).join(', ').toLowerCase()} sẽ hiển thị ở đây',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            return OrderCard(order: order);
          },
        );
      },
    );
  }
}

