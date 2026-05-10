class HomeSectionModel {
  final String id;
  final String title; // Tiêu đề section
  final List<String> productIds; // Danh sách ID sản phẩm
  final DateTime? startDate; // Ngày bắt đầu hiển thị (optional)
  final DateTime? endDate; // Ngày kết thúc hiển thị (optional)
  final int order; // Thứ tự hiển thị
  final bool isActive; // Trạng thái active
  final DateTime createdAt;
  final DateTime updatedAt;

  HomeSectionModel({
    this.id = '',
    required this.title,
    this.productIds = const [],
    this.startDate,
    this.endDate,
    required this.order,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Kiểm tra section có đang trong thời gian hiển thị không
  bool get isInTimeRange {
    if (startDate == null && endDate == null) return true;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  // Kiểm tra section có nên hiển thị không
  bool get shouldDisplay {
    return isActive && isInTimeRange;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'productIds': productIds,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HomeSectionModel.fromMap(String id, Map<String, dynamic> map) {
    return HomeSectionModel(
      id: id,
      title: map['title'] as String,
      productIds: (map['productIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'] as String)
          : null,
      endDate:
          map['endDate'] != null ? DateTime.parse(map['endDate'] as String) : null,
      order: (map['order'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  HomeSectionModel copyWith({
    String? id,
    String? title,
    List<String>? productIds,
    DateTime? startDate,
    DateTime? endDate,
    int? order,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HomeSectionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      productIds: productIds ?? this.productIds,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

