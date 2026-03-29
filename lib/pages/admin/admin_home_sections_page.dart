import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../config/colors.dart';
import '../../config/spacing.dart';
import '../../models/home_section_model.dart';
import '../../services/home_section_service.dart';
import '../../widgets/admin/admin_home_sections/create_section_dialog.dart';
import '../../widgets/admin/admin_home_sections/delete_section_dialog.dart';
import '../../widgets/admin/admin_home_sections/edit_section_dialog.dart';
import '../../widgets/admin/admin_home_sections/mobile_sections_view.dart';
import '../../widgets/admin/admin_home_sections/sections_data_table.dart';
import '../../widgets/admin/admin_home_sections/sections_search_and_filter_bar.dart';
import '../../widgets/admin/admin_home_sections/sections_stats.dart';
import '../../widgets/admin/common/admin_card.dart';
import '../../widgets/admin/common/admin_page_header.dart';

/// Admin Home Sections – Modern Minimal.
class AdminHomeSectionsPage extends StatefulWidget {
  const AdminHomeSectionsPage({super.key});

  @override
  State<AdminHomeSectionsPage> createState() => _AdminHomeSectionsPageState();
}

class _AdminHomeSectionsPageState extends State<AdminHomeSectionsPage> {
  final _sectionService = HomeSectionService();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;

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

  List<HomeSectionModel> _filter(List<HomeSectionModel> sections) {
    final query = _searchController.text.toLowerCase();
    return sections.where((s) {
      final matchesSearch = query.isEmpty ||
          s.title.toLowerCase().contains(query);
      final matchesStatus = _selectedStatus == null ||
          (_selectedStatus == 'Đang hiển thị' && s.isActive) ||
          (_selectedStatus == 'Tạm tắt' && !s.isActive);
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
    });
  }

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  Future<void> _handleCreate() async {
    final result = await showDialog<HomeSectionModel>(
      context: context,
      builder: (_) => const CreateSectionDialog(),
    );
    if (result != null && mounted) {
      try {
        await _sectionService.createSection(result);
        if (!mounted) return;
        _snack('Đã tạo bộ sưu tập thành công', AppColors.success);
      } catch (e) {
        if (!mounted) return;
        _snack('Lỗi: $e', AppColors.error);
      }
    }
  }

  Future<void> _handleEdit(HomeSectionModel section) async {
    final result = await showDialog<HomeSectionModel>(
      context: context,
      builder: (_) => EditSectionDialog(section: section),
    );
    if (result != null && mounted) {
      try {
        await _sectionService.updateSection(result);
        if (!mounted) return;
        _snack('Đã cập nhật bộ sưu tập', AppColors.success);
      } catch (e) {
        if (!mounted) return;
        _snack('Lỗi: $e', AppColors.error);
      }
    }
  }

  Future<void> _handleDelete(HomeSectionModel section) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteSectionDialog(section: section),
    );
    if (confirmed == true && mounted) {
      try {
        await _sectionService.deleteSection(section.id);
        if (!mounted) return;
        _snack('Đã xoá: ${section.title}', AppColors.success);
      } catch (e) {
        if (!mounted) return;
        _snack('Lỗi: $e', AppColors.error);
      }
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Container(
      color: AppColors.adminBackground,
      child: StreamBuilder<List<HomeSectionModel>>(
        stream: _sectionService.getAllSections(),
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

          final all = snapshot.data ?? const <HomeSectionModel>[];
          final filtered = _filter(all);

          final padding =
              isMobile ? AppSpacing.lg : (isTablet ? AppSpacing.xl2 : AppSpacing.xl3);

          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminPageHeader(
                  icon: Icons.view_list_outlined,
                  title: 'Bộ sưu tập trang chủ',
                  subtitle:
                      'Cấu hình các nhóm sản phẩm nổi bật trên trang chủ. ${all.length} bộ sưu tập.',
                  action: AdminPrimaryButton(
                    icon: Icons.add_rounded,
                    label: isMobile || isTablet ? 'Thêm' : 'Thêm bộ sưu tập',
                    onPressed: _handleCreate,
                  ),
                ),
                if (!isMobile) ...[
                  SectionsStats(sections: all),
                  const SizedBox(height: AppSpacing.lg),
                ],
                SectionsSearchAndFilterBar(
                  searchController: _searchController,
                  selectedStatus: _selectedStatus,
                  onStatusChanged: (s) =>
                      setState(() => _selectedStatus = s),
                  onClearFilters: _clearFilters,
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: isMobile
                      ? MobileSectionsView(
                          sections: filtered,
                          onEdit: _handleEdit,
                          onDelete: _handleDelete,
                        )
                      : AdminCard(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.sm,
                            AppSpacing.sm,
                            AppSpacing.sm,
                            0,
                          ),
                          child: SectionsDataTable(
                            sections: filtered,
                            onEdit: _handleEdit,
                            onDelete: _handleDelete,
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
              'Không thể tải bộ sưu tập',
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
