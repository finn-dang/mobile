/// Custom scheme return/cancel cho PayOS trên app (Android/iOS).
/// Khớp [android/app/src/main/AndroidManifest.xml] và [ios/Runner/Info.plist].
class PaymentCallbackUrls {
  PaymentCallbackUrls._();

  static const String scheme = 'figurestore';
  static const String host = 'payment';

  static Uri _uri(String path, String orderId) {
    return Uri(
      scheme: scheme,
      host: host,
      path: path,
      queryParameters: <String, String>{'orderId': orderId},
    );
  }

  static String buildReturnUrl(String orderId) =>
      _uri('/success', orderId).toString();

  static String buildCancelUrl(String orderId) =>
      _uri('/cancel', orderId).toString();

  static bool matchesSchemeHost(Uri uri) =>
      uri.scheme == scheme && uri.host == host;
}
