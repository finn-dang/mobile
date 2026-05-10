class NewsModel {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String imageUrl;
  final String category;
  final DateTime publishDate;
  final String author;
  final String readTime;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  NewsModel({
    this.id = '',
    required this.title,
    required this.summary,
    required this.content,
    required this.imageUrl,
    required this.category,
    required this.publishDate,
    required this.author,
    required this.readTime,
    this.isPublished = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create from Map (Firestore)
  factory NewsModel.fromMap(Map<String, dynamic> map) {
    return NewsModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      summary: map['summary'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      publishDate: map['publishDate'] != null
          ? (map['publishDate'] is DateTime
              ? map['publishDate']
              : DateTime.parse(map['publishDate']))
          : DateTime.now(),
      author: map['author'] ?? '',
      readTime: map['readTime'] ?? '',
      isPublished: map['isPublished'] ?? false,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is DateTime
              ? map['createdAt']
              : DateTime.parse(map['createdAt']))
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is DateTime
              ? map['updatedAt']
              : DateTime.parse(map['updatedAt']))
          : DateTime.now(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'summary': summary,
      'content': content,
      'imageUrl': imageUrl,
      'category': category,
      'publishDate': publishDate.toIso8601String(),
      'author': author,
      'readTime': readTime,
      'isPublished': isPublished,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  NewsModel copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    String? imageUrl,
    String? category,
    DateTime? publishDate,
    String? author,
    String? readTime,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      publishDate: publishDate ?? this.publishDate,
      author: author ?? this.author,
      readTime: readTime ?? this.readTime,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NewsModel(id: $id, title: $title, category: $category, isPublished: $isPublished)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NewsModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

