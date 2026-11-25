import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../data/models/order_model.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';

/// Màn hình Thanh toán & Đặt hàng – kết nối CartBloc, OrderBloc và NotificationService
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = AppConstants.paymentCOD;
  int _selectedAddressIndex = 0;

  final _addresses = [
    {
      'name': 'Nguyễn Văn A',
      'phone': '0901234567',
      'address': 'Khu II, ĐH Cần Thơ, Đường 3/2, Q. Ninh Kiều, Cần Thơ',
    },
    {
      'name': 'Nguyễn Văn A',
      'phone': '0901234567',
      'address': '123 Trần Hưng Đạo, P. Bến Thành, Q. 1, TP. Hồ Chí Minh',
    },
  ];

  void _confirmOrder(BuildContext context, CartState cartState) {
    if (cartState.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giỏ hàng trống!')),
      );
      return;
    }

    final orderId = 'BK${DateTime.now().millisecondsSinceEpoch % 1000000}';
    final selectedAddr = _addresses[_selectedAddressIndex]['address']!;

    final orderItems = cartState.items
        .map((ci) => OrderItem(
              bookId: ci.bookId,
              title: ci.title,
              price: ci.price,
              quantity: ci.quantity,
              imageUrl: ci.imageUrl,
            ))
        .toList();

    final newOrder = OrderModel(
      id: orderId,
      userId: 'user_01',
      items: orderItems,
      totalAmount: cartState.total,
      status: AppConstants.orderPending,
      paymentMethod: _paymentMethod,
      shippingAddress: selectedAddr,
      createdAt: DateTime.now(),
    );

    // 1. Tạo đơn hàng và kích hoạt Local Notification
    context.read<OrderBloc>().add(CreateOrderEvent(newOrder));

    // 2. Làm trống giỏ hàng trong SQLite
    context.read<CartBloc>().add(const ClearCart());

    // 3. Hiển thị dialog đặt hàng thành công
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            Text('Đặt hàng thành công! 🎉',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Đơn hàng #$orderId (${CurrencyFormatter.format(cartState.total)}) đang được xử lý và sẽ sớm giao đến bạn.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/orders');
              },
              child: const Text('Xem danh sách đơn hàng'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Xác nhận đơn hàng'),
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
                // 1. Địa chỉ giao hàng
                _buildSectionHeader(
                  context,
                  title: 'Địa chỉ nhận hàng',
                  actionLabel: 'Sổ địa chỉ',
                  onAction: () => context.push('/addresses'),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  _addresses.length,
                  (i) => _AddressTile(
                    name: _addresses[i]['name']!,
                    phone: _addresses[i]['phone']!,
                    address: _addresses[i]['address']!,
                    isSelected: _selectedAddressIndex == i,
                    onTap: () => setState(() => _selectedAddressIndex = i),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Phương thức thanh toán
                _buildSectionHeader(context, title: 'Phương thức thanh toán'),
                const SizedBox(height: 8),
                _PaymentOption(
                  label: 'Thanh toán khi nhận hàng (COD)',
                  icon: Icons.local_shipping_outlined,
                  value: AppConstants.paymentCOD,
                  groupValue: _paymentMethod,
                  onChanged: (v) => setState(() => _paymentMethod = v!),
                ),
                _PaymentOption(
                  label: 'Chuyển khoản VietQR / MoMo',
                  icon: Icons.qr_code_2_outlined,
                  value: AppConstants.paymentVietQR,
                  groupValue: _paymentMethod,
                  onChanged: (v) => setState(() => _paymentMethod = v!),
                ),
                const SizedBox(height: 16),

                // 3. Tóm tắt đơn hàng
                _buildSectionHeader(context, title: 'Tóm tắt thanh toán'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _SummaryLine(
                        label: 'Số lượng sản phẩm',
                        value: '${cartState.totalItemCount} quyển',
                      ),
                      const SizedBox(height: 8),
                      _SummaryLine(
                        label: 'Tạm tính',
                        value: CurrencyFormatter.format(cartState.subtotal),
                      ),
                      const SizedBox(height: 8),
                      _SummaryLine(
                        label: 'Phí vận chuyển',
                        value: cartState.shippingFee == 0
                            ? 'Miễn phí'
                            : CurrencyFormatter.format(cartState.shippingFee),
                      ),
                      if (cartState.discountAmount > 0) ...[
                        const SizedBox(height: 8),
                        _SummaryLine(
                          label: 'Giảm giá voucher',
                          value:
                              '- ${CurrencyFormatter.format(cartState.discountAmount)}',
                          valueColor: AppColors.success,
                        ),
                      ],
                      const Divider(height: 20),
                      _SummaryLine(
                        label: 'Tổng thanh toán',
                        value: CurrencyFormatter.format(cartState.total),
                        isBold: true,
                        valueColor: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tổng thanh toán',
                          style: Theme.of(context).textTheme.bodySmall),
                      Text(
                        CurrencyFormatter.format(cartState.total),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _confirmOrder(context, cartState),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.secondary,
                      ),
                      child: const Text('Xác nhận đặt hàng'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// Widget phụ trợ
// ═══════════════════════════════════════════════════════

class _AddressTile extends StatelessWidget {
  final String name;
  final String phone;
  final String address;
  final bool isSelected;
  final VoidCallback onTap;

  const _AddressTile({
    required this.name,
    required this.phone,
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text('($phone)',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(address, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _PaymentOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  )),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.primary : Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryLine({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 15 : 13,
            )),
        Text(value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 13,
              color: valueColor,
            )),
      ],
    );
  }
}
