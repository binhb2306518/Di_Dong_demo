import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/order_model.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';

/// Màn hình Lịch sử Đơn hàng – kết nối OrderBloc
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = [
    'Tất cả',
    'Chờ xử lý',
    'Đang giao',
    'Đã giao',
    'Đã hủy',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    context.read<OrderBloc>().add(const LoadOrders());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderModel> _filterOrders(List<OrderModel> allOrders, int tabIndex) {
    switch (tabIndex) {
      case 1:
        return allOrders
            .where((o) =>
                o.status == AppConstants.orderPending ||
                o.status == AppConstants.orderProcessing)
            .toList();
      case 2:
        return allOrders
            .where((o) => o.status == AppConstants.orderShipping)
            .toList();
      case 3:
        return allOrders
            .where((o) => o.status == AppConstants.orderDelivered)
            .toList();
      case 4:
        return allOrders
            .where((o) => o.status == AppConstants.orderCancelled)
            .toList();
      default:
        return allOrders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Đơn hàng của tôi'),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<OrderBloc>().add(const LoadOrders());
            },
            child: TabBarView(
              controller: _tabController,
              children: List.generate(_tabs.length, (tabIndex) {
                final orders = _filterOrders(state.orders, tabIndex);
                if (orders.isEmpty) {
                  return ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text('Chưa có đơn hàng nào',
                                  style: TextStyle(color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _OrderCard(order: orders[index]),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════
// Order Card
// ═══════════════════════════════════════════════════════

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  Color _statusColor() {
    switch (order.status) {
      case AppConstants.orderPending:
        return AppColors.warning;
      case AppConstants.orderProcessing:
      case AppConstants.orderShipping:
        return AppColors.info;
      case AppConstants.orderDelivered:
        return AppColors.success;
      case AppConstants.orderCancelled:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel() {
    switch (order.status) {
      case AppConstants.orderPending:
        return 'Chờ xử lý';
      case AppConstants.orderProcessing:
        return 'Đang đóng gói';
      case AppConstants.orderShipping:
        return 'Đang giao hàng';
      case AppConstants.orderDelivered:
        return 'Đã giao';
      case AppConstants.orderCancelled:
        return 'Đã hủy';
      default:
        return order.status;
    }
  }

  IconData _statusIcon() {
    switch (order.status) {
      case AppConstants.orderPending:
        return Icons.hourglass_top_rounded;
      case AppConstants.orderProcessing:
        return Icons.inventory_2_outlined;
      case AppConstants.orderShipping:
        return Icons.local_shipping_outlined;
      case AppConstants.orderDelivered:
        return Icons.check_circle_outline;
      case AppConstants.orderCancelled:
        return Icons.cancel_outlined;
      default:
        return Icons.receipt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt);

    return InkWell(
      onTap: () => context.push('/order-detail/${order.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
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
          children: [
            // Header: ID + Status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order.id}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(), size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel(),
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Date
            Text(
              'Ngày đặt: $dateStr',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 20),

            // Items count + Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.items.length} sản phẩm',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Row(
                  children: [
                    Text('Tổng tiền: ',
                        style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      CurrencyFormatter.format(order.totalAmount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
