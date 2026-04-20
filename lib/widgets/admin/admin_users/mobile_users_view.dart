import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import 'users_search_and_filter_bar.dart';

class MobileUsersView extends StatelessWidget {
  final List<UserModel> users;
  final Map<String, int> ordersCount;
  final TextEditingController searchController;
  final String? selectedRole;
  final String? selectedStatus;
  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClearFilters;
  final Function(int, bool) onSort;
  final int sortColumnIndex;
  final bool sortAscending;
  final String Function(DateTime) formatDate;

  const MobileUsersView({
    super.key,
    required this.users,
    required this.ordersCount,
    required this.searchController,
    required this.selectedRole,
    required this.selectedStatus,
    required this.onRoleChanged,
    required this.onStatusChanged,
    required this.onClearFilters,
    required this.onSort,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quản lý người dùng',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
          ),
          const SizedBox(height: 16),
          // Search and Filter
          UsersSearchAndFilterBar(
            searchController: searchController,
            selectedRole: selectedRole,
            selectedStatus: selectedStatus,
            onRoleChanged: onRoleChanged,
            onStatusChanged: onStatusChanged,
            onClearFilters: onClearFilters,
            isTablet: false,
          ),
          const SizedBox(height: 16),
          // Mobile list view
          ...users.map((user) {
            final userName = user.displayName ?? user.email.split('@').first;
            final isActive = user.isActive;
            final role = user.role;
            final roleColor = role.toLowerCase() == 'admin' ? Colors.red : Colors.blue;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  userName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.email),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isActive ? 'Hoạt động' : 'Khóa',
                            style: TextStyle(
                              color: isActive ? Colors.green[700] : Colors.red[700],
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: roleColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            role.toUpperCase(),
                            style: TextStyle(
                              color: roleColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${ordersCount[user.uid] ?? 0} đơn',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDate(user.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Chỉnh sửa'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xóa', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      // TODO: Edit user
                    } else if (value == 'delete') {
                      // TODO: Delete user
                    }
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

