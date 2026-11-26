import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/order_model.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';

/// Màn hình Chi tiết Đơn hàng – kết nối OrderBloc & Timeline
class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  void _showReviewDialog(BuildContext context) {
    double selectedRating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Đánh giá sản phẩm ⭐'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Bạn cảm thấy sản phẩm và dịch vụ thế nào?'),
              const SizedBox(height: 16),
              RatingBar.builder(
                initialRating: 5,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star_rounded,
                  color: AppColors.starFilled,
                ),
                onRatingUpdate: (rating) {
                  setState(() => selectedRating = rating);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Nhập cảm nhận của bạn về cuốn sách...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Bỏ qua'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Cảm ơn bạn đã gửi đánh giá $selectedRating sao! ❤️'),
                  ),
                );
              },
              child: const Text('Gửi đánh giá'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        OrderModel? order;
        try {
          order = state.orders.firstWhere((o) => o.id == orderId);
        } catch (_) {
          order = null;
        }

        final displayOrder = order ??
            OrderModel(
              id: orderId,
              userId: '',
              items: const [],
              totalAmount: 0,
              status: AppConstants.orderPending,
              paymentMethod: AppConstants.paymentCOD,
              shippingAddress: '',
              createdAt: DateTime.now(),
            );

        return Scaffold(
          appBar: AppBar(
            title: Text('Đơn hàng #${displayOrder.id}'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Timeline trạng thái ──
                _buildStatusTimeline(context, displayOrder.status),
                const SizedBox(height: 20),

                // ── Thông tin giao hàng ──
                _buildSection(
                  context,
                  icon: Icons.local_shipping_outlined,
                  title: 'Thông tin giao hàng',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _InfoRow(
                          label: 'Người nhận', value: 'Nguyễn Văn A'),
                      const _InfoRow(
                          label: 'Số điện thoại', value: '0901234567'),
                      _InfoRow(
                        label: 'Địa chỉ',
                        value: displayOrder.shippingAddress,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Danh sách sản phẩm ──
                _buildSection(
                  context,
                  icon: Icons.menu_book_outlined,
                  title: 'Sản phẩm đã đặt (${displayOrder.items.length})',
                  child: Column(
                    children: displayOrder.items
                        .map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _OrderItemRow(
                                title: item.title,
                                qty: item.quantity,
                                price: item.price,
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Chi tiết thanh toán ──
                _buildSection(
                  context,
                  icon: Icons.payment_outlined,
                  title: 'Chi tiết thanh toán',
                  child: Column(
                    children: [
                      _PaymentRow(
                        label: 'Phương thức',
                        value: displayOrder.paymentMethod,
                      ),
                      _PaymentRow(
                        label: 'Thời gian đặt',
                        value: DateFormat('dd/MM/yyyy HH:mm')
                            .format(displayOrder.createdAt),
                      ),
                      const Divider(height: 16),
                      _PaymentRow(
                        label: 'Tổng tiền',
                        value:
                            CurrencyFormatter.format(displayOrder.totalAmount),
                        isBold: true,
                        valueColor: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Nút hành động ──
                Row(
                  children: [
                    if (displayOrder.status == AppConstants.orderPending)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                title: const Text('Hủy đơn hàng?'),
                                content: const Text(
                                    'Bạn có chắc muốn hủy đơn hàng này không?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Không'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      context.read<OrderBloc>().add(
                                          CancelOrderEvent(displayOrder.id));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Đã hủy đơn hàng #${displayOrder.id}')),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.error),
                                    child: const Text('Hủy đơn'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('Hủy đơn'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    if (displayOrder.status == AppConstants.orderPending)
                      const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showReviewDialog(context),
                        icon: const Icon(Icons.rate_review_outlined),
                        label: const Text('Đánh giá'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(BuildContext context,
      {required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(BuildContext context, String currentStatus) {
    int currentStep = 0;
    if (currentStatus == AppConstants.orderProcessing) currentStep = 1;
    if (currentStatus == AppConstants.orderShipping) currentStep = 2;
    if (currentStatus == AppConstants.orderDelivered) currentStep = 3;
    if (currentStatus == AppConstants.orderCancelled) currentStep = -1;

    final steps = [
      _TimelineStep('Đặt hàng', Icons.receipt_long_rounded),
      _TimelineStep('Đóng gói', Icons.inventory_2_outlined),
      _TimelineStep('Đang giao', Icons.local_shipping_outlined),
      _TimelineStep('Giao thành công', Icons.check_circle_outline),
    ];

    if (currentStatus == AppConstants.orderCancelled) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppColors.error, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đơn hàng đã bị hủy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('Đơn hàng này không còn hiệu lực giao dịch.'),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Trạng thái đơn hàng',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(steps.length, (index) {
            final isActive = index <= currentStep;
            final isCurrent = index == currentStep;
            final isLast = index == steps.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isActive
                              ? (isCurrent
                                  ? AppColors.primary
                                  : AppColors.success)
                              : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          steps[index].icon,
                          size: 16,
                          color: isActive ? Colors.white : Colors.grey.shade500,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 30,
                          color: isActive
                              ? AppColors.success
                              : Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            steps[index].title,
                            style: TextStyle(
                              fontWeight:
                                  isCurrent ? FontWeight.bold : FontWeight.w500,
                              color: isActive ? null : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineStep {
  final String title;
  final IconData icon;
  _TimelineStep(this.title, this.icon);
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final String title;
  final int qty;
  final double price;
  const _OrderItemRow(
      {required this.title, required this.qty, required this.price});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('x$qty', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        Text(CurrencyFormatter.format(price * qty),
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  const _PaymentRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: isBold ? 14 : 12,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isBold ? null : AppColors.textSecondary,
              )),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: isBold ? 16 : 12,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: valueColor,
                )),
          ),
        ],
      ),
    );
  }
}
