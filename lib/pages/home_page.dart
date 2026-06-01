import 'package:flutter/material.dart';

import '../config/colors.dart';
import '../config/spacing.dart';
import '../services/home_section_service.dart';
import '../widgets/footer.dart';
import '../widgets/pages/home/banner_with_categories.dart';
import '../widgets/pages/home/dynamic_section.dart';
import '../widgets/pages/home/why_choose_us.dart';

/// Trang chủ customer – Modern Minimal.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sectionService = HomeSectionService();

    return Container(
      color: AppColors.surface,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BannerWithCategories(),
            StreamBuilder(
              stream: sectionService.getActiveSections(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl3),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary500,
                        ),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Container(
                    margin: const EdgeInsets.all(AppSpacing.lg),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.errorLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 18,
                          color: AppColors.errorDark,
                        ),
                        AppSpacing.gapSm,
                        Expanded(
                          child: Text(
                            'Lỗi khi tải sections: ${snapshot.error}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.errorDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final sections = snapshot.data ?? const [];
                if (sections.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    for (final s in sections)
                      DynamicSection(key: ValueKey(s.id), section: s),
                  ],
                );
              },
            ),
            const WhyChooseUs(),
            const Footer(),
          ],
        ),
      ),
    );
  }
}
