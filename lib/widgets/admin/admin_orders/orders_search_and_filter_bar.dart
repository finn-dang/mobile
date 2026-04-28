import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/order_status.dart';
import '../common/admin_card.dart';

/// Date range presets dùng cho filter Orders.
class OrderDateRange {
  static const String today = 'today';
  static const String week = 'week';
  static const String month = 'month';
  static const String year = 'year';

  /// Trả về true nếu [date] thoả khoảng thời gian [preset].
  static bool match(String? preset, DateTime date) {
    if (preset == null) return true;
    final now = DateTime.now();
    switch (preset) {
      case today:
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      case week:
        // Tuần hiện tại (Monday → Sunday)
        final weekday = now.weekday; // 1=Mon, 7=Sun
        final weekStart = DateTime(now.year, now.month, now.day - (weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return !date.isBefore(weekStart) && !date.isAfter(weekEnd);
      case month:
        return date.year == now.year && date.month == now.month;
      case year:
        return date.year == now.year;
      default:
        return true;
    }
  }

  static String label(String? preset) {
    switch (preset) {
      case today:
        return 'Hôm nay';
      case week:
        return 'Tuần này';
      case month:
        return 'Tháng này';
      case year:
        return 'Năm nay';
      default:
        return 'Tất cả thời gian';
    }
  }
}

/// Search & Filter cho Orders – Modern Minimal.
class OrdersSearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final OrderStatus? selectedStatus;
  final String? selectedDateRange;
  final ValueChanged<OrderStatus?> onStatusChanged;
  final ValueChanged<String?> onDateRangeChanged;
  final VoidCallback onClearFilters;
  final bool isTablet;
  final bool isMobile;

  const OrdersSearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.selectedStatus,
    required this.selectedDateRange,
    required this.onStatusChanged,
    required this.onDateRangeChanged,
    required this.onClearFilters,
    required this.isTablet,
    this.isMobile = false,
  });

  bool get _hasFilter =>
      selectedStatus != null ||
      selectedDateRange != null ||
      searchController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
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
            hintText: 'Tìm theo mã đơn, tên khách hàng, số điện thoại...',
            prefix: const Icon(
              Icons.search_rounded,
              size: 18,
              color: AppColors.neutral400,
            ),
            suffix: searchController.text.isNotEmpty
                ? IconButton(
                    iconSize: 16,
                    splashRadius: 16,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.neutral500,
                    ),
                    onPressed: () => searchController.clear(),
                  )
                : null,
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
        AppSpacing.gapMd,
        Expanded(
          flex: 2,
          child: _DateRangeDropdown(
            value: selectedDateRange,
            onChanged: onDateRangeChanged,
          ),
        ),
        if (_hasFilter) ...[
          AppSpacing.gapSm,
          _ClearFiltersButton(onPressed: onClearFilters),
        ],
      ],
    );
  }

  Widget _buildMobile() {
    return Column(
      children: [
        _MinimalTextField(
          controller: searchController,
          hintText: 'Tìm đơn hàng...',
          prefix: const Icon(
            Icons.search_rounded,
            size: 18,
            color: AppColors.neutral400,
          ),
          suffix: searchController.text.isNotEmpty
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
                  onPressed: () => searchController.clear(),
                )
              : null,
        ),
        AppSpacing.gapSm,
        Row(
          children: [
            Expanded(
              child: _StatusDropdown(
                value: selectedStatus,
                onChanged: onStatusChanged,
              ),
            ),
            AppSpacing.gapSm,
            Expanded(
              child: _DateRangeDropdown(
                value: selectedDateRange,
                onChanged: onDateRangeChanged,
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

// ---------------------------------------------------------------------------
// Internal sub-widgets
// ---------------------------------------------------------------------------

class _MinimalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? prefix;
  final Widget? suffix;
  const _MinimalTextField({
    required this.controller,
    required this.hintText,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontSize: 13.5,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 13.5,
            color: AppColors.neutral400,
          ),
          isDense: true,
          filled: true,
          fillColor: AppColors.surface,
          prefixIcon: prefix == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(left: 10, right: 4),
                  child: prefix,
                ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 32, minHeight: 32),
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: _border(AppColors.adminBorder),
          enabledBorder: _border(AppColors.adminBorder),
          focusedBorder: _border(AppColors.primary500, width: 1.5),
        ),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final OrderStatus? value;
  final ValueChanged<OrderStatus?> onChanged;
  const _StatusDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: DropdownButtonFormField<OrderStatus?>(
        value: value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 18,
          color: AppColors.neutral500,
        ),
        style: const TextStyle(
          fontSize: 13.5,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Trạng thái',
          hintStyle: const TextStyle(
            fontSize: 13.5,
            color: AppColors.neutral400,
          ),
          isDense: true,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: _border(AppColors.adminBorder),
          enabledBorder: _border(AppColors.adminBorder),
          focusedBorder: _border(AppColors.primary500, width: 1.5),
        ),
        items: [
          const DropdownMenuItem<OrderStatus?>(
            value: null,
            child: Text('Tất cả trạng thái'),
          ),
          ...OrderStatus.values.map(
            (s) => DropdownMenuItem<OrderStatus?>(
              value: s,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: s.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      s.adminDisplayName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _DateRangeDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const _DateRangeDropdown({required this.value, required this.onChanged});

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
        style: const TextStyle(
          fontSize: 13.5,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Thời gian',
          hintStyle: const TextStyle(
            fontSize: 13.5,
            color: AppColors.neutral400,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 10, right: 4),
            child: Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: AppColors.neutral500,
            ),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 30, minHeight: 32),
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
          DropdownMenuItem<String?>(value: null, child: Text('Tất cả')),
          DropdownMenuItem<String?>(
              value: OrderDateRange.today, child: Text('Hôm nay')),
          DropdownMenuItem<String?>(
              value: OrderDateRange.week, child: Text('Tuần này')),
          DropdownMenuItem<String?>(
              value: OrderDateRange.month, child: Text('Tháng này')),
          DropdownMenuItem<String?>(
              value: OrderDateRange.year, child: Text('Năm nay')),
        ],
        onChanged: onChanged,
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _ClearFiltersButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ClearFiltersButton({required this.onPressed});

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
