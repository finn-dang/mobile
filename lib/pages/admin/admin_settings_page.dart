import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../config/colors.dart';
import '../../config/spacing.dart';
import '../../widgets/admin/admin_settings/banners_management_section.dart';
import '../../widgets/admin/admin_settings/momo_payment_settings_section.dart';
import '../../widgets/admin/common/admin_page_header.dart';

/// Admin Settings – Modern Minimal.
///
/// Hiện tại chỉ chứa quản lý banners; sẽ mở rộng dần (theme, locale,
/// thông báo,...).
class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final padding = isMobile
        ? AppSpacing.lg
        : (isTablet ? AppSpacing.xl2 : AppSpacing.xl3);

    return Container(
      color: AppColors.adminBackground,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminPageHeader(
              icon: Icons.settings_outlined,
              title: 'Cài đặt',
              subtitle:
                  'Cấu hình banner trang chủ và các thiết lập tổng thể của cửa hàng.',
            ),
            MomoPaymentSettingsSection(),
            SizedBox(height: AppSpacing.lg),
            BannersManagementSection(),
          ],
        ),
      ),
    );
  }
}
