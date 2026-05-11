import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import '../models/review_model.dart';
import 'image_service.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImageService _imageService = ImageService();
  final String _collection = 'reviews';

  String? get _currentUserId => _auth.currentUser?.uid;

  /// Lấy danh sách đánh giá của một sản phẩm
  Stream<List<ReviewModel>> getReviews(String productId) {
    return _firestore
        .collection(_collection)
        .where('productId', isEqualTo: productId)
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
          .toList();
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
   
    });
  }

  /// Lấy danh sách đánh giá của một sản phẩm (one-time)
  Future<List<ReviewModel>> getReviewsOnce(String productId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw 'Lỗi khi lấy đánh giá: ${e.toString()}';
    }
  }

  /// Lấy số lượng đánh giá của một sản phẩm (chỉ count, không lấy dữ liệu)
  Future<int> getReviewCount(String productId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('productId', isEqualTo: productId)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      // Nếu có lỗi, trả về 0
      return 0;
    }
  }

  /// Lấy rating trung bình của một sản phẩm từ reviews
  Future<double> getAverageRating(String productId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('productId', isEqualTo: productId)
          .get();

      if (snapshot.docs.isEmpty) {
        return 0.0;
      }

      int totalRating = 0;
      for (final doc in snapshot.docs) {
        final rating = doc.data()['rating'] as int? ?? 0;
        totalRating += rating;
      }

      return totalRating / snapshot.docs.length;
    } catch (e) {
      // Nếu có lỗi, trả về 0.0
      return 0.0;
    }
  }

  /// Lấy cả số lượng và rating trung bình của một sản phẩm
  Future<Map<String, dynamic>> getReviewStats(String productId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('productId', isEqualTo: productId)
          .get();

      if (snapshot.docs.isEmpty) {
        return {'count': 0, 'averageRating': 0.0};
      }

      int totalRating = 0;
      for (final doc in snapshot.docs) {
        final rating = doc.data()['rating'] as int? ?? 0;
        totalRating += rating;
      }

      return {
        'count': snapshot.docs.length,
        'averageRating': totalRating / snapshot.docs.length,
      };
    } catch (e) {
      return {'count': 0, 'averageRating': 0.0};
    }
  }

  /// Lấy số lượng đánh giá của nhiều sản phẩm (stream)
  /// Lưu ý: Firestore whereIn chỉ hỗ trợ tối đa 10 items
  Stream<Map<String, int>> getReviewCounts(List<String> productIds) {
    if (productIds.isEmpty) {
      return Stream.value({});
    }

    // Firestore whereIn chỉ hỗ trợ tối đa 10 items
    // Nếu có nhiều hơn 10, chỉ lấy 10 đầu tiên
    final limitedIds = productIds.length > 10 
        ? productIds.take(10).toList() 
        : productIds;

    return _firestore
        .collection(_collection)
        .where('productId', whereIn: limitedIds)
        .snapshots()
        .map((snapshot) {
      final counts = <String, int>{};
      for (final doc in snapshot.docs) {
        final productId = doc.data()['productId'] as String?;
        if (productId != null) {
          counts[productId] = (counts[productId] ?? 0) + 1;
        }
      }
      // Set 0 for products with no reviews (chỉ cho limitedIds)
      for (final productId in limitedIds) {
        if (!counts.containsKey(productId)) {
          counts[productId] = 0;
        }
      }
      return counts;
    });
  }

  /// Upload nhiều hình ảnh review
  Future<List<String>> uploadReviewImages(
    List<PlatformFile> imageFiles,
    String reviewId,
  ) async {
    try {
      final urls = <String>[];
      for (final imageFile in imageFiles) {
        final url = await _imageService.uploadImage(
          platformFile: imageFile,
          folder: 'reviews/$reviewId',
        );
        urls.add(url);
      }
      return urls;
    } catch (e) {
      throw 'Lỗi khi upload hình ảnh: ${e.toString()}';
    }
  }

  /// Tạo đánh giá mới
  Future<ReviewModel> createReview({
    required String productId,
    required String userName,
    required int rating,
    required String comment,
    List<PlatformFile>? imageFiles,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw 'Vui lòng đăng nhập để đánh giá sản phẩm';
    }

    try {
      final now = DateTime.now();
      final tempReviewId = 'temp_${now.millisecondsSinceEpoch}';

      // Upload images if any
      List<String> imageUrls = [];
      if (imageFiles != null && imageFiles.isNotEmpty) {
        imageUrls = await uploadReviewImages(imageFiles, tempReviewId);
      }

      // Create review
      final review = ReviewModel(
        productId: productId,
        userId: userId,
        userName: userName,
        rating: rating,
        comment: comment,
        imageUrls: imageUrls,
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await _firestore.collection(_collection).add(review.toMap());
      
      return review.copyWith(id: docRef.id);
    } catch (e) {
      throw 'Lỗi khi tạo đánh giá: ${e.toString()}';
    }
  }

  /// Cập nhật phản hồi từ admin
  Future<void> updateAdminReply(String reviewId, String reply) async {
    try {
      await _firestore.collection(_collection).doc(reviewId).update({
        'adminReply': reply,
        'adminReplyAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Lỗi khi cập nhật phản hồi: ${e.toString()}';
    }
  }

  /// Xóa phản hồi admin
  Future<void> deleteAdminReply(String reviewId) async {
    try {
      await _firestore.collection(_collection).doc(reviewId).update({
        'adminReply': null,
        'adminReplyAt': null,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Lỗi khi xóa phản hồi: ${e.toString()}';
    }
  }

  /// Xóa đánh giá (admin only)
  Future<void> deleteReview(String reviewId) async {
    try {
      // Delete images from storage
      final review = await getReviewById(reviewId);
      if (review != null && review.imageUrls.isNotEmpty) {
        for (final imageUrl in review.imageUrls) {
          try {
            await _imageService.deleteImage(imageUrl);
          } catch (e) {
            // Ignore errors when deleting images
          }
        }
      }

      // Delete review document
      await _firestore.collection(_collection).doc(reviewId).delete();
    } catch (e) {
      throw 'Lỗi khi xóa đánh giá: ${e.toString()}';
    }
  }

  /// Cập nhật đánh giá của user (chỉ cho phép user sở hữu review)
  Future<void> updateUserReview({
    required String reviewId,
    required String userName,
    required int rating,
    required String comment,
    List<PlatformFile>? newImageFiles,
    List<String>? existingImageUrls,
    List<String>? removedImageUrls,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw 'Vui lòng đăng nhập để chỉnh sửa đánh giá';
    }

    try {
      // Kiểm tra quyền sở hữu
      final review = await getReviewById(reviewId);
      if (review == null) {
        throw 'Không tìm thấy đánh giá';
      }
      if (review.userId != userId) {
        throw 'Bạn không có quyền chỉnh sửa đánh giá này';
      }

      // Xóa các ảnh đã bị xóa
      if (removedImageUrls != null && removedImageUrls.isNotEmpty) {
        for (final imageUrl in removedImageUrls) {
          try {
            await _imageService.deleteImage(imageUrl);
          } catch (e) {
            // Ignore errors when deleting images
          }
        }
      }

      // Upload ảnh mới nếu có
      List<String> newImageUrls = [];
      if (newImageFiles != null && newImageFiles.isNotEmpty) {
        newImageUrls = await uploadReviewImages(newImageFiles, reviewId);
      }

      // Kết hợp ảnh cũ và ảnh mới
      final finalImageUrls = <String>[];
      if (existingImageUrls != null) {
        finalImageUrls.addAll(existingImageUrls);
      }
      finalImageUrls.addAll(newImageUrls);

      // Cập nhật review
      await _firestore.collection(_collection).doc(reviewId).update({
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'imageUrls': finalImageUrls,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Lỗi khi cập nhật đánh giá: ${e.toString()}';
    }
  }

  /// Xóa đánh giá của user (chỉ cho phép user sở hữu review)
  Future<void> deleteUserReview(String reviewId) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw 'Vui lòng đăng nhập để xóa đánh giá';
    }

    try {
      // Kiểm tra quyền sở hữu
      final review = await getReviewById(reviewId);
      if (review == null) {
        throw 'Không tìm thấy đánh giá';
      }
      if (review.userId != userId) {
        throw 'Bạn không có quyền xóa đánh giá này';
      }

      // Delete images from storage
      if (review.imageUrls.isNotEmpty) {
        for (final imageUrl in review.imageUrls) {
          try {
            await _imageService.deleteImage(imageUrl);
          } catch (e) {
            // Ignore errors when deleting images
          }
        }
      }

      // Delete review document
      await _firestore.collection(_collection).doc(reviewId).delete();
    } catch (e) {
      throw 'Lỗi khi xóa đánh giá: ${e.toString()}';
    }
  }

  /// Lấy một đánh giá theo ID
  Future<ReviewModel?> getReviewById(String reviewId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(reviewId).get();
      if (doc.exists) {
        return ReviewModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      throw 'Lỗi khi lấy đánh giá: ${e.toString()}';
    }
  }

  /// Lấy tất cả đánh giá (cho admin)
  Stream<List<ReviewModel>> getAllReviews() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Kiểm tra xem user đã đánh giá sản phẩm chưa
  Future<bool> hasUserReviewedProduct(String productId) async {
    final userId = _currentUserId;
    if (userId == null) return false;

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Lấy review của user cho sản phẩm (nếu có)
  Future<ReviewModel?> getUserReviewForProduct(String productId) async {
    final userId = _currentUserId;
    if (userId == null) return null;

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return ReviewModel.fromMap(snapshot.docs.first.id, snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Lấy tất cả đánh giá của user hiện tại (stream)
  Stream<List<ReviewModel>> getUserReviews() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Lấy tất cả đánh giá của user hiện tại (one-time)
  Future<List<ReviewModel>> getUserReviewsOnce() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw 'Lỗi khi lấy đánh giá: ${e.toString()}';
    }
  }
}

