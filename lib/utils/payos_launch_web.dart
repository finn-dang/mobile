import 'package:url_launcher/url_launcher.dart';
import 'package:web/web.dart' as web;

/// Web hướng A: mở PayOS ngay trên tab hiện tại.
bool launchPayOsCheckoutInSameTab(String checkoutUrl) {
  web.window.location.assign(checkoutUrl);
  return true;
}

/// Gọi **đồng bộ** ngay khi user bấm (trước mọi `await`) — không dùng `noopener` vì một số
/// trình duyệt trả về `null` và không gán được `location.href`.
Object? openPayOsBlankTabSync() {
  return web.window.open('about:blank', '_blank');
}

bool navigatePayOsBlankTab(Object? tab, String checkoutUrl) {
  final w = tab as web.Window?;
  if (w == null) return false;
  w.location.href = checkoutUrl;
  return true;
}

void closePayOsBlankTab(Object? tab) {
  (tab as web.Window?)?.close();
}

/// Fallback khi không giữ được tham chiếu tab (popup bị chặn hoàn toàn).
Future<bool> launchPayOsCheckout(String checkoutUrl) async {
  return launchUrl(
    Uri.parse(checkoutUrl),
    webOnlyWindowName: '_blank',
  );
}
