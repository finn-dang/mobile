import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  // Get all products
  Stream<List<ProductModel>> getProducts() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    });
  }

  // Get single product by ID
  Future<ProductModel?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return ProductModel.fromMap({
          'id': doc.id,
          ...doc.data()!,
        });
      }
      return null;
    } catch (e) {
      throw 'Lỗi khi lấy sản phẩm: ${e.toString()}';
    }
  }

  // Get products by category ID
  Stream<List<ProductModel>> getProductsByCategory(String categoryId) {
    return _firestore
        .collection(_collection)
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    });
  }

  // Get products by child category ID
  Stream<List<ProductModel>> getProductsByChildCategory(String childCategoryId) {
    return _firestore
        .collection(_collection)
        .where('childCategoryId', isEqualTo: childCategoryId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    });
  }

  // Create product
  Future<String> createProduct(ProductModel product) async {
    try {
      final docRef = await _firestore.collection(_collection).add(product.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Lỗi khi tạo sản phẩm: ${e.toString()}';
    }
  }

  // Update product
  Future<void> updateProduct(String id, ProductModel product) async {
    try {
      await _firestore.collection(_collection).doc(id).update(product.toMap());
    } catch (e) {
      throw 'Lỗi khi cập nhật sản phẩm: ${e.toString()}';
    }
  }

  // Delete product
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw 'Lỗi khi xóa sản phẩm: ${e.toString()}';
    }
  }

  // Update product quantity
  Future<void> updateQuantity(String id, int quantity) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'quantity': quantity,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Lỗi khi cập nhật số lượng: ${e.toString()}';
    }
  }

  // Update product status
  Future<void> updateStatus(String id, String status) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Lỗi khi cập nhật trạng thái: ${e.toString()}';
    }
  }

  // Decrease product quantity (for order completion)
  Future<void> decreaseQuantity(String id, int quantity) async {
    try {
      final product = await getProductById(id);
      if (product == null) {
        throw 'Không tìm thấy sản phẩm';
      }
      
      final newQuantity = (product.quantity - quantity).clamp(0, double.infinity).toInt();
      await updateQuantity(id, newQuantity);
    } catch (e) {
      throw 'Lỗi khi giảm số lượng sản phẩm: ${e.toString()}';
    }
  }

  // Increase product quantity (for order cancellation/restore)
  Future<void> increaseQuantity(String id, int quantity) async {
    try {
      final product = await getProductById(id);
      if (product == null) {
        throw 'Không tìm thấy sản phẩm';
      }
      
      final newQuantity = product.quantity + quantity;
      await updateQuantity(id, newQuantity);
    } catch (e) {
      throw 'Lỗi khi tăng số lượng sản phẩm: ${e.toString()}';
    }
  }

  // Decrease option quantity (for order completion)
  Future<void> decreaseOptionQuantity(
    String productId,
    String? version,
    String? colorName,
    int quantity,
  ) async {
    try {
      final product = await getProductById(productId);
      if (product == null) {
        throw 'Không tìm thấy sản phẩm';
      }

      if (product.options == null || product.options!.isEmpty) {
        // No options, decrease main quantity
        await decreaseQuantity(productId, quantity);
        return;
      }

      // Find matching option
      final optionIndex = product.options!.indexWhere((opt) {
        final optVersion = opt['version'] as String?;
        final optColorName = opt['colorName'] as String?;
        return optVersion == version && optColorName == colorName;
      });

      if (optionIndex == -1) {
        // Option not found, decrease main quantity
        await decreaseQuantity(productId, quantity);
        return;
      }

      // Update option quantity
      final option = product.options![optionIndex];
      final currentOptionQuantity = option['quantity'] as int? ?? 0;
      final newOptionQuantity = (currentOptionQuantity - quantity).clamp(0, double.infinity).toInt();
      
      final updatedOptions = List<Map<String, dynamic>>.from(product.options!);
      updatedOptions[optionIndex] = {
        ...option,
        'quantity': newOptionQuantity,
      };

      // Also decrease main quantity
      final newMainQuantity = (product.quantity - quantity).clamp(0, double.infinity).toInt();

      await _firestore.collection(_collection).doc(productId).update({
        'quantity': newMainQuantity,
        'options': updatedOptions,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Lỗi khi giảm số lượng option: ${e.toString()}';
    }
  }

  // Increase option quantity (for order cancellation/restore)
  Future<void> increaseOptionQuantity(
    String productId,
    String? version,
    String? colorName,
    int quantity,
  ) async {
    try {
      final product = await getProductById(productId);
      if (product == null) {
        throw 'Không tìm thấy sản phẩm';
      }

      if (product.options == null || product.options!.isEmpty) {
        // No options, increase main quantity
        await increaseQuantity(productId, quantity);
        return;
      }

      // Find matching option
      final optionIndex = product.options!.indexWhere((opt) {
        final optVersion = opt['version'] as String?;
        final optColorName = opt['colorName'] as String?;
        return optVersion == version && optColorName == colorName;
      });

      if (optionIndex == -1) {
        // Option not found, increase main quantity
        await increaseQuantity(productId, quantity);
        return;
      }

      // Update option quantity
      final option = product.options![optionIndex];
      final currentOptionQuantity = option['quantity'] as int? ?? 0;
      final newOptionQuantity = currentOptionQuantity + quantity;
      
      final updatedOptions = List<Map<String, dynamic>>.from(product.options!);
      updatedOptions[optionIndex] = {
        ...option,
        'quantity': newOptionQuantity,
      };

      // Also increase main quantity
      final newMainQuantity = product.quantity + quantity;

      await _firestore.collection(_collection).doc(productId).update({
        'quantity': newMainQuantity,
        'options': updatedOptions,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Lỗi khi tăng số lượng option: ${e.toString()}';
    }
  }
}

