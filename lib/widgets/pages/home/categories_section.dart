import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/category_model.dart';
import '../../../services/category_service.dart';
import '../../web_safe_network_image.dart';

/// Khu vực danh mục trên trang chủ – Modern Minimal.
///
/// • Mobile: heading + lưới ngang scroll, item dạng "icon tròn + tên".
/// • Desktop: card list dọc cạnh hero banner, hover đổi màu nhẹ.
class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final categoryService = CategoryService();

    return StreamBuilder<List<CategoryModel>>(
      stream: categoryService.getParentCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 120,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary500,
                ),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Lỗi: ${snapshot.error}',
              style: const TextStyle(color: AppColors.error),
            ),
          );
        }

        final visible = (snapshot.data ?? const <CategoryModel>[])
            .where((c) => c.status == 'Hiển thị')
            .toList();

        if (visible.isEmpty) {
          return const SizedBox.shrink();
        }

        return isMobile
            ? _MobileCategories(categories: visible)
            : _DesktopCategories(categories: visible);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile – horizontal scroll
// ---------------------------------------------------------------------------

class _MobileCategories extends StatelessWidget {
  final List<CategoryModel> categories;
  const _MobileCategories({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: const [
                Text(
                  'Danh mục',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                Spacer(),
                _SeeAllChip(),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _MobileCategoryItem(
                category: categories[i],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeeAllChip extends StatelessWidget {
  const _SeeAllChip();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/products'),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Xem tất cả',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary600,
              ),
            ),
            SizedBox(width: 2),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: AppColors.primary600,
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileCategoryItem extends StatelessWidget {
  final CategoryModel category;
  const _MobileCategoryItem({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/products?category=${category.id}'),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(AppRadius.xl2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl2),
                child: category.imageUrl != null
                    ? WebSafeNetworkImage(
                        imageUrl: category.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.4,
                              color: AppColors.primary500,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.category_outlined,
                          size: 24,
                          color: AppColors.primary600,
                        ),
                      )
                    : const Icon(
                        Icons.category_outlined,
                        size: 24,
                        color: AppColors.primary600,
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop/Tablet – list bên cạnh hero banner
// ---------------------------------------------------------------------------

class _DesktopCategories extends StatelessWidget {
  final List<CategoryModel> categories;
  const _DesktopCategories({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        0,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.adminBorder),
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.category_outlined,
                  size: 16,
                  color: AppColors.primary600,
                ),
                SizedBox(width: 8),
                Text(
                  'Danh mục',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.neutral100),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              itemCount: categories.length,
              itemBuilder: (_, i) =>
                  _DesktopCategoryRow(category: categories[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopCategoryRow extends StatefulWidget {
  final CategoryModel category;
  const _DesktopCategoryRow({required this.category});

  @override
  State<_DesktopCategoryRow> createState() => _DesktopCategoryRowState();
}

class _DesktopCategoryRowState extends State<_DesktopCategoryRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _hover ? AppColors.primary50 : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: () =>
            context.go('/products?category=${widget.category.id}'),
        onHover: (v) => setState(() => _hover = v),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 10,
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: widget.category.imageUrl != null
                      ? WebSafeNetworkImage(
                          imageUrl: widget.category.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.4,
                                color: AppColors.primary500,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.category_outlined,
                            size: 16,
                            color: AppColors.primary600,
                          ),
                        )
                      : const Icon(
                          Icons.category_outlined,
                          size: 16,
                          color: AppColors.primary600,
                        ),
                ),
              ),
              AppSpacing.gapMd,
              Expanded(
                child: Text(
                  widget.category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: _hover ? FontWeight.w600 : FontWeight.w500,
                    color: _hover
                        ? AppColors.primary600
                        : AppColors.textPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: _hover
                    ? AppColors.primary600
                    : AppColors.neutral400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
