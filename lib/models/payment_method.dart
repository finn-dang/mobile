enum PaymentMethod {
  momo('momo', 'Thanh toán bằng MoMo', 'Chuyển tiền qua MoMo'),
  cod('cod', 'Thanh toán khi nhận hàng', 'Thanh toán tiền mặt khi nhận hàng'),
  payos('payos', 'PayOS (QR / VietQR)', 'Thanh toán online qua PayOS');

  final String value;
  final String name;
  final String description;

  const PaymentMethod(this.value, this.name, this.description);

  static PaymentMethod? fromString(String? value) {
    if (value == null) return null;
    if (value == 'bank') return PaymentMethod.momo;
    try {
      return PaymentMethod.values.firstWhere(
        (method) => method.value == value,
      );
    } catch (e) {
      return null;
    }
  }
}

