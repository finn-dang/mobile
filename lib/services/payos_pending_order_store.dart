import 'package:shared_preferences/shared_preferences.dart';

/// Đơn PayOS đang chờ redirect về app (FaceRide-style); sống sót cold start.
class PayOsPendingOrderStore {
  PayOsPendingOrderStore._();

  static const _key = 'payos_pending_order_id_v1';
  static String? _memory;

  static Future<void> setPendingOrderId(String orderId) async {
    _memory = orderId;
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, orderId);
  }

  static Future<String?> peekPendingOrderId() async {
    if (_memory != null) return _memory;
    final p = await SharedPreferences.getInstance();
    _memory = p.getString(_key);
    return _memory;
  }

  static Future<String?> takePendingOrderId() async {
    final v = await peekPendingOrderId();
    _memory = null;
    final p = await SharedPreferences.getInstance();
    await p.remove(_key);
    return v;
  }

  static Future<void> clear() async {
    _memory = null;
    final p = await SharedPreferences.getInstance();
    await p.remove(_key);
  }
}
