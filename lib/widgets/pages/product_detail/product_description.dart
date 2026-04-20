import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/product_model.dart';

/// Tabs panel cho product detail – Modern Minimal with enhanced UI/UX.
class ProductDescription extends StatefulWidget {
  final String productId;
  final ProductModel product;

  const ProductDescription({
    super.key,
    required this.productId,
    required this.product,
  });

  @override
  State<ProductDescription> createState() => _ProductDescriptionState();
}

class _ProductDescriptionState extends State<ProductDescription>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
    );
    _tabController.addListener(_handleTabChange);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward();
      }
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
      _fadeController.reset();
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final padding = isMobile
        ? AppSpacing.lg
        : (isTablet ? AppSpacing.xl2 : AppSpacing.xl3);

    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnimatedTabBar(isMobile),
          const SizedBox(height: AppSpacing.md),
          // Fixed: Use SizedBox with height instead of Expanded
          SizedBox(
            height: isMobile ? 500 : 600,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildTabContent(isMobile),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTabBar(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.adminBorder.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: AppColors.surface,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Material(
          color: Colors.transparent,
          child: TabBar(
            controller: _tabController,
            isScrollable: !isMobile,
            tabAlignment: isMobile ? TabAlignment.fill : TabAlignment.start,
            labelColor: AppColors.primary600,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
            indicator: _buildAnimatedIndicator(),
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            labelPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 0 : AppSpacing.lg,
              vertical: 4,
            ),
            overlayColor: WidgetStateProperty.all(AppColors.surfaceMuted),
            tabs: [
              _buildTabWithIcon(Icons.description_outlined, 'Mô tả', 0),
              _buildTabWithIcon(Icons.settings_outlined, 'Thông số', 1),
              _buildTabWithIcon(Icons.star_outline_rounded, 'Đánh giá', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabWithIcon(IconData icon, String label, int index) {
    final isSelected = _currentTabIndex == index;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary600 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
          if (label == 'Đánh giá') ...[
            const SizedBox(width: 6),
            _buildReviewBadge(),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: const Text(
        'NEW',
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: AppColors.warning,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Decoration _buildAnimatedIndicator() {
    return UnderlineTabIndicator(
      borderSide: const BorderSide(
        color: AppColors.primary500,
        width: 2.5,
      ),
      insets: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Widget _buildTabContent(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.adminBorder.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildDescriptionTab(isMobile),
            _buildSpecificationsTab(isMobile),
            _buildReviewsTab(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionTab(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface,
            AppColors.neutral50.withOpacity(0.3),
          ],
        ),
      ),
      child: DescriptionTab(
        isMobile: isMobile,
        description: widget.product.description??"",
      ),
    );
  }

  Widget _buildSpecificationsTab(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface,
            AppColors.neutral50.withOpacity(0.3),
          ],
        ),
      ),
      child: SpecificationsTab(
        isMobile: isMobile,
        specifications: widget.product.specifications,
      ),
    );
  }

  Widget _buildReviewsTab(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface,
            AppColors.neutral50.withOpacity(0.3),
          ],
        ),
      ),
      child: ReviewsTab(
        isMobile: isMobile,
        productId: widget.productId,
      ),
    );
  }
}

// ============================================================================
// Description Tab
// ============================================================================

class DescriptionTab extends StatelessWidget {
  final bool isMobile;
  final String description;

