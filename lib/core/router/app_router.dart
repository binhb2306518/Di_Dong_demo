import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/books/data/models/book_model.dart';
import '../../features/books/presentation/screens/home_screen.dart';
import '../../features/books/presentation/screens/book_detail_screen.dart';
import '../../features/books/presentation/screens/search_screen.dart';
import '../../features/books/presentation/widgets/wishlist_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/orders/presentation/screens/checkout_screen.dart';
import '../../features/orders/presentation/screens/order_history_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/address_management_screen.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/admin/presentation/screens/admin_book_list_screen.dart';
import '../../features/admin/presentation/screens/admin_add_edit_book_screen.dart';
import '../constants/app_colors.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Cấu hình GoRouter cho BookVerse kèm RBAC Guard cho Admin
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',

  // ── Phân quyền (Role-Based Access Control) ──
  redirect: (context, state) {
    final isAdminRoute = state.matchedLocation.startsWith('/admin');
    if (isAdminRoute) {
      // Nếu không phải quyền admin, chặn lại và chuyển hướng về Trang chủ
      if (!AuthCubit.instance.isAdmin) {
        return '/home';
      }
    }
    return null;
  },

  routes: [
    // ── Shell Route (Bottom Navigation) ──
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Trang chủ
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) => _buildFadePage(
                state,
                const HomeScreen(),
              ),
            ),
          ],
        ),
        // Tab 1: Tìm kiếm
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              pageBuilder: (context, state) => _buildFadePage(
                state,
                const SearchScreen(),
              ),
            ),
          ],
        ),
        // Tab 2: Yêu thích
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/wishlist',
              pageBuilder: (context, state) => _buildFadePage(
                state,
                const WishlistScreen(),
              ),
            ),
          ],
        ),
        // Tab 3: Đơn hàng
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/orders',
              pageBuilder: (context, state) => _buildFadePage(
                state,
                const OrderHistoryScreen(),
              ),
            ),
          ],
        ),
        // Tab 4: Cá nhân
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => _buildFadePage(
                state,
                const ProfileScreen(),
              ),
            ),
          ],
        ),
      ],
    ),

    // ── Routes bên ngoài shell ──
    GoRoute(
      path: '/book/:bookId',
      pageBuilder: (context, state) {
        final bookId = state.pathParameters['bookId']!;
        final book = state.extra as Book?;
        return _buildSlidePage(
          state,
          BookDetailScreen(bookId: bookId, book: book),
        );
      },
    ),
    GoRoute(
      path: '/cart',
      pageBuilder: (context, state) => _buildSlidePage(
        state,
        const CartScreen(),
      ),
    ),
    GoRoute(
      path: '/checkout',
      pageBuilder: (context, state) => _buildSlidePage(
        state,
        const CheckoutScreen(),
      ),
    ),
    GoRoute(
      path: '/order-detail/:orderId',
      pageBuilder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return _buildSlidePage(
          state,
          OrderDetailScreen(orderId: orderId),
        );
      },
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _buildFadePage(
        state,
        const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => _buildSlidePage(
        state,
        const RegisterScreen(),
      ),
    ),
    GoRoute(
      path: '/addresses',
      pageBuilder: (context, state) => _buildSlidePage(
        state,
        const AddressManagementScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/books',
      pageBuilder: (context, state) => _buildSlidePage(
        state,
        const AdminBookListScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/books/edit',
      pageBuilder: (context, state) {
        final book = state.extra as Book?;
        return _buildSlidePage(
          state,
          AdminAddEditBookScreen(book: book),
        );
      },
    ),
  ],
);

/// Custom Fade Transition Page
CustomTransitionPage<void> _buildFadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

/// Custom Slide Transition Page (từ phải sang)
CustomTransitionPage<void> _buildSlidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

/// Scaffold chứa BottomNavigationBar dùng chung cho các tab
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          animationDuration: const Duration(milliseconds: 400),
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Trang chủ',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search_rounded),
              label: 'Tìm kiếm',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline_rounded),
              selectedIcon: Icon(Icons.favorite_rounded),
              label: 'Yêu thích',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Đơn hàng',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }
}
