import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/home_section_model.dart';

class HomeSectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'home_sections';

  /// Lấy tất cả sections (cho admin)
  Stream<List<HomeSectionModel>> getAllSections() {
    return _firestore
        .collection(_collection)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => HomeSectionModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Lấy các sections đang active và trong thời gian hiển thị (cho customer)
  Stream<List<HomeSectionModel>> getActiveSections() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      final sections = snapshot.docs
          .map((doc) {
            try {
              return HomeSectionModel.fromMap(doc.id, doc.data());
            } catch (e) {
              // Log error và skip document không hợp lệ
              print('Error parsing section ${doc.id}: $e');
              return null;
            }
          })
          .where((section) => section != null)
          .cast<HomeSectionModel>()
          .where((section) {
            // Chỉ lấy sections active
            if (!section.isActive) {
              return false;
            }
            // Kiểm tra thời gian hiển thị
            if (section.startDate != null && now.isBefore(section.startDate!)) {
              return false;
            }
            if (section.endDate != null && now.isAfter(section.endDate!)) {
              return false;
            }
            return true;
          })
          .toList();
      
      // Sắp xếp theo order
      sections.sort((a, b) => a.order.compareTo(b.order));
      return sections;
    }).handleError((error) {
      print('Error loading sections: $error');
      return <HomeSectionModel>[];
    });
  }

  /// Lấy một section theo ID
  Future<HomeSectionModel?> getSectionById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return HomeSectionModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      throw 'Lỗi khi lấy section: ${e.toString()}';
    }
  }

  /// Tạo section mới
  Future<String> createSection(HomeSectionModel section) async {
    try {
      final now = DateTime.now();
      final sectionWithDates = section.copyWith(
        createdAt: now,
        updatedAt: now,
      );
      final docRef =
          await _firestore.collection(_collection).add(sectionWithDates.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Lỗi khi tạo section: ${e.toString()}';
    }
  }

  /// Cập nhật section
  Future<void> updateSection(HomeSectionModel section) async {
    try {
      final updatedSection = section.copyWith(
        updatedAt: DateTime.now(),
      );
      await _firestore
          .collection(_collection)
          .doc(section.id)
          .update(updatedSection.toMap());
    } catch (e) {
      throw 'Lỗi khi cập nhật section: ${e.toString()}';
    }
  }

  /// Xóa section
  Future<void> deleteSection(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw 'Lỗi khi xóa section: ${e.toString()}';
    }
  }

  /// Cập nhật thứ tự sections
  Future<void> updateSectionsOrder(List<String> sectionIds) async {
    try {
      final batch = _firestore.batch();
      for (int i = 0; i < sectionIds.length; i++) {
        final sectionRef = _firestore.collection(_collection).doc(sectionIds[i]);
        batch.update(sectionRef, {
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

