import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/address_model.dart';

class AddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'addresses';

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Get addresses stream for current user
  Stream<List<AddressModel>> getAddresses() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        // .orderBy('isDefault', descending: true)
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AddressModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Get addresses (one-time fetch)
  Future<List<AddressModel>> getAddressesOnce() async {
    final userId = _currentUserId;
    if (userId == null) {
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          // .orderBy('isDefault', descending: true)
          // .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AddressModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw 'Lỗi khi lấy địa chỉ: ${e.toString()}';
    }
  }

  // Add new address
  Future<String> addAddress(AddressModel address) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw 'Vui lòng đăng nhập';
    }

    try {
      // If this is set as default, unset other defaults
      if (address.isDefault) {
        await _unsetOtherDefaults(userId);
      }

      final docRef = await _firestore
          .collection(_collection)
          .add(address.copyWith(userId: userId).toMap());
      return docRef.id;
    } catch (e) {
      throw 'Lỗi khi thêm địa chỉ: ${e.toString()}';
    }
  }

  // Update address
  Future<void> updateAddress(String id, AddressModel address) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw 'Vui lòng đăng nhập';
    }

    try {
      // If this is set as default, unset other defaults
      if (address.isDefault) {
        await _unsetOtherDefaults(userId, excludeId: id);
      }

      await _firestore
          .collection(_collection)
          .doc(id)
          .update(address.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw 'Lỗi khi cập nhật địa chỉ: ${e.toString()}';
    }
  }

  // Delete address
  Future<void> deleteAddress(String id) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw 'Vui lòng đăng nhập';
    }

    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw 'Lỗi khi xóa địa chỉ: ${e.toString()}';
    }
  }

  // Set address as default
  Future<void> setDefaultAddress(String id) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw 'Vui lòng đăng nhập';
    }

    try {
      await _unsetOtherDefaults(userId, excludeId: id);
      await _firestore.collection(_collection).doc(id).update({
        'isDefault': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Lỗi khi đặt địa chỉ mặc định: ${e.toString()}';
    }
  }

  // Helper: Unset other default addresses
  Future<void> _unsetOtherDefaults(String userId, {String? excludeId}) async {
    final query = _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isDefault', isEqualTo: true);

    final snapshot = await query.get();
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      if (excludeId == null || doc.id != excludeId) {
        batch.update(doc.reference, {
          'isDefault': false,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    }

    if (snapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }
}