  const DescriptionTab({
    super.key,
    required this.isMobile,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xl2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Chi tiết sản phẩm', Icons.article_outlined),
          const SizedBox(height: AppSpacing.md),
          _buildDescriptionContent(),
          const SizedBox(height: AppSpacing.xl2),
          _buildKeyFeatures(),
          const SizedBox(height: AppSpacing.xl2),
          _buildCareInstructions(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary600),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionContent() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        description.isNotEmpty ? description : 'Chưa có mô tả sản phẩm',
        style: const TextStyle(
          fontSize: 14,
          height: 1.7,
          color: AppColors.textSecondary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildKeyFeatures() {
    final features = [
      'Thiết kế hiện đại, tinh tế',
      'Chất liệu cao cấp, bền bỉ',
      'Công nghệ tiên tiến nhất',
      'Bảo hành chính hãng 12 tháng',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Tính năng nổi bật', Icons.bolt_outlined),
        const SizedBox(height: AppSpacing.md),
        ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildCareInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            'Hướng dẫn bảo quản', Icons.local_laundry_service_outlined),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary50,
                AppColors.primary50.withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const Column(
            children: [
              _CareItem(
                icon: Icons.water_drop_outlined,
                text: 'Tránh tiếp xúc với nước và hóa chất',
              ),
              SizedBox(height: 8),
              _CareItem(
                icon: Icons.thermostat_outlined,
                text: 'Bảo quản nơi khô ráo, thoáng mát',
              ),
              SizedBox(height: 8),
              _CareItem(
                icon: Icons.cleaning_services_outlined,
                text: 'Vệ sinh định kỳ bằng khăn mềm',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CareItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CareItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary600),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Specifications Tab
// ============================================================================

class SpecificationsTab extends StatelessWidget {
  final bool isMobile;
  final List<Map<String, String>>? specifications;

  const SpecificationsTab({
    super.key,
    required this.isMobile,
    required this.specifications,
  });

  @override
  Widget build(BuildContext context) {
    if (specifications == null || specifications!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings_overscan_outlined,
              size: 48,
              color: AppColors.neutral300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có thông số kỹ thuật',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xl2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Thông số kỹ thuật', Icons.settings_outlined),
          const SizedBox(height: AppSpacing.lg),
          _buildSpecsList(specifications!),
          const SizedBox(height: AppSpacing.xl2),
          _buildPackageIncludes(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary600),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecsList(List<Map<String, String>> specs) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: specs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final spec = specs[index];
        final label = spec['label'] ?? '';
        final value = spec['value'] ?? '';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.adminBorder.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPackageIncludes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Phụ kiện bao gồm', Icons.card_giftcard_outlined),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const Column(
            children: [
              _PackageItem(text: '1 x Sản phẩm chính'),
              SizedBox(height: 8),
              _PackageItem(text: '1 x Sạc nhanh chính hãng'),
              SizedBox(height: 8),
              _PackageItem(text: '1 x Sách hướng dẫn sử dụng'),
              SizedBox(height: 8),
              _PackageItem(text: '1 x Phiếu bảo hành 12 tháng'),
            ],
          ),
        ),
      ],
    );
  }
}

class _PackageItem extends StatelessWidget {
  final String text;

  const _PackageItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_outline_rounded,
          size: 16,
          color: AppColors.success,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Reviews Tab
// ============================================================================

class ReviewsTab extends StatelessWidget {
  final bool isMobile;
  final String productId;

  const ReviewsTab({
    super.key,
    required this.isMobile,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xl2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRatingSummary(),
          const SizedBox(height: AppSpacing.xl),
          _buildWriteReviewButton(),
          const SizedBox(height: AppSpacing.xl2),
          _buildRecentReviews(),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withOpacity(0.05),
            AppColors.warning.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.warning.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Text(
                  '4.8',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: AppColors.warning,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      5,
                      (index) => const Icon(
                            Icons.star_rounded,
                            size: 20,
                            color: AppColors.warning,
                          )),
                ),
                const SizedBox(height: 8),
                Text(
                  'Dựa trên 128 đánh giá',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 80,
            color: AppColors.adminBorder,
          ),
          Expanded(
            child: Column(
              children: [
                _buildRatingBar(5, 0.85),
                _buildRatingBar(4, 0.10),
                _buildRatingBar(3, 0.03),
                _buildRatingBar(2, 0.01),
                _buildRatingBar(1, 0.01),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            stars.toString(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const Icon(Icons.star_rounded, size: 12, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: AppColors.neutral200,
                color: AppColors.warning,
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(percentage * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWriteReviewButton() {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.rate_review_outlined, size: 18),
        label: const Text('Viết đánh giá của bạn'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: const BorderSide(color: AppColors.primary400, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.comment_outlined,
                size: 18,
                color: AppColors.primary600,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Đánh giá mới nhất',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (context, index) => const Divider(height: 24),
          itemBuilder: (context, index) => _buildReviewItem(index),
        ),
      ],
    );
  }

  Widget _buildReviewItem(int index) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.adminBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary100,
                child: Text(
                  'NT${index + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nguyễn Văn A',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(
                          5,
                          (starIndex) => const Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: AppColors.warning,
                              )),
                    ),
                  ],
                ),
              ),
              Text(
                '2 ngày trước',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Sản phẩm chất lượng tốt, đóng gói cẩn thận. Giao hàng nhanh. Sẽ ủng hộ lần sau!',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}