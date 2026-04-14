import 'package:flutter/widgets.dart';

/// Hệ thống spacing & radius cho phong cách Modern Minimal.
///
/// Dùng các token này thay cho việc rải rác `EdgeInsets.all(16/24/32)`.
class AppSpacing {
  AppSpacing._();

  // Base unit = 4px (kế thừa scale của Tailwind / Material)
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 20;
  static const double xl2  = 24;
  static const double xl3  = 32;
  static const double xl4  = 40;
  static const double xl5  = 48;

  // ---------- EdgeInsets shortcuts ----------
  static const EdgeInsets pageSm  = EdgeInsets.all(lg);
  static const EdgeInsets pageMd  = EdgeInsets.all(xl2);
  static const EdgeInsets pageLg  = EdgeInsets.all(xl3);

  static const EdgeInsets cardSm  = EdgeInsets.all(md);
  static const EdgeInsets cardMd  = EdgeInsets.all(lg);
  static const EdgeInsets cardLg  = EdgeInsets.all(xl);

  // ---------- Common gaps ----------
  static const SizedBox gapXs  = SizedBox(width: xs, height: xs);
  static const SizedBox gapSm  = SizedBox(width: sm, height: sm);
  static const SizedBox gapMd  = SizedBox(width: md, height: md);
  static const SizedBox gapLg  = SizedBox(width: lg, height: lg);
  static const SizedBox gapXl  = SizedBox(width: xl, height: xl);
  static const SizedBox gapXl2 = SizedBox(width: xl2, height: xl2);
}

/// Border radius scale – Modern Minimal hơi bo nhẹ, không quá soft.
class AppRadius {
  AppRadius._();

  static const double xs  = 4;
  static const double sm  = 6;
  static const double md  = 8;
  static const double lg  = 10;
  static const double xl  = 12;
  static const double xl2 = 16;
  static const double xl3 = 20;
  static const double pill = 999;
}
