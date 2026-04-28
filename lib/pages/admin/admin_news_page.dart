import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../config/colors.dart';
import '../../config/spacing.dart';
import '../../models/news_model.dart';
import '../../services/news_service.dart';
import '../../widgets/admin/admin_news/news_list_card.dart';
import '../../widgets/admin/admin_news/news_pagination.dart';
import '../../widgets/admin/admin_news/news_search_and_filter_bar.dart';
import '../../widgets/admin/common/admin_card.dart';
import '../../widgets/admin/common/admin_dialog.dart';
import '../../widgets/admin/common/admin_page_header.dart';

/// Admin News – Modern Minimal.
class AdminNewsPage extends StatefulWidget {
  const AdminNewsPage({super.key});

  @override
  State<AdminNewsPage> createState() => _AdminNewsPageState();
}

class _AdminNewsPageState extends State<AdminNewsPage> {
  final NewsService _newsService = NewsService();
  final TextEditingController _searchController = TextEditingController();

  static const int _itemsPerPage = 10;

  List<NewsModel> _allArticles = [];
  List<NewsModel> _filtered = [];
  List<String> _categories = ['Tất cả'];
  String _selectedCategory = 'Tất cả';
  int _currentPage = 1;
  bool _isLoading = true;

  int get _totalPages =>
      (_filtered.length / _itemsPerPage).ceil().clamp(1, 9999);

  List<NewsModel> get _currentPageArticles {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= _filtered.length) return const [];
    return _filtered.sublist(
      start,
      end > _filtered.length ? _filtered.length : end,
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filter);
    _loadNews();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filter);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNews() async {
    setState(() => _isLoading = true);
    try {
      final news = await _newsService.getNewsList();
      final cats = await _newsService.getNewsCategories();
      if (!mounted) return;
      setState(() {
        _allArticles = news;
        _filtered = news;
        _categories = ['Tất cả', ...cats];
        _isLoading = false;
        _currentPage = 1;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _snack('Lỗi khi tải tin tức: $e', AppColors.error);
    }
  }

  void _filter() {
    final q = _searchController.text.toLowerCase();
    var list = _allArticles;
    if (_selectedCategory != 'Tất cả') {
      list = list.where((a) => a.category == _selectedCategory).toList();
    }
    if (q.isNotEmpty) {
      list = list
          .where((a) =>
              a.title.toLowerCase().contains(q) ||
              a.summary.toLowerCase().contains(q) ||
              a.author.toLowerCase().contains(q))
          .toList();
    }
    setState(() {
      _filtered = list;
      _currentPage = 1;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'Tất cả';
      _searchController.clear();
      _filter();
    });
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteArticle(NewsModel article) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AdminDialogShell(
        maxWidth: 460,
        title: 'Xoá bài viết?',
        subtitle:
            'Bài viết sẽ không thể khôi phục. Hãy chắc chắn trước khi xác nhận.',
        icon: Icons.delete_outline_rounded,
        iconBg: AppColors.errorContainer,
        iconFg: AppColors.errorDark,
        body: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.adminBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                article.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tác giả: ${article.author}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        footer: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AdminSecondaryButton(
              label: 'Hủy',
              onPressed: () => Navigator.of(context).pop(false),
            ),
            AppSpacing.gapMd,
            _DangerButton(
              onPressed: () => Navigator.of(context).pop(true),
              label: 'Xoá bài viết',
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;
    setState(() => _isLoading = true);
    try {
      await _newsService.deleteNews(article.id);
      await _loadNews();
      if (!mounted) return;
      _snack('Đã xoá bài viết', AppColors.success);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _snack('Lỗi: $e', AppColors.error);
    }
  }

  Future<void> _togglePublish(NewsModel article) async {
    setState(() => _isLoading = true);
    try {
      await _newsService.togglePublishStatus(
        article.id,
        !article.isPublished,
      );
      await _loadNews();
      if (!mounted) return;
      _snack(
        article.isPublished ? 'Đã ẩn bài viết' : 'Đã xuất bản bài viết',
        AppColors.success,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _snack('Lỗi: $e', AppColors.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final padding = isMobile
        ? AppSpacing.lg
        : (isTablet ? AppSpacing.xl2 : AppSpacing.xl3);

    return Container(
      color: AppColors.adminBackground,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminPageHeader(
              icon: Icons.article_outlined,
              title: 'Tin tức',
              subtitle:
                  '${_filtered.length} bài viết${_totalPages > 1 ? ' • Trang $_currentPage/$_totalPages' : ''}.',
              action: AdminPrimaryButton(
                icon: Icons.add_rounded,
                label: isMobile ? 'Thêm' : 'Thêm bài viết',
                onPressed: () => context.go('/admin/news/new'),
              ),
            ),
            NewsSearchAndFilterBar(
              searchController: _searchController,
              selectedCategory: _selectedCategory,
              categories: _categories,
              onCategoryChanged: (v) {
                setState(() => _selectedCategory = v);
                _filter();
              },
              onClearFilters: _clearFilters,
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: AdminCard(
                padding: EdgeInsets.zero,
                child: _isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: AppColors.primary500,
                          ),
                        ),
                      )
                    : _currentPageArticles.isEmpty
                        ? const _EmptyState()
                        : Column(
                            children: [
                              Expanded(
                                child: ListView.separated(
                                  padding: EdgeInsets.all(
                                    isMobile ? AppSpacing.md : AppSpacing.lg,
                                  ),
                                  itemCount: _currentPageArticles.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: AppSpacing.md),
                                  itemBuilder: (_, i) {
                                    final article = _currentPageArticles[i];
                                    return NewsListCard(
                                      article: article,
                                      isMobile: isMobile,
                                      formatDate: _formatDate,
                                      onEdit: () => context.go(
                                        '/admin/news/${article.id}/edit',
                                      ),
                                      onTogglePublish: () =>
                                          _togglePublish(article),
                                      onDelete: () => _deleteArticle(article),
                                    );
                                  },
                                ),
                              ),
                              NewsPagination(
                                currentPage: _currentPage,
                                totalPages: _totalPages,
                                onPageChanged: (p) =>
                                    setState(() => _currentPage = p),
                              ),
                            ],
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(AppRadius.xl2),
              ),
              child: const Icon(
                Icons.article_outlined,
                size: 26,
                color: AppColors.neutral400,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Không có bài viết nào',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Thử điều chỉnh bộ lọc hoặc thêm bài viết mới.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  const _DangerButton({required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.error,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.delete_outline_rounded,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
