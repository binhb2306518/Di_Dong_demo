import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/models/order_model.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final NotificationService _notificationService;

  // Mock initial orders list
  static final List<OrderModel> _initialOrders = [
    OrderModel(
      id: 'BK98421',
      userId: 'user_01',
      items: const [
        OrderItem(
          bookId: 'book_001',
          title: 'Đắc Nhân Tâm',
          price: 86000,
          quantity: 1,
          imageUrl: 'https://picsum.photos/seed/book1/300/450',
        ),
        OrderItem(
          bookId: 'book_002',
          title: 'Nhà Giả Kim',
          price: 63200,
          quantity: 2,
          imageUrl: 'https://picsum.photos/seed/book2/300/450',
        ),
      ],
      totalAmount: 212400,
      status: AppConstants.orderPending,
      paymentMethod: AppConstants.paymentCOD,
      shippingAddress: 'Khu II, Đ. 3/2, P. Xuân Khánh, Q. Ninh Kiều, Cần Thơ',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    OrderModel(
      id: 'BK97302',
      userId: 'user_01',
      items: const [
        OrderItem(
          bookId: 'book_004',
          title: 'Clean Code: A Handbook of Agile Software Craftsmanship',
          price: 340000,
          quantity: 1,
          imageUrl: 'https://picsum.photos/seed/book4/300/450',
        ),
      ],
      totalAmount: 340000,
      status: AppConstants.orderDelivered,
      paymentMethod: AppConstants.paymentVietQR,
      shippingAddress: 'Khu II, Đ. 3/2, P. Xuân Khánh, Q. Ninh Kiều, Cần Thơ',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  OrderBloc({NotificationService? notificationService})
      : _notificationService = notificationService ?? NotificationService.instance,
        super(OrderState(orders: _initialOrders, status: OrderStatusState.loaded)) {
    on<LoadOrders>(_onLoadOrders);
    on<CreateOrderEvent>(_onCreateOrder);
    on<CancelOrderEvent>(_onCancelOrder);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
  }

  void _onLoadOrders(LoadOrders event, Emitter<OrderState> emit) {
    emit(state.copyWith(status: OrderStatusState.loaded));
  }

  Future<void> _onCreateOrder(
      CreateOrderEvent event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatusState.loading));
    try {
      final updatedOrders = [event.order, ...state.orders];
      emit(state.copyWith(
        status: OrderStatusState.success,
        orders: updatedOrders,
        lastCreatedOrder: event.order,
        message: 'Đặt hàng thành công! Mã đơn: #${event.order.id}',
      ));

      // Bắn Local Notification thông báo tức thì lên thanh trạng thái Android
      await _notificationService.showOrderSuccessNotification(
        orderId: event.order.id,
        totalAmount: event.order.totalAmount,
      );
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatusState.error,
        errorMessage: 'Lỗi tạo đơn hàng: ${e.toString()}',
      ));
    }
  }

  void _onCancelOrder(CancelOrderEvent event, Emitter<OrderState> emit) {
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
