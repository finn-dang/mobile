import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../common/admin_card.dart';

/// Search & Filter cho Users – Modern Minimal.
class UsersSearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String? selectedRole;
  final String? selectedStatus;
  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClearFilters;
  final bool isTablet;

  const UsersSearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.selectedRole,
    required this.selectedStatus,
    required this.onRoleChanged,
    required this.onStatusChanged,
    required this.onClearFilters,
    required this.isTablet,
  });

  bool get _hasFilter =>
      selectedRole != null ||
      selectedStatus != null ||
      searchController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    return AdminCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: isMobile ? _buildMobile() : _buildDesktop(),
    );
  }

  Widget _buildDesktop() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _MinimalTextField(
            controller: searchController,
            hintText: 'Tìm theo tên hoặc email...',
          ),
        ),
        AppSpacing.gapMd,
        Expanded(
          flex: 2,
          child: _RoleDropdown(
            value: selectedRole,
            onChanged: onRoleChanged,
          ),
        ),
        AppSpacing.gapMd,
        Expanded(
          flex: 2,
          child: _StatusDropdown(
            value: selectedStatus,
            onChanged: onStatusChanged,
          ),
        ),
        if (_hasFilter) ...[
          AppSpacing.gapSm,
          _ClearButton(onPressed: onClearFilters),
        ],
      ],
    );
  }

  Widget _buildMobile() {
    return Column(
      children: [
        _MinimalTextField(
          controller: searchController,
          hintText: 'Tìm người dùng...',
        ),
        AppSpacing.gapSm,
        Row(
          children: [
            Expanded(
              child: _RoleDropdown(
                value: selectedRole,
                onChanged: onRoleChanged,
              ),
            ),
            AppSpacing.gapSm,
            Expanded(
              child: _StatusDropdown(
                value: selectedStatus,
                onChanged: onStatusChanged,
              ),
            ),
          ],
        ),
        if (_hasFilter) ...[
          AppSpacing.gapSm,
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
              label: const Text('Xoá bộ lọc'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  side: const BorderSide(color: AppColors.adminBorder),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

OutlineInputBorder _border(Color color, {double width = 1}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );

class _MinimalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  const _MinimalTextField({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        style:
            const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 13.5,
            color: AppColors.neutral400,
          ),
          isDense: true,
          filled: true,
          fillColor: AppColors.surface,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 10, right: 4),
            child: Icon(
              Icons.search_rounded,
              size: 18,
              color: AppColors.neutral400,
            ),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 32, minHeight: 32),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  iconSize: 16,
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.neutral500,
                  ),
                  onPressed: () => controller.clear(),
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: _border(AppColors.adminBorder),
          enabledBorder: _border(AppColors.adminBorder),
          focusedBorder: _border(AppColors.primary500, width: 1.5),
        ),
      ),
    );
  }
}

class _RoleDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _RoleDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: DropdownButtonFormField<String?>(
        value: value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 18,
          color: AppColors.neutral500,
        ),
        style:
            const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Vai trò',
          isDense: true,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: _border(AppColors.adminBorder),
          enabledBorder: _border(AppColors.adminBorder),
          focusedBorder: _border(AppColors.primary500, width: 1.5),
        ),
        items: const [
          DropdownMenuItem<String?>(
            value: null,
            child: Text('Tất cả vai trò'),
          ),
          DropdownMenuItem<String?>(value: 'admin', child: Text('Admin')),
          DropdownMenuItem<String?>(value: 'user', child: Text('User')),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _StatusDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: DropdownButtonFormField<String?>(
        value: value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 18,
          color: AppColors.neutral500,
        ),
        style:
            const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Trạng thái',
          isDense: true,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: _border(AppColors.adminBorder),
          enabledBorder: _border(AppColors.adminBorder),
          focusedBorder: _border(AppColors.primary500, width: 1.5),
        ),
        items: const [
          DropdownMenuItem<String?>(
            value: null,
            child: Text('Tất cả trạng thái'),
          ),
          DropdownMenuItem<String?>(
            value: 'Hoạt động',
            child: Text('Hoạt động'),
          ),
          DropdownMenuItem<String?>(
            value: 'Khóa',
            child: Text('Đã khoá'),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ClearButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Xoá bộ lọc',
      child: SizedBox(
        height: 40,
        width: 40,
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.adminBorder),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.filter_alt_off_outlined,
                size: 18,
                color: AppColors.neutral600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
