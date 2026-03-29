import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../config/colors.dart';
import '../../config/spacing.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';

/// Admin Dashboard – Modern Minimal with Enhanced Beauty
///
/// Phong cách: phẳng, border 1px thay vì shadow đậm, typography gọn,
/// stat card có icon nhỏ đặt cạnh title, badge trạng thái tinh tế.
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  // Service instance được giữ ở State để tránh re-create stream mỗi rebuild.
  final _orderService = OrderService();
  final _productService = ProductService();

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    final padding = isMobile
        ? AppSpacing.pageSm
        : (isTablet ? AppSpacing.pageMd : AppSpacing.pageLg);

    return Container(
      color: AppColors.adminBackground,
      child: SingleChildScrollView(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DashboardHeader(),
            SizedBox(height: isMobile ? AppSpacing.xl : AppSpacing.xl2),
            _StatsGrid(
              isMobile: isMobile,
              isTablet: isTablet,
              orderService: _orderService,
              productService: _productService,
            ),
            SizedBox(height: isMobile ? AppSpacing.xl : AppSpacing.xl2),
            _ChartsSection(
              isMobile: isMobile,
              orderService: _orderService,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary500.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.dashboard_outlined,
                  size: 14,
                  color: AppColors.primary500,
                ),
                SizedBox(width: 4),
                Text(
                  'Tổng quan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary500,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chào mừng trở lại, Admin',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.6,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Đây là bảng điều khiển quản trị của bạn. Tại đây, bạn có thể theo dõi doanh thu, đơn hàng và sản phẩm theo thời gian thực.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats grid
// ---------------------------------------------------------------------------

class _StatsGrid extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final OrderService orderService;
  final ProductService productService;

  const _StatsGrid({
    required this.isMobile,
    required this.isTablet,
    required this.orderService,
    required this.productService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: orderService.getAllOrders(),
      builder: (context, orderSnapshot) {
        return StreamBuilder(
          stream: productService.getProducts(),
          builder: (context, productSnapshot) {
            final orders = orderSnapshot.data ?? const [];
            final products = productSnapshot.data ?? const [];

            final totalRevenue = orders
                .where((o) => o.status.value == 'completed')
                .fold<int>(0, (sum, o) => sum + (o.total as num).toInt());

            final completedOrders =
                orders.where((o) => o.status.value == 'completed').length;
            final pendingOrders =
                orders.where((o) => o.status.value == 'pending').length;
            final inStock =
                products.where((p) => p.status == 'Còn hàng').length;
            final completionRate = orders.isEmpty
                ? 0
                : ((completedOrders / orders.length) * 100).round();

            final stats = <_StatData>[
              _StatData(
                title: 'Tổng đơn hàng',
                value: _formatNumber(orders.length),
                hint: '$pendingOrders đang chờ',
                hintTone: _Tone.info,
                icon: Icons.receipt_long_outlined,
                accent: AppColors.info,
                trend: pendingOrders > 0 ? -pendingOrders : 0,
              ),
              _StatData(
                title: 'Doanh thu',
                value: _formatPrice(totalRevenue),
                hint: '$completedOrders đơn hoàn thành',
                hintTone: _Tone.success,
                icon: Icons.payments_outlined,
                accent: AppColors.success,
                trend: completedOrders > 0 ? completedOrders : 0,
              ),
              _StatData(
                title: 'Sản phẩm',
                value: _formatNumber(products.length),
                hint: '$inStock còn hàng',
                hintTone: _Tone.warning,
                icon: Icons.inventory_2_outlined,
                accent: AppColors.warning,
                trend: inStock,
              ),
              _StatData(
                title: 'Tỉ lệ hoàn thành',
                value: '$completionRate%',
                hint: '$completedOrders / ${orders.length} đơn',
                hintTone: _Tone.neutral,
                icon: Icons.check_circle_outline_rounded,
                accent: AppColors.primary500,
                trend: completionRate,
              ),
            ];

            return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 4),
                  crossAxisSpacing: AppSpacing.lg,
                  mainAxisSpacing: AppSpacing.lg,
                  childAspectRatio: isMobile ? 3.4 : (isTablet ? 2.4 : 2.0),
                ),
                itemCount: stats.length,
                itemBuilder: (_, i) => _StatCard(data: stats[i]),
              ),
            );
          },
        );
      },
    );
  }
}

enum _Tone { info, success, warning, neutral }

class _StatData {
  final String title;
  final String value;
  final String hint;
  final _Tone hintTone;
  final IconData icon;
  final Color accent;
  final num trend;

  const _StatData({
    required this.title,
    required this.value,
    required this.hint,
    required this.hintTone,
    required this.icon,
    required this.accent,
    this.trend = 0,
  });
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  Color get _hintFg {
    switch (data.hintTone) {
      case _Tone.success:
        return AppColors.successDark;
      case _Tone.info:
        return AppColors.infoDark;
      case _Tone.warning:
        return AppColors.warningDark;
      case _Tone.neutral:
        return AppColors.neutral600;
    }
  }

