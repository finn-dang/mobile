class PaymentSettingsModel {
  final String momoName;
  final String momoPhone;
  final String? momoQrImageUrl;
  final bool isMomoEnabled;
  final DateTime updatedAt;

  const PaymentSettingsModel({
    required this.momoName,
    required this.momoPhone,
    this.momoQrImageUrl,
    this.isMomoEnabled = true,
    required this.updatedAt,
  });

  factory PaymentSettingsModel.defaults() {
    return PaymentSettingsModel(
      momoName: '',
      momoPhone: '',
      momoQrImageUrl: null,
      isMomoEnabled: true,
      updatedAt: DateTime.now(),
    );
  }

  bool get hasMomoProfile => momoName.trim().isNotEmpty && momoPhone.trim().isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'momoName': momoName.trim(),
      'momoPhone': momoPhone.trim(),
      'momoQrImageUrl': momoQrImageUrl,
      'isMomoEnabled': isMomoEnabled,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PaymentSettingsModel.fromMap(Map<String, dynamic> map) {
    return PaymentSettingsModel(
      momoName: (map['momoName'] as String?) ?? '',
      momoPhone: (map['momoPhone'] as String?) ?? '',
      momoQrImageUrl: map['momoQrImageUrl'] as String?,
      isMomoEnabled: (map['isMomoEnabled'] as bool?) ?? true,
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  PaymentSettingsModel copyWith({
    String? momoName,
    String? momoPhone,
    String? momoQrImageUrl,
    bool? clearMomoQrImageUrl,
    bool? isMomoEnabled,
    DateTime? updatedAt,
  }) {
    return PaymentSettingsModel(
      momoName: momoName ?? this.momoName,
      momoPhone: momoPhone ?? this.momoPhone,
      momoQrImageUrl: clearMomoQrImageUrl == true
          ? null
          : (momoQrImageUrl ?? this.momoQrImageUrl),
      isMomoEnabled: isMomoEnabled ?? this.isMomoEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _parseDateTime(dynamic raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
