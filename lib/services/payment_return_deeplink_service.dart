import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../config/router.dart';
import 'payment_callback_urls.dart';
import 'payos_pending_order_store.dart';

class PaymentReturnDeepLinkService {
  PaymentReturnDeepLinkService._();

  static final PaymentReturnDeepLinkService instance =
      PaymentReturnDeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    final initial = await _appLinks.getInitialLink();
    if (initial != null) {
      _handleUri(initial);
    }

    _sub = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (Object error, StackTrace stackTrace) {
        if (kDebugMode) {
          debugPrint('[PayOS] deep link error: $error');
        }
      },
    );
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
    _started = false;
  }

  void _handleUri(Uri uri) {
    unawaited(_handleUriAsync(uri));
  }

  Future<void> _handleUriAsync(Uri uri) async {
    if (!PaymentCallbackUrls.matchesSchemeHost(uri)) return;

    final active = await PayOsPendingOrderStore.peekPendingOrderId();
    if (active == null) {
      return;
    }

    final q = uri.queryParameters['orderId'] ??
        uri.queryParameters['orderid'];
    if (q != null && q.isNotEmpty && q != active) {
      return;
    }

    final orderId =
        (q != null && q.isNotEmpty) ? q : active;

    final path = uri.path;
    final String? goPath;
    if (path == '/success' || path == 'success') {
      goPath = '/payment/payos-return';
    } else if (path == '/cancel' || path == 'cancel') {
      goPath = '/payment/payos-cancel';
    } else {
      return;
    }

    await PayOsPendingOrderStore.takePendingOrderId();

    final target = '$goPath?orderId=${Uri.encodeQueryComponent(orderId)}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appRouter.go(target);
    });
  }
}
