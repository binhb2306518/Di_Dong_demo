import 'package:equatable/equatable.dart';
import '../../data/models/order_model.dart';

enum OrderStatusState { initial, loading, loaded, success, error }

class OrderState extends Equatable {
  final OrderStatusState status;
  final List<OrderModel> orders;
  final OrderModel? lastCreatedOrder;
  final String? message;
  final String? errorMessage;

  const OrderState({
    this.status = OrderStatusState.initial,
    this.orders = const [],
    this.lastCreatedOrder,
    this.message,
    this.errorMessage,
  });

  OrderState copyWith({
    OrderStatusState? status,
    List<OrderModel>? orders,
    OrderModel? lastCreatedOrder,
    String? message,
    String? errorMessage,
  }) {
    return OrderState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      lastCreatedOrder: lastCreatedOrder ?? this.lastCreatedOrder,
      message: message,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, orders, lastCreatedOrder, message, errorMessage];
}
