import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../config/payos_config.dart';

/// Gọi HTTPS Function `payosCreatePaymentLink` (Bearer ID token).
class PayosPaymentService {
  PayosPaymentService._();

  static Future<String> createPaymentLink({
    required String orderId,
    String? returnUrl,
    String? cancelUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw 'Vui lòng đăng nhập';
    }
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw 'Không lấy được token';
    }

    final uri = Uri.parse(PayosConfig.createPaymentLinkUrl);
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'orderId': orderId,
        if (returnUrl != null && returnUrl.isNotEmpty) 'returnUrl': returnUrl,
        if (cancelUrl != null && cancelUrl.isNotEmpty) 'cancelUrl': cancelUrl,
      }),
    );

    if (res.statusCode != 200) {
      String msg = res.body;
      try {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        msg = j['error']?.toString() ?? res.body;
      } catch (_) {}
      throw msg;
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final url = json['checkoutUrl'] as String?;
    if (url == null || url.isEmpty) {
      throw 'Thiếu checkoutUrl từ server';
    }
    return url;
  }
}
