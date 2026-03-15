import 'dart:math' as math;

/// Tham số layout cho panel chat neo góc (đồng bộ với [ShellLayout]).
/// Logic hiển thị nằm trong `shell_layout.dart` để giữ một nguồn state mở/đóng.
abstract final class ProductChatbotDockLayout {
  static double panelWidth(double screenWidth) =>
      math.min(400.0, screenWidth * 0.92);

  static double panelHeight(double screenHeight) =>
      math.min(520.0, screenHeight * 0.68);
}
