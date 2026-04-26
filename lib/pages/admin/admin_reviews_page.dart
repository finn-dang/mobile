import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../config/colors.dart';
import '../../config/spacing.dart';
import '../../models/review_model.dart';
import '../../services/review_service.dart';
import '../../widgets/admin/admin_reviews/mobile_reviews_view.dart';
import '../../widgets/admin/admin_reviews/reviews_data_table.dart';
import '../../widgets/admin/admin_reviews/reviews_search_and_filter_bar.dart';
import '../../widgets/admin/admin_reviews/reviews_stats.dart';
import '../../widgets/admin/common/admin_card.dart';
import '../../widgets/admin/common/admin_page_header.dart';

/// Admin Reviews – Modern Minimal.
class AdminReviewsPage extends StatefulWidget {
  const AdminReviewsPage({super.key});

  @override
  State<AdminReviewsPage> createState() => _AdminReviewsPageState();
}

class _AdminReviewsPageState extends State<AdminReviewsPage> {
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _searchController = TextEditingController();

  int _rowsPerPage = 10;
  int _sortColumnIndex = 4; // mặc định sort theo ngày
  bool _sortAscending = false;
  int? _selectedRating;
  bool? _hasReply;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  List<ReviewModel> _filter(List<ReviewModel> reviews) {
    final query = _searchController.text.toLowerCase();
    return reviews.where((r) {
      final matchesSearch = query.isEmpty ||
          r.userName.toLowerCase().contains(query) ||
          r.comment.toLowerCase().contains(query) ||
          r.productId.toLowerCase().contains(query);
      final matchesRating =
          _selectedRating == null || r.rating == _selectedRating;
      final matchesReply = _hasReply == null ||
          (_hasReply! && r.adminReply != null) ||
          (!_hasReply! && r.adminReply == null);
      return matchesSearch && matchesRating && matchesReply;
    }).toList();
  }

  List<ReviewModel> _sort(List<ReviewModel> reviews) {
    final sorted = List<ReviewModel>.from(reviews);
    sorted.sort((a, b) {
      int cmp;
      switch (_sortColumnIndex) {
        case 0:
          cmp = a.userName.compareTo(b.userName);
          break;
        case 1:
          cmp = a.productId.compareTo(b.productId);
          break;
        case 2:
          cmp = a.rating.compareTo(b.rating);
          break;
        case 3:
          cmp = (a.adminReply != null ? 1 : 0)
              .compareTo(b.adminReply != null ? 1 : 0);
          break;
        case 4:
          cmp = a.createdAt.compareTo(b.createdAt);
          break;
        default:
          cmp = 0;
      }
      return _sortAscending ? cmp : -cmp;
    });
    return sorted;
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedRating = null;
      _hasReply = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Container(
      color: AppColors.adminBackground,
      child: StreamBuilder<List<ReviewModel>>(
        stream: _reviewService.getAllReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingState();
          }
          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error.toString(),
              onRetry: () => setState(() {}),
            );
          }

          final all = snapshot.data ?? const <ReviewModel>[];
          final sorted = _sort(_filter(all));

          if (isMobile) {
            return MobileReviewsView(
              reviews: sorted,
              searchController: _searchController,
              selectedRating: _selectedRating,
              hasReply: _hasReply,
              onRatingChanged: (v) => setState(() => _selectedRating = v),
              onReplyChanged: (v) => setState(() => _hasReply = v),
              onClearFilters: _clearFilters,
              onSort: _onSort,
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              formatDate: _formatDate,
            );
          }

          final padding = isTablet ? AppSpacing.pageMd : AppSpacing.pageLg;
          return Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminPageHeader(
                  icon: Icons.reviews_outlined,
                  title: 'Đánh giá',
                  subtitle:
                      'Theo dõi và phản hồi đánh giá khách hàng. ${sorted.length} đánh giá hiển thị.',
                ),
                ReviewsStats(reviews: sorted, isTablet: isTablet),
                const SizedBox(height: AppSpacing.lg),
                ReviewsSearchAndFilterBar(
                  searchController: _searchController,
                  selectedRating: _selectedRating,
                  hasReply: _hasReply,
                  onRatingChanged: (v) =>
                      setState(() => _selectedRating = v),
                  onReplyChanged: (v) => setState(() => _hasReply = v),
                  onClearFilters: _clearFilters,
                  isTablet: isTablet,
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: AdminCard(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.sm,
                      AppSpacing.sm,
                      AppSpacing.sm,
                      0,
                    ),
                    child: ReviewsDataTable(
                      reviews: sorted,
                      onSort: _onSort,
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _sortAscending,
                      rowsPerPage: _rowsPerPage,
                      onRowsPerPageChanged: (v) =>
                          setState(() => _rowsPerPage = v ?? 10),
                      isTablet: isTablet,
                      formatDate: _formatDate,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// State widgets
// ---------------------------------------------------------------------------

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: AppColors.primary500,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(AppRadius.xl2),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 26,
                color: AppColors.errorDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Không thể tải đánh giá',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AdminSecondaryButton(
              icon: Icons.refresh_rounded,
              label: 'Thử lại',
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
