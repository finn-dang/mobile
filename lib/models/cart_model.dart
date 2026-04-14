class CartItemModel {
  final String id;
  final String productId;
  final String productName;
  final String? imageUrl;
  final int price;
  final int originalPrice;
  final int quantity;
  final String? selectedVersion;
  final String? selectedColor;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItemModel({
    this.id = '',
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.price,
    required this.originalPrice,
    required this.quantity,
    this.selectedVersion,
    this.selectedColor,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'price': price,
      'originalPrice': originalPrice,
      'quantity': quantity,
      'selectedVersion': selectedVersion,
      'selectedColor': selectedColor,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CartItemModel.fromMap(String id, Map<String, dynamic> map) {
    return CartItemModel(
      id: id,
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      imageUrl: map['imageUrl'] as String?,
      price: map['price'] as int,
      originalPrice: map['originalPrice'] as int,
      quantity: map['quantity'] as int,
      selectedVersion: map['selectedVersion'] as String?,
      selectedColor: map['selectedColor'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  CartItemModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? imageUrl,
    int? price,
    int? originalPrice,
    int? quantity,
    String? selectedVersion,
    String? selectedColor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      quantity: quantity ?? this.quantity,
      selectedVersion: selectedVersion ?? this.selectedVersion,
      selectedColor: selectedColor ?? this.selectedColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate total price for this item
  int get totalPrice => price * quantity;
}

