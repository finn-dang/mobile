import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'hero_banner.dart';
import 'categories_section.dart';

class BannerWithCategories extends StatelessWidget {
  const BannerWithCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    if (isMobile) {
      // Mobile: hiển thị dạng column
      return Column(
        children: [
          const HeroBanner(),
          const CategoriesSection(),
        ],
      );
    }
    
    // Desktop/Tablet: hiển thị cùng row với tỉ lệ 1:3
    return SizedBox(
      height: 500, // Chiều cao khớp với banner
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Categories - chiếm 1 phần
          Expanded(
            flex: 1,
            child: const CategoriesSection(),
          ),
          // Banner - chiếm 3 phần
          Expanded(
            flex: 3,
            child: const HeroBanner(),
          ),
        ],
      ),
    );
  }
}

