import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';

/// Section "Tại sao chọn chúng tôi" – Modern Minimal.
///
/// • Nền trắng + nội dung 4 cột (hoặc 2x2 trên tablet).
/// • Mỗi feature có icon container cam nhạt 48×48.
/// • Trên mobile: 2x2 grid để tránh ẩn hoàn toàn.
class WhyChooseUs extends StatelessWidget {
  const WhyChooseUs({super.key});

  static const _features = <_Feature>[
    _Feature(
      icon: Icons.local_shipping_outlined,
      title: 'Giao hàng nhanh',
      desc: 'Miễn phí vận chuyển toàn quốc',
    ),
    _Feature(
      icon: Icons.verified_outlined,
      title: 'Chính hãng',
      desc: '100% sản phẩm chính hãng',
    ),
    _Feature(
      icon: Icons.support_agent_outlined,
      title: 'Hỗ trợ 24/7',
      desc: 'Đội ngũ tư vấn nhiệt tình',
    ),
    _Feature(
      icon: Icons.payments_outlined,
      title: 'Thanh toán linh hoạt',
      desc: 'COD, MoMo, PayOS',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.lg : AppSpacing.xl3,
        vertical: isMobile ? AppSpacing.xl2 : AppSpacing.xl3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tại sao chọn chúng tôi',
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Cam kết chất lượng dịch vụ – cho trải nghiệm mua sắm tốt nhất.',
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xl),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 2 : (isTablet ? 2 : 4),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: isMobile ? 1.4 : 1.7,
            children: [
              for (final f in _features)
                _FeatureCard(feature: f, isMobile: isMobile),
            ],
          ),
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String desc;
  const _Feature({
    required this.icon,
    required this.title,
    required this.desc,
  });
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;
  final bool isMobile;
  const _FeatureCard({required this.feature, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            alignment: Alignment.center,
            child: Icon(
              feature.icon,
              size: 22,
              color: AppColors.primary600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            feature.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            feature.desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isMobile ? 12 : 12.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
