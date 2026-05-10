import 'package:flutter/material.dart';

/// AppColors – Modern Minimal palette
///
/// Tone chính: Orange (Tailwind-style 50-900) làm accent.
/// Nền chính dùng neutral gray ấm để giảm cảm giác "thô cứng".
///
/// Quy ước:
/// - `primary*`        : màu thương hiệu (cam) – dùng cho CTA, focus, active.
/// - `neutral*`        : thang xám ấm – dùng cho text, border, surface.
/// - `success/warning/info/error`: trạng thái – tone nhạt hơn so với palette cũ.
/// - `surface*`, `background*`: nền tổng thể.
class AppColors {
  // ---------------------------------------------------------------------------
  // PRIMARY – Orange scale (Tailwind orange, hơi ấm)
  // ---------------------------------------------------------------------------
  static const Color primary50  = Color(0xFFFFF7ED);
  static const Color primary100 = Color(0xFFFFEDD5);
  static const Color primary200 = Color(0xFFFED7AA);
  static const Color primary300 = Color(0xFFFDBA74);
  static const Color primary400 = Color(0xFFFB923C);
  static const Color primary500 = Color(0xFFF97316); // <-- accent chính
  static const Color primary600 = Color(0xFFEA580C);
  static const Color primary700 = Color(0xFFC2410C);
  static const Color primary800 = Color(0xFF9A3412);
  static const Color primary900 = Color(0xFF7C2D12);

  // Backward-compatible aliases (đừng xoá – nhiều file đang dùng)
  static const Color primary         = primary500;
  static const Color primaryLight    = primary300;
  static const Color primaryDark     = primary700;
  static const Color primaryContainer = primary50;

  static const Color secondary       = primary500;
  static const Color secondaryLight  = primary300;
  static const Color secondaryDark   = primary700;

  // ---------------------------------------------------------------------------
  // NEUTRAL – Warm gray scale (ấm hơn pure gray, dịu mắt cho admin)
  // ---------------------------------------------------------------------------
  static const Color neutral0   = Color(0xFFFFFFFF);
  static const Color neutral50  = Color(0xFFFAFAF9);
  static const Color neutral100 = Color(0xFFF5F5F4);
  static const Color neutral200 = Color(0xFFE7E5E4);
  static const Color neutral300 = Color(0xFFD6D3D1);
  static const Color neutral400 = Color(0xFFA8A29E);
  static const Color neutral500 = Color(0xFF78716C);
  static const Color neutral600 = Color(0xFF57534E);
  static const Color neutral700 = Color(0xFF44403C);
  static const Color neutral800 = Color(0xFF292524);
  static const Color neutral900 = Color(0xFF1C1917);

  // ---------------------------------------------------------------------------
  // STATUS – tone nhạt, modern minimal
  // ---------------------------------------------------------------------------
  // Success
  static const Color success         = Color(0xFF10B981); // emerald-500
  static const Color successLight    = Color(0xFF6EE7B7);
  static const Color successDark     = Color(0xFF047857);
  static const Color successContainer = Color(0xFFECFDF5);

  // Warning
  static const Color warning         = Color(0xFFF59E0B); // amber-500
  static const Color warningLight    = Color(0xFFFCD34D);
  static const Color warningDark     = Color(0xFFB45309);
  static const Color warningContainer = Color(0xFFFFFBEB);

  // Error / Danger
  static const Color error           = Color(0xFFEF4444); // red-500
  static const Color errorLight      = Color(0xFFFCA5A5);
  static const Color errorDark       = Color(0xFFB91C1C);
  static const Color errorContainer  = Color(0xFFFEF2F2);

  // Info
  static const Color info            = Color(0xFF3B82F6); // blue-500
  static const Color infoLight       = Color(0xFF93C5FD);
  static const Color infoDark        = Color(0xFF1D4ED8);
  static const Color infoContainer   = Color(0xFFEFF6FF);

  // ---------------------------------------------------------------------------
  // TEXT
  // ---------------------------------------------------------------------------
  static const Color textPrimary     = neutral900;
  static const Color textSecondary   = neutral500;
  static const Color textDisabled    = neutral300;
  static const Color textOnPrimary   = neutral0;

  // ---------------------------------------------------------------------------
  // SURFACE / BACKGROUND
  // ---------------------------------------------------------------------------
  static const Color backgroundLight = neutral50;
  static const Color backgroundWhite = neutral0;
  static const Color backgroundGrey  = neutral100;
  static const Color surface         = neutral0;
  static const Color surfaceVariant  = neutral50;
  static const Color surfaceMuted    = neutral100;

  // ---------------------------------------------------------------------------
  // BORDER
  // ---------------------------------------------------------------------------
  static const Color borderLight  = neutral200;
  static const Color borderMedium = neutral300;
  static const Color borderDark   = neutral400;

  // ---------------------------------------------------------------------------
  // HEADER (giữ tương thích với code public site cũ)
  // ---------------------------------------------------------------------------
  static const Color headerBackground         = primary500;
  static const Color headerText               = neutral0;
  static const Color headerIcon               = neutral0;
  static const Color headerNavActive          = neutral0;
  static const Color headerNavInactive        = neutral0;
  static const Color headerNavActiveBackground = Color(0x40FFFFFF);

  // ---------------------------------------------------------------------------
  // CATEGORY (cho phần public, giữ nguyên API cũ)
  // ---------------------------------------------------------------------------
  static const Color categoryContainerBackground = neutral0;
  static const double categoryBorderRadius        = 16.0;
  static const double categoryElevation           = 4.0;
  static const Color categoryItemBackground       = neutral0;
  static const Color categoryItemHover            = neutral100;

  // ---------------------------------------------------------------------------
  // SHADOW – tone xám ấm, alpha thấp cho cảm giác Modern Minimal
  // ---------------------------------------------------------------------------
  static const Color shadowLight  = Color(0x0F1C1917); // ~6% on neutral900
  static const Color shadowMedium = Color(0x1A1C1917);
  static const Color shadowDark   = Color(0x331C1917);

  // ---------------------------------------------------------------------------
  // ADMIN-SPECIFIC TOKENS
  // ---------------------------------------------------------------------------
  /// Nền tổng thể của khu vực admin (content area)
  static const Color adminBackground   = neutral50;

  /// Nền sidebar – sáng, tối giản
  static const Color adminSidebarBg    = neutral0;

  /// Border phân tách giữa sidebar/content
  static const Color adminBorder       = neutral200;

  /// Nền nhẹ cho item active trong sidebar
  static const Color adminActiveBg     = primary50;

  /// Màu chữ/icon item active
  static const Color adminActiveFg     = primary600;

  /// Màu chữ/icon item idle (chưa hover)
  static const Color adminIdleFg       = neutral500;

  /// Màu chữ heading nhóm trong sidebar
  static const Color adminGroupLabel   = neutral400;
}
