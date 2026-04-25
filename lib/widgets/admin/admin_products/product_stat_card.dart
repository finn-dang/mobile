import 'package:flutter/material.dart';
import '../common/admin_card.dart';

/// Wrapper giữ tương thích với code cũ – uỷ quyền sang [AdminStatCard].
///
/// Trang Products sau khi refactor có thể dùng trực tiếp [AdminStatCard].
class ProductStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isTablet;

  const ProductStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return AdminStatCard(
      title: title,
      value: value,
      icon: icon,
      accent: color,
    );
  }
}
