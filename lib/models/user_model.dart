class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? phone;
  final String? address;
  final String role; // 'user' or 'admin'
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.phone,
    this.address,
    this.role = 'user',
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phone': phone,
      'address': address,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Create from Map
  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      role: map['role'] as String? ?? 'user',
      createdAt: DateTime.parse(map['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt']?.toString() ?? DateTime.now().toIso8601String()),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  // Create copy with method
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phone,
    String? address,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

