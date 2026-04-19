import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/user_model.dart';
import '../common/admin_card.dart';

class UsersDataTable extends StatelessWidget {
  final List<UserModel> users;
  final Map<String, int> ordersCount;
  final Function(int, bool) onSort;
  final int sortColumnIndex;
  final bool sortAscending;
  final int rowsPerPage;
  final ValueChanged<int?>? onRowsPerPageChanged;
  final bool isTablet;
  final String Function(DateTime) formatDate;
  final Function(UserModel)? onEdit;
  final Function(UserModel)? onDelete;

  const UsersDataTable({
    super.key,
    required this.users,
    required this.ordersCount,
    required this.onSort,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.rowsPerPage,
    this.onRowsPerPageChanged,
    required this.isTablet,
    required this.formatDate,
    this.onEdit,
    this.onDelete,
  });

  static const TextStyle _headerStyle = TextStyle(
    color: AppColors.neutral600,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    letterSpacing: 0.3,
  );

  DataColumn2 _column(
    String label, {
    ColumnSize size = ColumnSize.M,
    bool numeric = false,
    int? sortIndex,
  }) =>
      DataColumn2(
        label: Text(label.toUpperCase(), style: _headerStyle),
        size: size,
        numeric: numeric,
        onSort: sortIndex == null
            ? null
            : (_, ascending) => onSort(sortIndex, ascending),
      );

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable2(
      minWidth: isTablet ? 800 : 1100,
      columnSpacing: isTablet ? 8 : 16,
      horizontalMargin: isTablet ? 8 : 16,
      rowsPerPage: rowsPerPage,
      onRowsPerPageChanged: onRowsPerPageChanged,
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
      headingRowColor: WidgetStateProperty.all(AppColors.neutral50),
      headingRowHeight: 44,
      dataRowHeight: 60,
      dividerThickness: 0.6,
      border: TableBorder(
        horizontalInside: BorderSide(
          color: AppColors.neutral100,
          width: 1,
        ),
      ),
      columns: [
        _column('Tên', size: ColumnSize.L, sortIndex: 0),
        _column('Email', size: ColumnSize.L, sortIndex: 1),
        _column('Vai trò', size: ColumnSize.M, sortIndex: 2),
        _column('Trạng thái', size: ColumnSize.M, sortIndex: 3),
        _column('Ngày đăng ký', size: ColumnSize.M, sortIndex: 4),
        _column('Đơn hàng', size: ColumnSize.S, numeric: true, sortIndex: 5),
        _column('Hành động', size: ColumnSize.S),
      ],
      source: UsersDataSource(
        users: users,
        ordersCount: ordersCount,
        context: context,
        formatDate: formatDate,
        onEdit: onEdit ??
            (u) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Chỉnh sửa: ${u.displayName ?? u.email}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
        onDelete: onDelete ??
            (u) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Xoá: ${u.displayName ?? u.email}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
      ),
      empty: const _EmptyState(),
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
                Icons.people_outline,
                size: 26,
                color: AppColors.neutral400,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Không có người dùng nào',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Thử điều chỉnh bộ lọc hoặc kiểm tra lại sau.',
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

class UsersDataSource extends DataTableSource {
  final List<UserModel> users;
  final Map<String, int> ordersCount;
  final BuildContext context;
  final String Function(DateTime) formatDate;
  final Function(UserModel) onEdit;
  final Function(UserModel) onDelete;

  UsersDataSource({
    required this.users,
    required this.ordersCount,
    required this.context,
    required this.formatDate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;
    final user = users[index];
    final name = user.displayName ?? user.email.split('@').first;
    final isAdmin = user.role.toLowerCase() == 'admin';

    return DataRow2(
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _UserAvatar(name: name),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            user.email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        DataCell(
          isAdmin
              ? AdminStatusPill(
                  label: 'ADMIN',
                  fg: AppColors.primary700,
                  bg: AppColors.primary50,
                  icon: Icons.admin_panel_settings_outlined,
                )
              : AdminStatusPill.info(
                  'USER',
                  icon: Icons.person_outline_rounded,
                ),
        ),
        DataCell(
          user.isActive
              ? AdminStatusPill.success(
                  'Hoạt động',
                  icon: Icons.check_circle_outline_rounded,
                )
              : AdminStatusPill.danger(
                  'Đã khoá',
                  icon: Icons.block_rounded,
                ),
        ),
        DataCell(
          Text(
            formatDate(user.createdAt),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        DataCell(
          Text(
            (ordersCount[user.uid] ?? 0).toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconAction(
                icon: Icons.edit_outlined,
                tooltip: 'Chỉnh sửa',
                color: AppColors.primary600,
                onPressed: () => onEdit(user),
              ),
              AppSpacing.gapXs,
              _IconAction(
                icon: Icons.delete_outline_rounded,
                tooltip: 'Xoá',
                color: AppColors.error,
                onPressed: () => onDelete(user),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => users.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

class _UserAvatar extends StatelessWidget {
  final String name;
  const _UserAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: AppColors.primary600,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _IconAction extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;

  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_IconAction> createState() => _IconActionState();
}

class _IconActionState extends State<_IconAction> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: SizedBox(
        width: 30,
        height: 30,
        child: Material(
          color: _hover
              ? widget.color.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: InkWell(
            onTap: widget.onPressed,
            onHover: (v) => setState(() => _hover = v),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Icon(widget.icon, size: 16, color: widget.color),
          ),
        ),
      ),
    );
  }
}