  Color get _hintBg {
    switch (data.hintTone) {
      case _Tone.success:
        return AppColors.successContainer;
      case _Tone.info:
        return AppColors.infoContainer;
      case _Tone.warning:
        return AppColors.warningContainer;
      case _Tone.neutral:
        return AppColors.neutral100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.adminBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        data.accent.withValues(alpha: 0.15),
                        data.accent.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Icon(data.icon, size: 20, color: data.accent),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
                if (data.trend > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 12,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '+${data.trend}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    data.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.8,
                      height: 1.1,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _hintBg,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: _hintFg.withValues(alpha: 0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    data.hint,
                    style: TextStyle(
                      color: _hintFg,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Charts
// ---------------------------------------------------------------------------

class _ChartsSection extends StatelessWidget {
  final bool isMobile;
  final OrderService orderService;
  const _ChartsSection({required this.isMobile, required this.orderService});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary500,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Phân tích dữ liệu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Biểu đồ thể hiện xu hướng doanh thu và đơn hàng',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (isMobile)
          Column(
            children: [
              _ChartCard(
                title: 'Doanh thu theo tháng',
                chartType: 'revenue',
                orderService: orderService,
              ),
              const SizedBox(height: AppSpacing.lg),
              _ChartCard(
                title: 'Đơn hàng theo ngày',
                chartType: 'orders',
                orderService: orderService,
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _ChartCard(
                  title: 'Doanh thu theo tháng',
                  chartType: 'revenue',
                  orderService: orderService,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _ChartCard(
                  title: 'Đơn hàng theo ngày',
                  chartType: 'orders',
                  orderService: orderService,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String chartType; // 'revenue' or 'orders'
  final OrderService orderService;

  const _ChartCard({
    required this.title,
    required this.chartType,
    required this.orderService,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.adminBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      chartType == 'revenue'
                          ? Icons.attach_money
                          : Icons.shopping_bag_outlined,
                      size: 18,
                      color: AppColors.primary500,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary500.withValues(alpha: 0.1),
                        AppColors.primary500.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    chartType == 'revenue' ? '6 tháng gần nhất' : '7 ngày qua',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            StreamBuilder(
              stream: orderService.getAllOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 240,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.surfaceMuted,
                          AppColors.surfaceMuted.withValues(alpha: 0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primary500,
                        ),
                      ),
                    ),
                  );
                }
                final orders = snapshot.data ?? const [];
                final data = chartType == 'revenue'
                    ? _getRevenueData(orders)
                    : _getOrdersData(orders);

                return TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(opacity: value, child: child);
                  },
                  child: SizedBox(
                    height: 240,
                    child: chartType == 'revenue'
                        ? _buildRevenueChart(data)
                        : _buildOrdersChart(data),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ----- Data -----

  List<Map<String, dynamic>> _getRevenueData(List orders) {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final date = DateTime(now.year, now.month - 5 + i, 1);
      final monthOrders = orders.where((o) {
        final d = o.createdAt;
        return d.year == date.year &&
            d.month == date.month &&
            o.status.value == 'completed';
      });
      final revenue = monthOrders.fold<double>(
        0,
        (s, o) => s + (o.total as num).toDouble(),
      );
      return {'label': '${date.month}/${date.year % 100}', 'value': revenue};
    });
  }

  List<Map<String, dynamic>> _getOrdersData(List orders) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      final count = orders.where((o) {
        final d = o.createdAt;
        return d.year == date.year &&
            d.month == date.month &&
            d.day == date.day;
      }).length;
      return {'label': '${date.day}/${date.month}', 'value': count.toDouble()};
    });
  }

  // ----- Charts -----

  Widget _buildRevenueChart(List<Map<String, dynamic>> data) {
    final maxValue =
        data.map((e) => e['value'] as double).fold<double>(0, (a, b) => a > b ? a : b);
    final safeMaxY = maxValue > 0 ? maxValue * 1.2 : 1.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: safeMaxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.neutral800,
            tooltipRoundedRadius: 10,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            getTooltipItem: (group, _, rod, __) => BarTooltipItem(
              _formatPrice(rod.toY.toInt()),
              const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    data[i]['label'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, _) => Text(
                _formatPriceShort(value),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data
            .asMap()
            .entries
            .map((e) => BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value['value'] as double,
                      color: AppColors.primary500,
                      width: 24,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary500,
                          AppColors.primary400,
                        ],
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: safeMaxY,
                        color: AppColors.surfaceMuted,
                      ),
                    ),
                  ],
                ))
            .toList(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: safeMaxY / 4,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.neutral100,
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersChart(List<Map<String, dynamic>> data) {
    final maxValue =
        data.map((e) => e['value'] as double).fold<double>(0, (a, b) => a > b ? a : b);
    final safeMaxY = maxValue > 0 ? maxValue * 1.2 : 1.0;
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value['value'] as double))
        .toList();

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.neutral800,
            tooltipRoundedRadius: 10,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      '${s.y.toInt()} đơn',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ))
                .toList(),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: safeMaxY / 4,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.neutral100,
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    data[i]['label'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, _) => Text(
                value.toInt().toString(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: safeMaxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.primary500,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 4.5,
                color: Colors.white,
                strokeWidth: 2.5,
                strokeColor: AppColors.primary500,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary500.withValues(alpha: 0.2),
                  AppColors.primary500.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Formatters
// ---------------------------------------------------------------------------

String _formatNumber(int n) =>
    n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );

String _formatPrice(int price) {
  if (price >= 1000000000) return '${(price / 1000000000).toStringAsFixed(1)} tỷ';
  if (price >= 1000000) return '${(price / 1000000).toStringAsFixed(1)} triệu';
  if (price >= 10000) return '${(price / 1000).toStringAsFixed(0)}k';
  return price.toString();
}

String _formatPriceShort(double price) {
  if (price >= 1000000000) return '${(price / 1000000000).toStringAsFixed(1)}T';
  if (price >= 1000000) return '${(price / 1000000).toStringAsFixed(1)}M';
  if (price >= 1000) return '${(price / 1000).toStringAsFixed(1)}K';
  return price.toInt().toString();
}