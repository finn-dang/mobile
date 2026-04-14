class BannerModel {
  final String id;
  final String imageUrl; // URL của ảnh banner
  final String? link; // Link khi click vào banner (optional)
  final int order; // Thứ tự hiển thị
  final DateTime? startDate; // Ngày bắt đầu hiển thị (optional)
  final DateTime? endDate; // Ngày kết thúc hiển thị (optional)
  final bool isActive; // Trạng thái active
  final DateTime createdAt;
  final DateTime updatedAt;

  BannerModel({
    this.id = '',
    required this.imageUrl,
    this.link,
    required this.order,
    this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Kiểm tra banner có đang trong thời gian hiển thị không
  bool get isInTimeRange {
    if (startDate == null && endDate == null) return true;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  // Kiểm tra banner có nên hiển thị không
  bool get shouldDisplay {
    return isActive && isInTimeRange;
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'link': link,
      'order': order,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BannerModel.fromMap(String id, Map<String, dynamic> map) {
    return BannerModel(
      id: id,
      imageUrl: map['imageUrl'] as String,
      link: map['link'] as String?,
      order: (map['order'] as num?)?.toInt() ?? 0,
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'] as String)
          : null,
      endDate:
          map['endDate'] != null ? DateTime.parse(map['endDate'] as String) : null,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  BannerModel copyWith({
    String? id,
    String? imageUrl,
    String? link,
    int? order,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      link: link ?? this.link,
      order: order ?? this.order,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

