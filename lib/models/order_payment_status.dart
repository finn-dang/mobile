import 'package:flutter/material.dart';

enum OrderPaymentStatus {
  unpaid('unpaid', 'Chưa thanh toán', Colors.deepOrange),
  paid('paid', 'Đã thanh toán', Colors.green),
  failed('failed', 'Thanh toán lỗi', Colors.red);

  final String value;
  final String displayName;
  final Color color;

  const OrderPaymentStatus(this.value, this.displayName, this.color);

  static OrderPaymentStatus? fromString(String? v) {
    if (v == null) return null;
    try {
      return OrderPaymentStatus.values.firstWhere((e) => e.value == v);
    } catch (_) {
      return null;
    }
  }
}
