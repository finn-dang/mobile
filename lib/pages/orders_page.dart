import 'package:flutter/material.dart';
import '../models/order_status.dart';
import '../widgets/pages/orders/orders_tab.dart';
import '../widgets/pages/orders/my_reviews_tab.dart';
import '../config/colors.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.headerBackground.withValues(alpha: 0.03),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          // TabBar with modern design
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              indicatorPadding: EdgeInsets.symmetric(horizontal: 0),
              indicatorWeight: 0,
              unselectedLabelColor: Colors.grey[700],
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.headerBackground,
                    AppColors.primaryLight,
                  ],
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 0),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              isScrollable: true,
              tabs: const [
                Tab(text: 'Chờ xử lý'),
                Tab(text: 'Đang giao'),
                Tab(text: 'Hoàn thành'),
                Tab(text: 'Hủy bỏ'),
                Tab(text: 'Đánh giá của tôi'),
              ],
            ),
          ),
          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                OrdersTab(statuses: [
                  OrderStatus.pending,
                  OrderStatus.confirmed,
                  OrderStatus.processing,
                ]),
                OrdersTab(statuses: [OrderStatus.delivering]),
                OrdersTab(statuses: [OrderStatus.completed]),
                OrdersTab(statuses: [OrderStatus.cancelled]),
                const MyReviewsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

