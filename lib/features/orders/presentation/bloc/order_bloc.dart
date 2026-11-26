import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../services/pocketbase_order_service.dart';
import '../../data/models/order_model.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final NotificationService _notificationService;

  OrderBloc({NotificationService? notificationService})
      : _notificationService =
            notificationService ?? NotificationService.instance,
        super(const OrderState(orders: [], status: OrderStatusState.initial)) {
    on<LoadOrders>(_onLoadOrders);
    on<CreateOrderEvent>(_onCreateOrder);
    on<CancelOrderEvent>(_onCancelOrder);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
  }

  Future<void> _onLoadOrders(
      LoadOrders event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatusState.loading));
    try {
      final orders = await PocketBaseOrderService.instance.getAllOrders();
      emit(state.copyWith(status: OrderStatusState.loaded, orders: orders));
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatusState.error,
        errorMessage: 'Lỗi tải đơn hàng từ PocketBase: ${e.toString()}',
      ));
    }
  }

  Future<void> _onCreateOrder(
      CreateOrderEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatusState.loading));
    try {
      final createdOrder = await PocketBaseOrderService.instance.insertOrder(event.order);
      final updatedOrders = [createdOrder, ...state.orders];
      emit(state.copyWith(
        status: OrderStatusState.success,
        orders: updatedOrders,
        lastCreatedOrder: createdOrder,
        message: 'Đặt hàng thành công! Mã đơn: #${createdOrder.id}',
      ));

      // Bắn Local Notification thông báo tức thì lên thanh trạng thái Android
      await _notificationService.showOrderSuccessNotification(
        orderId: createdOrder.id,
        totalAmount: createdOrder.totalAmount,
      );
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatusState.error,
        errorMessage: 'Lỗi tạo đơn hàng: ${e.toString()}',
      ));
    }
  }

  Future<void> _onCancelOrder(
      CancelOrderEvent event, Emitter<OrderState> emit) async {
    await PocketBaseOrderService.instance.updateOrderStatus(
      event.orderId,
      AppConstants.orderCancelled,
    );
    final updatedOrders = state.orders.map((o) {
      if (o.id == event.orderId) {
        return o.copyWith(status: AppConstants.orderCancelled);
      }
      return o;
    }).toList();

    emit(state.copyWith(
      orders: updatedOrders,
      message: 'Đã hủy đơn hàng #${event.orderId}',
    ));
  }

  Future<void> _onUpdateOrderStatus(
      UpdateOrderStatusEvent event, Emitter<OrderState> emit) async {
    await PocketBaseOrderService.instance.updateOrderStatus(
      event.orderId,
      event.newStatus,
    );
    final updatedOrders = state.orders.map((o) {
      if (o.id == event.orderId) {
        return o.copyWith(status: event.newStatus);
      }
      return o;
    }).toList();

    emit(state.copyWith(
      orders: updatedOrders,
      message: 'Đơn hàng #${event.orderId} chuyển sang: ${event.newStatus}',
    ));

    await _notificationService.showOrderStatusUpdateNotification(
      orderId: event.orderId,
      status: event.newStatus,
    );
  }
}
