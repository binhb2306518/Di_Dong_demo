import 'package:equatable/equatable.dart';
import '../../data/models/cart_item_model.dart';

enum CartStatus { initial, loading, loaded, error }

class CartState extends Equatable {
  final CartStatus status;
  final List<CartItem> items;
  final String? voucherCode;
  final double discountAmount;
  final String? errorMessage;
  final String? message;

  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.voucherCode,
    this.discountAmount = 0.0,
    this.errorMessage,
    this.message,
  });

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  double get shippingFee => (subtotal > 200000 || subtotal == 0) ? 0.0 : 30000.0;

  double get total => (subtotal + shippingFee - discountAmount).clamp(0.0, double.infinity);

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({
    CartStatus? status,
    List<CartItem>? items,
    String? voucherCode,
    double? discountAmount,
    String? errorMessage,
    String? message,
    bool clearVoucher = false,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      voucherCode: clearVoucher ? null : (voucherCode ?? this.voucherCode),
      discountAmount: clearVoucher ? 0.0 : (discountAmount ?? this.discountAmount),
      errorMessage: errorMessage,
      message: message,
    );
  }

  @override
  List<Object?> get props =>
      [status, items, voucherCode, discountAmount, errorMessage, message];
}
