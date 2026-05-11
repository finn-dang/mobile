import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/user_model.dart';
import '../common/admin_card.dart';

/// Stats grid cho Users – Modern Minimal.
class UsersStats extends StatelessWidget {
  final List<UserModel> users;
  final bool isTablet;

  const UsersStats({
    super.key,
    required this.users,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final total = users.length;
    final active = users.where((u) => u.isActive).length;
    final admins = users.where((u) => u.role == 'admin').length;
    final locked = total - active;
    final activePct = total == 0 ? 0 : ((active / total) * 100).round();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isTablet ? 2 : 4,
      crossAxisSpacing: AppSpacing.lg,
      mainAxisSpacing: AppSpacing.lg,
      childAspectRatio: isTablet ? 2.4 : 2.0,
      children: [
        AdminStatCard(
          title: 'Tổng người dùng',
          value: total.toString(),
          icon: Icons.people_outline,
          accent: AppColors.info,
        ),
        AdminStatCard(
          title: 'Đang hoạt động',
          value: active.toString(),
          icon: Icons.check_circle_outline_rounded,
          accent: AppColors.success,
          hint: '$activePct%',
          hintFg: AppColors.successDark,
          hintBg: AppColors.successContainer,
        ),
        AdminStatCard(
          title: 'Bị khoá',
          value: locked.toString(),
          icon: Icons.block_rounded,
          accent: AppColors.error,
        ),
        AdminStatCard(
          title: 'Quản trị viên',
          value: admins.toString(),
          icon: Icons.admin_panel_settings_outlined,
          accent: AppColors.primary500,
        ),
      ],
    );
  }
}
