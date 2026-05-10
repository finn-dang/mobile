import 'package:go_router/go_router.dart';
import '../../pages/home_page.dart';
import '../../pages/products_page.dart';
import '../../pages/categories_page.dart';
import '../../pages/cart_page.dart';
import '../../pages/orders_page.dart';
// import '../../pages/profile_page.dart';
import '../../pages/product_detail_page.dart';
import '../../pages/login_page.dart';
import '../../pages/checkout_page.dart';
import '../../pages/payos_return_page.dart';
import '../../pages/payos_cancel_page.dart';
import '../../pages/news_page.dart';
import '../../pages/news_detail_page.dart';
import '../../models/cart_model.dart';
import '../../pages/admin/admin_dashboard_page.dart';
import '../../pages/admin/admin_products_page.dart';
import '../../pages/admin/admin_product_form_page.dart';
import '../../pages/admin/admin_categories_page.dart';
import '../../pages/admin/admin_orders_page.dart';
import '../../pages/admin/admin_reviews_page.dart';
import '../../pages/admin/admin_users_page.dart';
import '../../pages/admin/admin_home_sections_page.dart';
import '../../pages/admin/admin_analytics_page.dart';
import '../../pages/admin/admin_settings_page.dart';
import '../../pages/admin/admin_news_page.dart';
import '../../pages/admin/admin_news_form_page.dart';
import '../../services/auth_service.dart';
import '../../widgets/shell_layout.dart';
import '../../widgets/product_chatbot/product_chatbot_page.dart';
import '../../widgets/admin/admin_shell_layout.dart';

final AuthService _authService = AuthService();
const Set<String> _protectedCustomerPaths = {
  '/cart',
  '/orders',
  '/checkout',
};

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: _authService,
  redirect: (context, state) async {
    final path = state.uri.path;
    final isLoginRoute = path == '/login';
    final isAdminRoute = path == '/admin' || path.startsWith('/admin/');
    final isProtectedCustomerRoute = _protectedCustomerPaths.contains(path);
    final isLoggedIn = _authService.isLoggedIn;

    if (!isLoggedIn) {
      if (isAdminRoute || isProtectedCustomerRoute) {
        return '/login';
      }
      return null;
    }

    final isAdmin = await _authService.isCurrentUserAdmin();

    if (isLoginRoute) {
      return isAdmin ? '/admin' : '/';
    }

    if (isAdminRoute && !isAdmin) {
      return '/';
    }

    return null;
  },
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ShellLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/products/:id',
          name: 'product-detail',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return ProductDetailPage(productId: id);
          },
        ),
        GoRoute(
          path: '/products',
          name: 'products',
          builder: (context, state) => const ProductsPage(),
        ),
        GoRoute(
          path: '/categories',
          name: 'categories',
          builder: (context, state) => const CategoriesPage(),
        ),
        GoRoute(
          path: '/chat',
          name: 'chat',
          builder: (context, state) => const ProductChatbotPage(),
        ),
        GoRoute(
          path: '/news',
          name: 'news',
          builder: (context, state) => const NewsPage(),
        ),
        GoRoute(
          path: '/news/:id',
          name: 'news-detail',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return NewsDetailPage(newsId: id);
          },
        ),
        GoRoute(
          path: '/cart',
          name: 'cart',
          builder: (context, state) => const CartPage(),
        ),
        GoRoute(
          path: '/orders',
          name: 'orders',
          builder: (context, state) => const OrdersPage(),
        ),
        // GoRoute(
        //   path: '/profile',
        //   name: 'profile',
        //   builder: (context, state) => const ProfilePage(),
        // ),
        GoRoute(
          path: '/checkout',
          name: 'checkout',
          builder: (context, state) {
            // Lấy specificItems từ extra nếu có
            final specificItems = state.extra as List<CartItemModel>?;
            if (specificItems != null && specificItems.isNotEmpty) {
              return CheckoutPage(specificItems: specificItems);
            }
            return const CheckoutPage();
          },
        ),
        GoRoute(
          path: '/payment/payos-return',
          name: 'payos-return',
          builder: (context, state) {
            final orderId = state.uri.queryParameters['orderId'] ?? '';
            return PayOsReturnPage(orderId: orderId);
          },
        ),
        GoRoute(
          path: '/payment/payos-cancel',
          name: 'payos-cancel',
          builder: (context, state) {
            final orderId = state.uri.queryParameters['orderId'] ?? '';
            return PayOsCancelPage(orderId: orderId);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return AdminShellLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/admin',
          name: 'admin-dashboard',
          builder: (context, state) => const AdminDashboardPage(),
        ),
        GoRoute(
          path: '/admin/products',
          name: 'admin-products',
          builder: (context, state) => const AdminProductsPage(),
        ),
        GoRoute(
          path: '/admin/products/new',
          name: 'admin-product-create',
          builder: (context, state) => const AdminProductFormPage(),
        ),
        GoRoute(
          path: '/admin/products/:id/edit',
          name: 'admin-product-edit',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return AdminProductFormPage(productId: id);
          },
        ),
        GoRoute(
          path: '/admin/categories',
          name: 'admin-categories',
          builder: (context, state) => const AdminCategoriesPage(),
        ),
        GoRoute(
          path: '/admin/orders',
          name: 'admin-orders',
          builder: (context, state) => const AdminOrdersPage(),
        ),
        GoRoute(
          path: '/admin/reviews',
          name: 'admin-reviews',
          builder: (context, state) => const AdminReviewsPage(),
        ),
        GoRoute(
          path: '/admin/users',
          name: 'admin-users',
          builder: (context, state) => const AdminUsersPage(),
        ),
        GoRoute(
          path: '/admin/home-sections',
          name: 'admin-home-sections',
          builder: (context, state) => const AdminHomeSectionsPage(),
        ),
        GoRoute(
          path: '/admin/news',
          name: 'admin-news',
          builder: (context, state) => const AdminNewsPage(),
        ),
        GoRoute(
          path: '/admin/news/new',
          name: 'admin-news-create',
          builder: (context, state) => const AdminNewsFormPage(),
        ),
        GoRoute(
          path: '/admin/news/:id/edit',
          name: 'admin-news-edit',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return AdminNewsFormPage(newsId: id);
          },
        ),
        GoRoute(
          path: '/admin/analytics',
          name: 'admin-analytics',
          builder: (context, state) => const AdminAnalyticsPage(),
        ),
        GoRoute(
          path: '/admin/settings',
          name: 'admin-settings',
          builder: (context, state) => const AdminSettingsPage(),
        ),
      ],
    ),
  ],
);

