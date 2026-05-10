import 'package:url_launcher/url_launcher.dart';

/// Non-web fallback: không xử lý same-tab tại đây.
bool launchPayOsCheckoutInSameTab(String checkoutUrl) => false;

/// Không dùng trên VM — luôn null.
Object? openPayOsBlankTabSync() => null;

bool navigatePayOsBlankTab(Object? tab, String checkoutUrl) => false;

void closePayOsBlankTab(Object? tab) {}

/// Mobile / desktop: mở PayOS ngoài app.
Future<bool> launchPayOsCheckout(String checkoutUrl) async {
  final uri = Uri.parse(checkoutUrl);
  return launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
    webOnlyWindowName: '_blank',
  );
}
