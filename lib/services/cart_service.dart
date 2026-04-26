import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'carts';

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Get cart items stream for current user
  Stream<List<CartItemModel>> getCartItems() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collection)
        .doc(userId)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CartItemModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Get cart items (one-time fetch)
  Future<List<CartItemModel>> getCartItemsOnce() async {
    final userId = _currentUserId;
    if (userId == null) {
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('items')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CartItemModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw 'Lỗi khi lấy giỏ hàng: ${e.toString()}';
    }
  }

  // Add item to cart
  Future<void> addToCart(CartItemModel item) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw 'Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng';
    }

    try {
      // Check if item with same productId, version, and color already exists
      final existingItems = await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('items')
          .where('productId', isEqualTo: item.productId)
          .where('selectedVersion', isEqualTo: item.selectedVersion)
          .where('selectedColor', isEqualTo: item.selectedColor)
          .get();

      if (existingItems.docs.isNotEmpty) {
        // Update quantity of existing item
        final existingDoc = existingItems.docs.first;
        final existingItem = CartItemModel.fromMap(existingDoc.id, existingDoc.data());
        await _firestore
            .collection(_collection)
            .doc(userId)
            .collection('items')
            .doc(existingDoc.id)
            .update({
          'quantity': existingItem.quantity + item.quantity,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      } else {
        // Add new item
        await _firestore
            .collection(_collection)
            .doc(userId)
            .collection('items')
            .add(item.toMap());
      }
    } catch (e) {
      throw 'Lỗi khi thêm vào giỏ hàng: ${e.toString()}';
    }
  }

  // Update item quantity
  Future<void> updateQuantity(String itemId, int quantity) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw 'Vui lòng đăng nhập';
    }

    try {
      if (quantity <= 0) {
        await removeFromCart(itemId);
      } else {
        await _firestore
            .collection(_collection)
            .doc(userId)
            .collection('items')
            .doc(itemId)
            .update({
          'quantity': quantity,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw 'Lỗi khi cập nhật số lượng: ${e.toString()}';
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String itemId) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw 'Vui lòng đăng nhập';
    }

    try {
      await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('items')
          .doc(itemId)
          .delete();
    } catch (e) {
      throw 'Lỗi khi xóa sản phẩm: ${e.toString()}';
    }
  }

  // Clear all cart items
  Future<void> clearCart() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw 'Vui lòng đăng nhập';
    }

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('items')
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw 'Lỗi khi xóa giỏ hàng: ${e.toString()}';
    }
  }

  // Get cart items count
  Future<int> getCartItemsCount() async {
    final userId = _currentUserId;
    if (userId == null) {
      return 0;
    }

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('items')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Get cart items count stream
  Stream<int> getCartItemsCountStream() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection(_collection)
        .doc(userId)
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}

