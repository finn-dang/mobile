import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../config/colors.dart';
import '../../config/spacing.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../widgets/admin/admin_users/mobile_users_view.dart';
import '../../widgets/admin/admin_users/users_data_table.dart';
import '../../widgets/admin/admin_users/users_search_and_filter_bar.dart';
import '../../widgets/admin/admin_users/users_stats.dart';
import '../../widgets/admin/common/admin_card.dart';
import '../../widgets/admin/common/admin_page_header.dart';

/// Admin Users – Modern Minimal.
class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();

  int _rowsPerPage = 10;
  int _sortColumnIndex = 4;
  bool _sortAscending = false;
  String? _selectedRole;
  String? _selectedStatus;
  Map<String, int> _ordersCount = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadOrdersCount();
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

  Future<void> _loadOrdersCount() async {
    try {
      final counts = await _userService.getAllUsersOrdersCount();
      if (mounted) setState(() => _ordersCount = counts);
    } catch (_) {}
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  List<UserModel> _filter(List<UserModel> users) {
    final query = _searchController.text.toLowerCase();
    return users.where((u) {
      final matchesSearch = query.isEmpty ||
          (u.displayName ?? '').toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query);
      final matchesRole = _selectedRole == null ||
          u.role.toLowerCase() == _selectedRole!.toLowerCase();
      final matchesStatus = _selectedStatus == null ||
          (_selectedStatus == 'Hoạt động' && u.isActive) ||
          (_selectedStatus == 'Khóa' && !u.isActive);
      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  List<UserModel> _sort(List<UserModel> users) {
    final sorted = List<UserModel>.from(users);
    sorted.sort((a, b) {
      int cmp;
      switch (_sortColumnIndex) {
        case 0:
          cmp = (a.displayName ?? a.email).compareTo(b.displayName ?? b.email);
          break;
        case 1:
          cmp = a.email.compareTo(b.email);
          break;
        case 2:
          cmp = a.role.compareTo(b.role);
          break;
        case 3:
          cmp = (a.isActive ? 1 : 0).compareTo(b.isActive ? 1 : 0);
          break;
        case 4:
          cmp = a.createdAt.compareTo(b.createdAt);
          break;
        case 5:
          cmp = (_ordersCount[a.uid] ?? 0)
              .compareTo(_ordersCount[b.uid] ?? 0);
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
      _selectedRole = null;
      _selectedStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Container(
      color: AppColors.adminBackground,
      child: StreamBuilder<List<UserModel>>(
        stream: _userService.getAllUsers(),
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

          final all = snapshot.data ?? const <UserModel>[];
          final sorted = _sort(_filter(all));

          if (isMobile) {
            return MobileUsersView(
              users: sorted,
              ordersCount: _ordersCount,
              searchController: _searchController,
              selectedRole: _selectedRole,
              selectedStatus: _selectedStatus,
              onRoleChanged: (v) => setState(() => _selectedRole = v),
              onStatusChanged: (v) =>
                  setState(() => _selectedStatus = v),
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
                  icon: Icons.people_outline,
                  title: 'Người dùng',
                  subtitle:
                      'Quản lý tài khoản, vai trò và trạng thái khoá. ${sorted.length} người dùng hiển thị.',
                ),
                UsersStats(users: sorted, isTablet: isTablet),
                const SizedBox(height: AppSpacing.lg),
                UsersSearchAndFilterBar(
                  searchController: _searchController,
                  selectedRole: _selectedRole,
                  selectedStatus: _selectedStatus,
                  onRoleChanged: (v) => setState(() => _selectedRole = v),
                  onStatusChanged: (v) =>
                      setState(() => _selectedStatus = v),
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
                    child: UsersDataTable(
                      users: sorted,
                      ordersCount: _ordersCount,
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
              'Không thể tải người dùng',
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
