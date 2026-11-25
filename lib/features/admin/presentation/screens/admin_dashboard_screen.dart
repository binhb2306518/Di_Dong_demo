import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ct484project/core/constants/app_colors.dart';
import 'package:ct484project/core/constants/app_constants.dart';
import 'package:ct484project/core/utils/currency_formatter.dart';
import 'package:ct484project/features/books/presentation/bloc/book_cubit.dart';
import 'package:ct484project/features/orders/presentation/bloc/order_bloc.dart';
import 'package:ct484project/features/orders/presentation/bloc/order_state.dart';
import 'package:ct484project/features/orders/data/models/order_model.dart';

/// Tab Tổng quan (Dashboard) – 4 thẻ thống kê + Đơn hàng mới nhất
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Tổng quan'),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.storefront_outlined),
            tooltip: 'Về cửa hàng (Khách)',
          ),
          IconButton(
            onPressed: () {
              // Refresh dữ liệu
              context.read<BookCubit>().loadBooks();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã làm mới dữ liệu!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Lời chào ──
            Text(
              'Xin chào, Admin 👋',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Quản lý cửa hàng BookVerse của bạn',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),

            // ── 4 Thẻ thống kê dạng lưới 2x2 ──
            BlocBuilder<BookCubit, BookState>(
              builder: (context, bookState) {
                return BlocBuilder<OrderBloc, OrderState>(
                  builder: (context, orderState) {
                    final books = bookState.books;
                    final orders = orderState.orders;

                    // Tính toán số liệu
                    final totalRevenue = orders
                        .where((o) => o.status == AppConstants.orderDelivered)
                        .fold<double>(0, (sum, o) => sum + o.totalAmount);
                    final pendingOrders = orders
                        .where((o) => o.status == AppConstants.orderPending)
                        .length;
                    final totalBooks = books.length;
                    final lowStockBooks =
                        books.where((b) => b.stockQuantity <= 5).length;

                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _StatCard(
                          title: 'Doanh thu',
                          value: CurrencyFormatter.format(totalRevenue),
                          icon: Icons.monetization_on_rounded,
                          color: AppColors.success,
                          bgColor: AppColors.success.withValues(alpha: 0.1),
                        ),
                        _StatCard(
                          title: 'Đơn chờ duyệt',
                          value: '$pendingOrders',
                          icon: Icons.pending_actions_rounded,
                          color: AppColors.warning,
                          bgColor: AppColors.warning.withValues(alpha: 0.1),
                        ),
                        _StatCard(
                          title: 'Tổng số sách',
                          value: '$totalBooks',
                          icon: Icons.menu_book_rounded,
                          color: AppColors.info,
                          bgColor: AppColors.info.withValues(alpha: 0.1),
                        ),
                        _StatCard(
                          title: 'Sắp hết hàng',
                          value: '$lowStockBooks',
                          icon: Icons.warning_amber_rounded,
                          color: AppColors.error,
                          bgColor: AppColors.error.withValues(alpha: 0.1),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // ── Đơn hàng mới nhất cần xử lý ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đơn hàng mới nhất',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    // Chuyển sang tab Đơn hàng (index = 2)
                    // Sử dụng callback từ AdminShellScreen
                  },
                  child: const Text('Xem tất cả →'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) {
                // Lấy tối đa 5 đơn gần nhất
                final recentOrders = List<Order>.from(state.orders)
                  ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
                final displayOrders = recentOrders.take(5).toList();

                if (displayOrders.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(Icons.inbox_rounded,
                              size: 48, color: AppColors.textSecondary),
                          SizedBox(height: 8),
                          Text('Chưa có đơn hàng nào',
                              style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: displayOrders
                      .map((order) => _RecentOrderCard(order: order))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Thẻ thống kê dạng Card
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Card đơn hàng gần đây
class _RecentOrderCard extends StatelessWidget {
  final Order order;
  const _RecentOrderCard({required this.order});

  Color _statusColor(String status) {
    switch (status) {
      case AppConstants.orderPending:
        return AppColors.warning;
      case AppConstants.orderProcessing:
        return AppColors.info;
      case AppConstants.orderShipping:
        return Colors.orange;
      case AppConstants.orderDelivered:
        return AppColors.success;
      case AppConstants.orderCancelled:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case AppConstants.orderPending:
        return 'Chờ duyệt';
      case AppConstants.orderProcessing:
        return 'Đang xử lý';
      case AppConstants.orderShipping:
        return 'Đang giao';
      case AppConstants.orderDelivered:
        return 'Hoàn thành';
      case AppConstants.orderCancelled:
        return 'Đã hủy';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(order.orderDate);
    final bookNames = order.items.map((e) => e.title).join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon đơn hàng
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _statusColor(order.status).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: _statusColor(order.status),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${order.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            _statusColor(order.status).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusLabel(order.status),
                        style: TextStyle(
                          color: _statusColor(order.status),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  bookNames,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(order.totalAmount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
