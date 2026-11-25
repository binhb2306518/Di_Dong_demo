import 'package:equatable/equatable.dart';
import '../../data/models/order_model.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrderEvent {
  const LoadOrders();
}

class CreateOrderEvent extends OrderEvent {
  final OrderModel order;

  const CreateOrderEvent(this.order);

  @override
  List<Object?> get props => [order];
}

class CancelOrderEvent extends OrderEvent {
  final String orderId;

  const CancelOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class UpdateOrderStatusEvent extends OrderEvent {
  final String orderId;
  final String newStatus;

  const UpdateOrderStatusEvent({required this.orderId, required this.newStatus});

  @override
  List<Object?> get props => [orderId, newStatus];
}
