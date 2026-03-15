import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../config/colors.dart';
import '../config/spacing.dart';

/// Footer customer – Modern Minimal.
///
/// Nền `neutral900` (đen ấm) thay cam, chữ sáng, các cột thông tin gọn.
class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    if (isMobile) {
      return const _MobileFooter();
    }

    return Container(
      width: double.infinity,
      color: AppColors.neutral900,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? AppSpacing.xl2 : AppSpacing.xl5,
        vertical: AppSpacing.xl3,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                flex: 2,
                child: _BrandSection(),
              ),
              AppSpacing.gapXl2,
              const Expanded(
                child: _FooterColumn(
                  title: 'Về chúng tôi',
                  links: ['Giới thiệu', 'Liên hệ', 'Tuyển dụng', 'Tin tức'],
                ),
              ),
              AppSpacing.gapXl2,
              const Expanded(
                child: _FooterColumn(
                  title: 'Hỗ trợ',
                  links: [
                    'Câu hỏi thường gặp',
                    'Hướng dẫn mua hàng',
                    'Chính sách đổi trả',
                    'Bảo hành',
                  ],
                ),
              ),
              AppSpacing.gapXl2,
              const Expanded(child: _ContactColumn()),
            ],
          ),
          AppSpacing.gapXl2,
          Container(
            height: 1,
            color: AppColors.neutral800,
          ),
          AppSpacing.gapMd,
          const Row(
            children: [
              Text(
                '© 2026 Figure Store. All rights reserved.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.neutral400,
                ),
              ),
              Spacer(),
              _SocialIconsRow(),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile footer (giản lược – chỉ giữ 1 brand row + social + copyright)
// ---------------------------------------------------------------------------

class _MobileFooter extends StatelessWidget {
  const _MobileFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.neutral900,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandSection(),
          AppSpacing.gapLg,
          Container(
            height: 1,
            color: AppColors.neutral800,
          ),
          AppSpacing.gapMd,
          const _SocialIconsRow(),
          AppSpacing.gapMd,
          const Text(
            '© 2026 Figure Store',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _BrandSection extends StatelessWidget {
  const _BrandSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary500,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Figure Store',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        AppSpacing.gapMd,
        const Text(
          'Cửa hàng figure chính hãng – đa dạng phiên bản, giao hàng tận nơi và bảo hành minh bạch.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.neutral300,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> links;
  const _FooterColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral400,
            letterSpacing: 0.6,
          ),
        ),
        AppSpacing.gapMd,
        for (final l in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _FooterLink(text: l, onTap: () {}),
          ),
      ],
    );
  }
}

class _ContactColumn extends StatelessWidget {
  const _ContactColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Liên hệ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral400,
            letterSpacing: 0.6,
          ),
        ),
        AppSpacing.gapMd,
        const _ContactRow(
          icon: Icons.location_on_outlined,
          text: '123 Đường ABC, Quận XYZ',
        ),
        const SizedBox(height: 8),
        const _ContactRow(
          icon: Icons.phone_outlined,
          text: 'Hotline: 1900 1234',
        ),
        const SizedBox(height: 8),
        const _ContactRow(
          icon: Icons.mail_outline_rounded,
          text: 'info@figurestore.vn',
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.neutral400),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.neutral300,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const _FooterLink({required this.text, required this.onTap});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (v) => setState(() => _hover = v),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 13,
            color: _hover ? Colors.white : AppColors.neutral300,
            fontWeight: FontWeight.w500,
            decoration:
                _hover ? TextDecoration.underline : TextDecoration.none,
            decorationColor: AppColors.primary300,
          ),
        ),
      ),
    );
  }
}

class _SocialIconsRow extends StatelessWidget {
  const _SocialIconsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _SocialIcon(icon: Icons.facebook_rounded),
        SizedBox(width: 8),
        _SocialIcon(icon: Icons.camera_alt_outlined), // Instagram
        SizedBox(width: 8),
        _SocialIcon(icon: Icons.send_rounded), // Telegram-ish
        SizedBox(width: 8),
        _SocialIcon(icon: Icons.smart_display_outlined), // YouTube
      ],
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final IconData icon;
  const _SocialIcon({required this.icon});

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      onHover: (v) => setState(() => _hover = v),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _hover ? AppColors.primary500 : AppColors.neutral800,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        alignment: Alignment.center,
        child: Icon(
          widget.icon,
          size: 16,
          color: _hover ? Colors.white : AppColors.neutral300,
        ),
      ),
    );
  }
}
