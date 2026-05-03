import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news_model.dart';

class NewsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'news';

  // Get all news articles (stream)
  Stream<List<NewsModel>> getNews() {
    return _firestore
        .collection(_collection)
        // .orderBy('publishDate', descending: true)
        .snapshots()
        .map((snapshot) {
          final news = snapshot.docs
          .map((doc) => NewsModel.fromMap({
                'id': doc.id,
                ...?doc.data() as Map<String, dynamic>?,
              }))
          .toList();
      news.sort((a, b) => b.publishDate.compareTo(a.publishDate));
      return news;
    });
  }

  // Get all news articles (future)
  Future<List<NewsModel>> getNewsList() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          // .orderBy('publish_date', descending: true)
          .get();

      final news = snapshot.docs
          .map((doc) => NewsModel.fromMap({
                'id': doc.id,
                ...?doc.data() as Map<String, dynamic>?,
              }))
          .toList();
      news.sort((a, b) => b.publishDate.compareTo(a.publishDate));
      return news;
    } catch (e) {
      throw 'Lỗi khi lấy danh sách tin tức: ${e.toString()}';
    }
  }

  // Get news by category
  Stream<List<NewsModel>> getNewsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .where('isPublished', isEqualTo: true)
        // .orderBy('publishDate', descending: true)
        .snapshots()
        .map((snapshot) {
      final news = snapshot.docs
          .map((doc) => NewsModel.fromMap({
                'id': doc.id,
                ...?doc.data() as Map<String, dynamic>?,
              }))
          .toList();
      news.sort((a, b) => b.publishDate.compareTo(a.publishDate));
      return news;
    });
  }

  // Get published news only
  Stream<List<NewsModel>> getPublishedNews() {
    return _firestore
        .collection(_collection)
        .where('isPublished', isEqualTo: true)
        // .orderBy('publishDate', descending: true)
        .snapshots()
        .map((snapshot) {
      final news = snapshot.docs
          .map((doc) => NewsModel.fromMap({
                'id': doc.id,
                ...?doc.data() as Map<String, dynamic>?,
              }))
          .toList();
      news.sort((a, b) => b.publishDate.compareTo(a.publishDate));
      return news;
    });
  }

  // Get news by ID
  Future<NewsModel?> getNewsById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return NewsModel.fromMap({
          'id': doc.id,
          ...doc.data()!,
        });
      }
      return null;
    } catch (e) {
      throw 'Lỗi khi lấy tin tức: ${e.toString()}';
    }
  }

  // Create new article
  Future<String> createNews(NewsModel news) async {
    try {
      final docRef = await _firestore.collection(_collection).add(news.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Lỗi khi tạo tin tức: ${e.toString()}';
    }
  }

  // Update article
  Future<void> updateNews(String id, NewsModel news) async {
    try {
      await _firestore.collection(_collection).doc(id).update(news.toMap());
    } catch (e) {
      throw 'Lỗi khi cập nhật tin tức: ${e.toString()}';
    }
  }

  // Delete article
  Future<void> deleteNews(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw 'Lỗi khi xóa tin tức: ${e.toString()}';
    }
  }

  // Toggle publish status
  Future<void> togglePublishStatus(String id, bool isPublished) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'isPublished': isPublished,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Lỗi khi cập nhật trạng thái: ${e.toString()}';
    }
  }

  // Get news categories
  Future<List<String>> getNewsCategories() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('isPublished', isEqualTo: true)
          .get();

      final Set<String> categories = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['category'] != null) {
          categories.add(data['category']);
        }
      }
      return categories.toList();
    } catch (e) {
      return [];
    }
  }

  // Get recent news (last N articles)
  Future<List<NewsModel>> getRecentNews({int limit = 5}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('isPublished', isEqualTo: true)
          // .orderBy('publishDate', descending: true)
          .limit(limit)
          .get();

      final news = snapshot.docs
          .map((doc) => NewsModel.fromMap({
                'id': doc.id,
                ...?doc.data() as Map<String, dynamic>?,
              }))
          .toList();
      news.sort((a, b) => b.publishDate.compareTo(a.publishDate));
      return news;
    } catch (e) {
      return [];
    }
  }
}

