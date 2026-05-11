import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  /// Lấy tất cả users (cho admin)
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs.map((doc) {
        final data = doc.data();
        return UserModel.fromMap({
          'uid': doc.id,
          ...data,
        });
      }).where((user) => user.role.toLowerCase() != 'admin').toList();
      
      // Sort by createdAt descending
      users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return users;
    });
  }

  /// Lấy tất cả users (one-time)
  Future<List<UserModel>> getAllUsersOnce() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final users = snapshot.docs.map((doc) {
        final data = doc.data();
        return UserModel.fromMap({
          'uid': doc.id,
          ...data,
        });
      }).where((user) => user.role.toLowerCase() != 'admin').toList();
      
      // Sort by createdAt descending
      users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return users;
    } catch (e) {
      throw 'Lỗi khi lấy danh sách người dùng: ${e.toString()}';
    }
  }

  /// Lấy một user theo ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap({
          'uid': doc.id,
          ...doc.data()!,
        });
      }
      return null;
    } catch (e) {
      throw 'Lỗi khi lấy thông tin người dùng: ${e.toString()}';
    }
  }

  /// Cập nhật role của user
  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'role': role,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Lỗi khi cập nhật vai trò: ${e.toString()}';
    }
  }

  /// Cập nhật trạng thái active của user
  Future<void> updateUserStatus(String uid, bool isActive) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'isActive': isActive,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Lỗi khi cập nhật trạng thái: ${e.toString()}';
    }
  }

  /// Xóa user (admin only)
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
    } catch (e) {
      throw 'Lỗi khi xóa người dùng: ${e.toString()}';
    }
  }

  /// Lấy số lượng đơn hàng của tất cả users (batch)
  Future<Map<String, int>> getAllUsersOrdersCount() async {
    try {
      final snapshot = await _firestore.collection('orders').get();
      
      final Map<String, int> counts = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] as String?;
        if (userId != null) {
          counts[userId] = (counts[userId] ?? 0) + 1;
        }
      }
      return counts;
    } catch (e) {
      return {}; // Return empty map if error
    }
  }
}

