import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'categories';

  // Get all categories
  Stream<List<CategoryModel>> getCategories() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    });
  }

  // Get single category by ID
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return CategoryModel.fromMap({
          'id': doc.id,
          ...doc.data()!,
        });
      }
      return null;
    } catch (e) {
      throw 'Lỗi khi lấy danh mục: ${e.toString()}';
    }
  }

  // Get parent categories only
  Stream<List<CategoryModel>> getParentCategories() {
    return _firestore
        .collection(_collection)
        .where('parentId', isNull: true)
        // .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    });
  }

  // Get child categories by parent ID
  Stream<List<CategoryModel>> getChildCategories(String parentId) {
    return _firestore
        .collection(_collection)
        .where('parentId', isEqualTo: parentId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    });
  }

  // Create category
  Future<String> createCategory(CategoryModel category) async {
    try {
      final docRef = await _firestore.collection(_collection).add(category.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Lỗi khi tạo danh mục: ${e.toString()}';
    }
  }

  // Update category
  Future<void> updateCategory(String id, CategoryModel category) async {
    try {
      await _firestore.collection(_collection).doc(id).update(category.toMap());
    } catch (e) {
      throw 'Lỗi khi cập nhật danh mục: ${e.toString()}';
    }
  }

  // Delete category
  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw 'Lỗi khi xóa danh mục: ${e.toString()}';
    }
  }

  // Check if category has children
  Future<bool> hasChildren(String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('parentId', isEqualTo: categoryId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw 'Lỗi khi kiểm tra danh mục con: ${e.toString()}';
    }
  }

  // Update product count for category
  Future<void> updateProductCount(String categoryId, int count) async {
    try {
      await _firestore.collection(_collection).doc(categoryId).update({
        'productCount': count,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Lỗi khi cập nhật số lượng sản phẩm: ${e.toString()}';
    }
  }
}

