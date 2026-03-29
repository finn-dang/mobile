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
class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });
}

class EcommerceProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<CartItem> _cart = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  List<CartItem> get cart => _cart;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    
    // Fake API call
    await Future.delayed(Duration(milliseconds: 500));
    
    _products = [
      Product(
        id: '1',
        name: 'Product 1',
        price: 29.99,
        imageUrl: '',
        description: 'Description 1',
      ),
      Product(
        id: '2',
        name: 'Product 2',
        price: 49.99,
        imageUrl: '',
        description: 'Description 2',
      ),
    ];
    
    _isLoading = false;
    notifyListeners();
  }

  void addToCart(Product product) {
    final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      _cart[existingIndex].quantity++;
    } else {
      _cart.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  double get totalPrice {
    return _cart.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  Future<bool> checkout() async {
    await Future.delayed(Duration(seconds: 1));
    _cart.clear();
    notifyListeners();
    return true;
  }
}

