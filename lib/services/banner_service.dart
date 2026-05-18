import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/banner_model.dart';

class BannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'banners';

  /// Lấy tất cả banners (cho admin)
  Stream<List<BannerModel>> getAllBanners() {
    return _firestore
        .collection(_collection)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return BannerModel.fromMap(doc.id, doc.data());
            } catch (e) {
              print('Error parsing banner ${doc.id}: $e');
              return null;
            }
          })
          .where((banner) => banner != null)
          .cast<BannerModel>()
          .toList();
    });
  }

  /// Lấy các banners đang active và trong thời gian hiển thị (cho customer) - Stream
  Stream<List<BannerModel>> getActiveBanners() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      final banners = snapshot.docs
          .map((doc) {
            try {
              return BannerModel.fromMap(doc.id, doc.data());
            } catch (e) {
              print('Error parsing banner ${doc.id}: $e');
              return null;
            }
          })
          .where((banner) => banner != null)
          .cast<BannerModel>()
          .where((banner) {
            // Chỉ lấy banners active
            if (!banner.isActive) {
              return false;
            }
            // Kiểm tra thời gian hiển thị
            if (banner.startDate != null && now.isBefore(banner.startDate!)) {
              return false;
            }
            if (banner.endDate != null && now.isAfter(banner.endDate!)) {
              return false;
            }
            return true;
          })
          .toList();
      
      // Sắp xếp theo order
      banners.sort((a, b) => a.order.compareTo(b.order));
      return banners;
    }).handleError((error) {
      print('Error loading banners: $error');
      return <BannerModel>[];
    });
  }

  /// Lấy các banners đang active và trong thời gian hiển thị (cho customer) - One-time
  Future<List<BannerModel>> getActiveBannersOnce() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final now = DateTime.now();
      final banners = snapshot.docs
          .map((doc) {
            try {
              return BannerModel.fromMap(doc.id, doc.data());
            } catch (e) {
              print('Error parsing banner ${doc.id}: $e');
              return null;
            }
          })
          .where((banner) => banner != null)
          .cast<BannerModel>()
          .where((banner) {
            // Chỉ lấy banners active
            if (!banner.isActive) {
              return false;
            }
            // Kiểm tra thời gian hiển thị
            if (banner.startDate != null && now.isBefore(banner.startDate!)) {
              return false;
            }
            if (banner.endDate != null && now.isAfter(banner.endDate!)) {
              return false;
            }
            return true;
          })
          .toList();
      
      // Sắp xếp theo order
      banners.sort((a, b) => a.order.compareTo(b.order));
      return banners;
    } catch (e) {
      print('Error loading banners: $e');
      return <BannerModel>[];
    }
  }

  /// Lấy một banner theo ID
  Future<BannerModel?> getBannerById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return BannerModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      throw 'Lỗi khi lấy banner: ${e.toString()}';
    }
  }

  /// Tạo banner mới
  Future<String> createBanner(BannerModel banner) async {
    try {
      final now = DateTime.now();
      final bannerWithDates = banner.copyWith(
        createdAt: now,
        updatedAt: now,
      );
      final docRef =
          await _firestore.collection(_collection).add(bannerWithDates.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Lỗi khi tạo banner: ${e.toString()}';
    }
  }

  /// Cập nhật banner
  Future<void> updateBanner(BannerModel banner) async {
    try {
      final updatedBanner = banner.copyWith(
        updatedAt: DateTime.now(),
      );
      await _firestore
          .collection(_collection)
          .doc(banner.id)
          .update(updatedBanner.toMap());
    } catch (e) {
      throw 'Lỗi khi cập nhật banner: ${e.toString()}';
    }
  }

  /// Xóa banner
  Future<void> deleteBanner(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw 'Lỗi khi xóa banner: ${e.toString()}';
    }
  }

  /// Cập nhật thứ tự banners
  Future<void> updateBannersOrder(List<String> bannerIds) async {
    try {
      final batch = _firestore.batch();
      for (int i = 0; i < bannerIds.length; i++) {
        final bannerRef = _firestore.collection(_collection).doc(bannerIds[i]);
        batch.update(bannerRef, {
          'order': i,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
      await batch.commit();
    } catch (e) {
      throw 'Lỗi khi cập nhật thứ tự: ${e.toString()}';
    }
  }
}

