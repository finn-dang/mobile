class ProductModel {
  final String id;
  final String name;
  final String categoryId; // ID của category
  final String? childCategoryId; // ID của child category (optional)
  final int price; // Giá bán
  final int originalPrice; // Giá gốc
  final int quantity; // Số lượng
  final String status; // 'Còn hàng' or 'Hết hàng'
  final String? imageUrl; // URL của hình ảnh chính
  final List<String>? imageUrls; // Danh sách URL hình ảnh phụ
  final String? description; // Mô tả sản phẩm
  final double rating; // Đánh giá (0-5)
  final int sold; // Số lượng đã bán
  final List<String>? versions; // Danh sách phiên bản ['128GB', '256GB', ...]
  final List<Map<String, dynamic>>? colors; // Danh sách màu sắc [{'name': 'Đỏ', 'hex': '#FF0000'}, ...]
  final List<Map<String, dynamic>>? options; // Danh sách options [{'version': '128GB', 'colorName': 'Đỏ', 'colorHex': '#FF0000', 'originalPrice': 15000000, 'discount': 10}, ...]
  final List<Map<String, String>>? specifications; // Thông số kỹ thuật [{'label': 'Màn hình', 'value': '6.7 inch'}, ...]
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    this.id = '',
    required this.name,
    required this.categoryId,
    this.childCategoryId,
    required this.price,
    required this.originalPrice,
    required this.quantity,
    this.status = 'Còn hàng',
    this.imageUrl,
    this.imageUrls,
    this.description,
    this.rating = 0.0,
    this.sold = 0,
    this.versions,
    this.colors,
    this.options,
    this.specifications,
    required this.createdAt,
    required this.updatedAt,
  });

  // Tính discount percentage
  int get discount {
    if (originalPrice > price) {
      return ((originalPrice - price) / originalPrice * 100).round();
    }
    return 0;
  }

  // Tính số lượng thực tế: nếu có options thì tính tổng số lượng options, nếu không thì dùng quantity
  int get actualQuantity {
    if (options != null && options!.isNotEmpty) {
      // Tính tổng số lượng từ tất cả options
      int total = 0;
      for (var option in options!) {
        final optionQuantity = option['quantity'] as int? ?? 0;
        total += optionQuantity;
      }
      return total;
    }
    // Nếu không có options, dùng số lượng trong tab thông tin
    return quantity;
  }

  // Tính trạng thái dựa trên số lượng thực tế
  String get calculatedStatus {
    return actualQuantity > 0 ? 'Còn hàng' : 'Hết hàng';
  }

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'categoryId': categoryId,
      'childCategoryId': childCategoryId,
      'price': price,
      'originalPrice': originalPrice,
      'quantity': quantity,
      'status': status,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'description': description,
      'rating': rating,
      'sold': sold,
      'versions': versions,
      'colors': colors,
      'options': options,
      'specifications': specifications,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Map
  factory ProductModel.fromMap(Map<dynamic, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      name: map['name'] as String,
      categoryId: map['categoryId'] as String,
      childCategoryId: map['childCategoryId'] as String?,
      price: map['price'] as int,
      originalPrice: map['originalPrice'] as int,
      quantity: map['quantity'] as int,
      status: map['status'] as String? ?? 'Còn hàng',
      imageUrl: map['imageUrl'] as String?,
      imageUrls: map['imageUrls'] != null
          ? List<String>.from(map['imageUrls'] as List)
          : null,
      description: map['description'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      sold: map['sold'] as int? ?? 0,
      versions: map['versions'] != null
          ? List<String>.from(map['versions'] as List)
          : null,
      colors: map['colors'] != null
          ? List<Map<String, dynamic>>.from(
              (map['colors'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
            )
          : null,
      options: map['options'] != null
          ? List<Map<String, dynamic>>.from(
              (map['options'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
            )
          : null,
      specifications: map['specifications'] != null
          ? List<Map<String, String>>.from(
              (map['specifications'] as List).map((e) => Map<String, String>.from(e as Map)),
            )
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // Create copy with method
  ProductModel copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? childCategoryId,
    int? price,
    int? originalPrice,
    int? quantity,
    String? status,
    String? imageUrl,
    List<String>? imageUrls,
    String? description,
    double? rating,
    int? sold,
    List<String>? versions,
    List<Map<String, dynamic>>? colors,
    List<Map<String, dynamic>>? options,
    List<Map<String, String>>? specifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      childCategoryId: childCategoryId ?? this.childCategoryId,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      sold: sold ?? this.sold,
      versions: versions ?? this.versions,
      colors: colors ?? this.colors,
      options: options ?? this.options,
      specifications: specifications ?? this.specifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

