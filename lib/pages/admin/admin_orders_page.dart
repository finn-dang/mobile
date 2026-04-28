import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../config/colors.dart';
import '../../config/spacing.dart';
import '../../models/order_model.dart';
import '../../models/order_status.dart';
import '../../services/order_service.dart';
import '../../widgets/admin/admin_orders/edit_order_dialog.dart';
import '../../widgets/admin/admin_orders/mobile_orders_view.dart';
import '../../widgets/admin/admin_orders/orders_data_table.dart';
import '../../widgets/admin/admin_orders/orders_search_and_filter_bar.dart';
import '../../widgets/admin/admin_orders/orders_stats.dart';
import '../../widgets/admin/common/admin_card.dart';
import '../../widgets/admin/common/admin_page_header.dart';
import '../../widgets/pages/orders/order_detail_dialog.dart';

/// Admin Orders – Modern Minimal.
///
/// State + orchestration. UI được tách thành các widget con trong
/// `lib/widgets/admin/admin_orders/`.
class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final OrderService _orderService = OrderService();
  final TextEditingController _searchController = TextEditingController();

  int _rowsPerPage = 10;
  int _sortColumnIndex = 7; // mặc định sort theo ngày đặt
  bool _sortAscending = false;
  OrderStatus? _selectedStatus;
  String? _selectedDateRange;

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

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _formatPrice(int price) => price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  List<OrderModel> _filter(List<OrderModel> orders) {
    final query = _searchController.text.toLowerCase();
    return orders.where((o) {
      final matchesSearch = query.isEmpty ||
          o.orderCode.toLowerCase().contains(query) ||
          o.fullName.toLowerCase().contains(query) ||
          o.phone.toLowerCase().contains(query);
      final matchesStatus =
          _selectedStatus == null || o.status == _selectedStatus;
      final matchesDate =
          OrderDateRange.match(_selectedDateRange, o.createdAt);
      return matchesSearch && matchesStatus && matchesDate;
    }).toList();
  }

  List<OrderModel> _sort(List<OrderModel> orders) {
    final sorted = List<OrderModel>.from(orders);
    sorted.sort((a, b) {
      int cmp;
      switch (_sortColumnIndex) {
        case 0:
          cmp = a.orderCode.compareTo(b.orderCode);
          break;
        case 1:
          cmp = a.fullName.compareTo(b.fullName);
          break;
        case 2:
          cmp = a.items.length.compareTo(b.items.length);
          break;
        case 3:
          cmp = a.total.compareTo(b.total);
          break;
        case 4:
          cmp = a.paymentMethod.name.compareTo(b.paymentMethod.name);
          break;
        case 5:
          cmp = a.paymentStatus.displayName.compareTo(b.paymentStatus.displayName);
          break;
        case 6:
          cmp = a.status.adminDisplayName.compareTo(b.status.adminDisplayName);
          break;
        case 7:
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
      _selectedStatus = null;
      _selectedDateRange = null;
    });
  }

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  void _showDetail(OrderModel order) {
    showDialog(
      context: context,
      builder: (_) => OrderDetailDialog(order: order),
    );
  }

  void _showEdit(OrderModel order) {
    showDialog(
      context: context,
      builder: (_) => EditOrderDialog(
        order: order,
        onStatusUpdated: (id, status) {
          // StreamBuilder sẽ tự cập nhật, đây chỉ là hook nếu cần.
        },
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
      child: StreamBuilder<List<OrderModel>>(
        stream: _orderService.getAllOrders(),
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

          final all = snapshot.data ?? const <OrderModel>[];
          final filtered = _filter(all);
          final sorted = _sort(filtered);

          if (isMobile) {
            return MobileOrdersView(
              orders: sorted,
              searchController: _searchController,
              selectedStatus: _selectedStatus,
              selectedDateRange: _selectedDateRange,
              onStatusChanged: (v) =>
                  setState(() => _selectedStatus = v),
              onDateRangeChanged: (v) =>
                  setState(() => _selectedDateRange = v),
              onClearFilters: _clearFilters,
              formatPrice: _formatPrice,
              formatDate: _formatDate,
              onView: _showDetail,
              onEdit: _showEdit,
            );
          }

          return _DesktopBody(
            isTablet: isTablet,
            orders: sorted,
            searchController: _searchController,
            selectedStatus: _selectedStatus,
            selectedDateRange: _selectedDateRange,
            rowsPerPage: _rowsPerPage,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            formatPrice: _formatPrice,
            formatDate: _formatDate,
            onStatusChanged: (v) => setState(() => _selectedStatus = v),
            onDateRangeChanged: (v) =>
                setState(() => _selectedDateRange = v),
            onClearFilters: _clearFilters,
            onSort: _onSort,
            onRowsPerPageChanged: (v) =>
                setState(() => _rowsPerPage = v ?? 10),
            onView: _showDetail,
            onEdit: _showEdit,
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop body
// ---------------------------------------------------------------------------

class _DesktopBody extends StatelessWidget {
  final bool isTablet;
  final List<OrderModel> orders;
  final TextEditingController searchController;
  final OrderStatus? selectedStatus;
  final String? selectedDateRange;
  final int rowsPerPage;
  final int sortColumnIndex;
  final bool sortAscending;
  final String Function(int) formatPrice;
  final String Function(DateTime) formatDate;

  final ValueChanged<OrderStatus?> onStatusChanged;
  final ValueChanged<String?> onDateRangeChanged;
  final VoidCallback onClearFilters;
  final void Function(int, bool) onSort;
  final ValueChanged<int?> onRowsPerPageChanged;
  final void Function(OrderModel) onView;
  final void Function(OrderModel) onEdit;

  const _DesktopBody({
    required this.isTablet,
    required this.orders,
    required this.searchController,
    required this.selectedStatus,
    required this.selectedDateRange,
    required this.rowsPerPage,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.formatPrice,
    required this.formatDate,
    required this.onStatusChanged,
    required this.onDateRangeChanged,
    required this.onClearFilters,
    required this.onSort,
    required this.onRowsPerPageChanged,
    required this.onView,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final padding = isTablet ? AppSpacing.pageMd : AppSpacing.pageLg;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminPageHeader(
            icon: Icons.receipt_long_outlined,
            title: 'Đơn hàng',
            subtitle:
                'Theo dõi và cập nhật trạng thái đơn hàng. ${orders.length} đơn hiển thị.',
          ),
          OrdersStats(
            orders: orders,
            isTablet: isTablet,
            formatPrice: formatPrice,
          ),
          const SizedBox(height: AppSpacing.lg),
          OrdersSearchAndFilterBar(
            searchController: searchController,
            selectedStatus: selectedStatus,
            selectedDateRange: selectedDateRange,
            onStatusChanged: onStatusChanged,
            onDateRangeChanged: onDateRangeChanged,
            onClearFilters: onClearFilters,
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
              child: OrdersDataTable(
                orders: orders,
                onSort: onSort,
                sortColumnIndex: sortColumnIndex,
                sortAscending: sortAscending,
                rowsPerPage: rowsPerPage,
                onRowsPerPageChanged: onRowsPerPageChanged,
                isTablet: isTablet,
                formatPrice: formatPrice,
                formatDate: formatDate,
                onView: onView,
                onEdit: onEdit,
              ),
            ),
          ),
        ],
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
              'Không thể tải đơn hàng',
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
