import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:ct484project/core/constants/app_colors.dart';
import 'package:ct484project/core/constants/app_constants.dart';
import 'package:ct484project/core/utils/currency_formatter.dart';
import 'package:ct484project/features/orders/data/models/order_model.dart';
import 'package:ct484project/features/orders/presentation/bloc/order_bloc.dart';
import 'package:ct484project/features/orders/presentation/bloc/order_event.dart';
import 'package:ct484project/features/orders/presentation/bloc/order_state.dart';

/// Tab Quản lý Đơn hàng – TabBar 4 trạng thái + hành động nhanh
class AdminOrderManagementScreen extends StatefulWidget {
  const AdminOrderManagementScreen({super.key});

  @override
  State<AdminOrderManagementScreen> createState() =>
      _AdminOrderManagementScreenState();
}

class _AdminOrderManagementScreenState
    extends State<AdminOrderManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 4 trạng thái tab
  static const _tabs = [
    AppConstants.orderPending,
    AppConstants.orderShipping,
    AppConstants.orderDelivered,
    AppConstants.orderCancelled,
  ];

  static const _tabLabels = [
    'Chờ duyệt',
    'Đang giao',
    'Hoàn thành',
    'Đã hủy',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 Quản lý đơn hàng'),
        centerTitle: false,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: List.generate(
            _tabs.length,
            (i) => Tab(text: _tabLabels[i]),
          ),
        ),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: _tabs.map((status) {
              final filtered =
                  state.orders.where((o) => o.status == status).toList();
              if (filtered.isEmpty) {
                return _EmptyOrderTab(status: status);
              }
              return ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return _AdminOrderCard(
                    order: filtered[index],
                    currentStatus: status,
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

/// Card đơn hàng cho Admin – hiển thị chi tiết + nút hành động nhanh
class _AdminOrderCard extends StatelessWidget {
  final Order order;
  final String currentStatus;

  const _AdminOrderCard({
    required this.order,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy – HH:mm').format(order.orderDate);
    final bookSummary = order.items
        .map((e) => '${e.title} x${e.quantity}')
        .join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
        children: [
          // Dòng 1: Mã đơn + Tổng tiền
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_outlined,
                      size: 18, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Text(
                    'Đơn #${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
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
          const SizedBox(height: 10),

          // Dòng 2: Thông tin khách hàng
          _InfoRow(
            icon: Icons.person_outline,
            label: 'Khách hàng',
            value: _customerName(order),
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'SĐT',
            value: _customerPhone(order),
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Địa chỉ',
            value: order.shippingAddress.isNotEmpty
                ? order.shippingAddress
                : 'Chưa có',
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Ngày đặt',
            value: dateStr,
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.payment_outlined,
            label: 'Thanh toán',
            value: order.paymentMethod,
          ),

          const Divider(height: 20),

          // Danh sách sách tóm tắt
          Text(
            '📚 $bookSummary',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          ),

          const SizedBox(height: 14),

          // Nút hành động nhanh
          _ActionButtons(order: order, currentStatus: currentStatus),
        ],
      ),
    );
  }

  String _customerName(Order order) {
    // Lấy từ userId hoặc dùng mock
    if (order.userId == 'user_01') return 'Nguyễn Văn A';
    if (order.userId == 'usr_user') return 'Nguyễn Văn A';
    return 'Khách #${order.userId.substring(0, 6.clamp(0, order.userId.length))}';
  }

  String _customerPhone(Order order) {
    if (order.userId == 'user_01' || order.userId == 'usr_user') {
      return '0901234567';
    }
    return '0900000000';
  }
}

/// Dòng thông tin nhỏ: icon + label: value
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Nút hành động nhanh cho từng trạng thái
class _ActionButtons extends StatelessWidget {
  final Order order;
  final String currentStatus;

  const _ActionButtons({
    required this.order,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    switch (currentStatus) {
      case AppConstants.orderPending:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _updateStatus(
                  context,
                  order.id,
                  AppConstants.orderCancelled,
                  'Đã hủy đơn #${order.id}',
                ),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Hủy'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _updateStatus(
                  context,
                  order.id,
                  AppConstants.orderShipping,
                  'Đơn #${order.id} → Đang giao hàng',
                ),
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Xác nhận & Giao'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        );

      case AppConstants.orderShipping:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _updateStatus(
              context,
              order.id,
              AppConstants.orderDelivered,
              'Đơn #${order.id} → Đã giao thành công!',
            ),
            icon: const Icon(Icons.done_all, size: 16),
            label: const Text('Xác nhận đã giao'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        );

      case AppConstants.orderDelivered:
      case AppConstants.orderCancelled:
        return const SizedBox.shrink(); // Không có hành động

      default:
        return const SizedBox.shrink();
    }
  }

  void _updateStatus(
      BuildContext context, String orderId, String newStatus, String msg) {
    context.read<OrderBloc>().add(
          UpdateOrderStatusEvent(orderId: orderId, newStatus: newStatus),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            newStatus == AppConstants.orderCancelled
                ? AppColors.error
                : AppColors.success,
      ),
    );
  }
}

/// Widget hiển thị khi tab trống
class _EmptyOrderTab extends StatelessWidget {
  final String status;
  const _EmptyOrderTab({required this.status});

  String get _label {
    switch (status) {
      case AppConstants.orderPending:
        return 'Không có đơn chờ duyệt';
      case AppConstants.orderShipping:
        return 'Không có đơn đang giao';
      case AppConstants.orderDelivered:
        return 'Chưa có đơn hoàn thành';
      case AppConstants.orderCancelled:
        return 'Chưa có đơn bị hủy';
      default:
        return 'Trống';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            _label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
