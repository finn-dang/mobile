import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/home_section_model.dart';
import '../common/admin_card.dart';

/// Stats grid cho bộ sưu tập trang chủ – Modern Minimal.
class SectionsStats extends StatelessWidget {
  final List<HomeSectionModel> sections;

  const SectionsStats({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final total = sections.length;
    final active = sections.where((s) => s.isActive).length;
    final inactive = total - active;
    final showing = sections.where((s) => s.shouldDisplay).length;
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
          title: 'Tổng bộ sưu tập',
          value: total.toString(),
          icon: Icons.view_list_outlined,
          accent: AppColors.info,
        ),
        AdminStatCard(
          title: 'Đang hiển thị',
          value: active.toString(),
          icon: Icons.check_circle_outline_rounded,
          accent: AppColors.success,
          hint: '$activePct%',
          hintFg: AppColors.successDark,
          hintBg: AppColors.successContainer,
        ),
        AdminStatCard(
          title: 'Tạm tắt',
          value: inactive.toString(),
          icon: Icons.toggle_off_outlined,
          accent: AppColors.warning,
        ),
        AdminStatCard(
          title: 'Đang hiển thị',
          value: showing.toString(),
          icon: Icons.visibility_outlined,
          accent: AppColors.primary500,
        ),
      ],
    );
  }
}
