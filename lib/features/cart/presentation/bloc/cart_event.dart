import 'package:equatable/equatable.dart';
import '../../data/models/cart_item_model.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {
  const LoadCart();
}

class AddToCart extends CartEvent {
  final CartItem item;

  const AddToCart(this.item);

  @override
  List<Object?> get props => [item];
}

class UpdateCartQuantity extends CartEvent {
  final String id;
  final int quantity;

  const UpdateCartQuantity({required this.id, required this.quantity});

  @override
  List<Object?> get props => [id, quantity];
}

class RemoveFromCart extends CartEvent {
  final String id;

  const RemoveFromCart(this.id);

  @override
  List<Object?> get props => [id];
}

class ApplyVoucher extends CartEvent {
  final String voucherCode;

  const ApplyVoucher(this.voucherCode);

  @override
  List<Object?> get props => [voucherCode];
}

class RemoveVoucher extends CartEvent {
  const RemoveVoucher();
}

class ClearCart extends CartEvent {
  const ClearCart();
}
