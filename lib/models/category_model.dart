import 'dart:developer';

class CategoryModel {
  final String id;
  final String name;
  final String? imageUrl; // URL của hình ảnh từ Firebase Storage
  final String? parentId; // null = parent category, not null = child category
  final String? description;
  final int productCount;
  final String status; // 'Hiển thị' or 'Ẩn'
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
     this.id = '',
    required this.name,
    this.imageUrl,
    this.parentId,
    this.description,
    this.productCount = 0,
    this.status = 'Hiển thị',
    required this.createdAt,
    required this.updatedAt,
  });

  // Check if this is a parent category
  bool get isParent => parentId == null;

  // Check if this is a child category
  bool get isChild => parentId != null;

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'parentId': parentId,
      'description': description,
      'productCount': productCount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Map
  factory CategoryModel.fromMap(Map<dynamic, dynamic> map) {
    log('map: $map');
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String?,
      parentId: map['parentId'] as String?,
      description: map['description'] as String?,
      productCount: map['productCount'] as int? ?? 0,
      status: map['status'] as String? ?? 'Hiển thị',
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // Create copy with method
  CategoryModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? parentId,
    String? description,
    int? productCount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      parentId: parentId ?? this.parentId,
      description: description ?? this.description,
      productCount: productCount ?? this.productCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

