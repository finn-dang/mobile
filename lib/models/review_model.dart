class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final int rating; // 1-5
  final String comment;
  final List<String> imageUrls; // Nhiều hình ảnh
  final String? adminReply; // Phản hồi từ admin
  final DateTime? adminReplyAt; // Thời gian admin phản hồi
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    this.id = '',
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    this.imageUrls = const [],
    this.adminReply,
    this.adminReplyAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'imageUrls': imageUrls,
      'adminReply': adminReply,
      'adminReplyAt': adminReplyAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ReviewModel.fromMap(String id, Map<String, dynamic> map) {
    return ReviewModel(
      id: id,
      productId: map['productId'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      rating: map['rating'] as int,
      comment: map['comment'] as String,
      imageUrls: (map['imageUrls'] as List<dynamic>?)
              ?.map((url) => url as String)
              .toList() ??
          [],
      adminReply: map['adminReply'] as String?,
      adminReplyAt: map['adminReplyAt'] != null
          ? DateTime.parse(map['adminReplyAt'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  ReviewModel copyWith({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    int? rating,
    String? comment,
    List<String>? imageUrls,
    String? adminReply,
    DateTime? adminReplyAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      imageUrls: imageUrls ?? this.imageUrls,
      adminReply: adminReply ?? this.adminReply,
      adminReplyAt: adminReplyAt ?? this.adminReplyAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

