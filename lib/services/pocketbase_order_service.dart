import 'dart:convert';
import 'package:pocketbase/pocketbase.dart';
import '../../features/orders/data/models/order_model.dart';
import 'pocketbase_client.dart';

class PocketBaseOrderService {
  PocketBaseOrderService._();
  static final PocketBaseOrderService instance = PocketBaseOrderService._();

  /// Lấy toàn bộ danh sách đơn hàng từ PocketBase
  Future<List<Order>> getAllOrders() async {
    final pb = await getPocketbaseInstance();
    final records = await pb.collection('orders').getFullList(sort: '-created');
    return records.map((r) => _recordToOrder(r)).toList();
  }

  /// Tạo đơn hàng mới trên PocketBase
  Future<Order> insertOrder(Order order) async {
    final pb = await getPocketbaseInstance();

    // Lấy user_id hợp lệ từ authStore nếu đang đăng nhập
    String? validUserId;
    if (pb.authStore.isValid && pb.authStore.model is RecordModel) {
      validUserId = (pb.authStore.model as RecordModel).id;
    }

    final body = <String, dynamic>{
      'order_code': order.id.isNotEmpty ? order.id : 'BK${DateTime.now().millisecondsSinceEpoch % 1000000}',
      'customer_name': 'Khách hàng',
      'customer_phone': '0901234567', // Giá trị mặc định tránh lỗi Required của PocketBase
      'shipping_address': order.shippingAddress.isNotEmpty ? order.shippingAddress : 'Địa chỉ mặc định',
      'payment_method': order.paymentMethod.isNotEmpty ? order.paymentMethod : 'COD',
      'payment_status': 'unpaid',
      'status': order.status.isNotEmpty ? order.status : 'Pending',
      'total_amount': order.totalAmount,
      'shipping_fee': order.shippingFee,
      'discount_amount': order.discountAmount.toString(),
    };

    if (validUserId != null && validUserId.isNotEmpty) {
      body['user_id'] = validUserId;
    }

    // Hỗ trợ cả 2 tên trường items_jso (theo ảnh PB) hoặc items_json
    final itemsData = order.items.map((e) => e.toJson()).toList();
    body['items_jso'] = itemsData;
    body['items_json'] = itemsData;

    RecordModel record;
    try {
      record = await pb.collection('orders').create(body: body);
    } catch (_) {
      // Thử lại nếu thừa trường
      body.remove('items_json');
      try {
        record = await pb.collection('orders').create(body: body);
      } catch (_) {
        body.remove('items_jso');
        body.remove('user_id');
        record = await pb.collection('orders').create(body: body);
      }
    }
    return _recordToOrder(record);
  }

  /// Cập nhật trạng thái đơn hàng trên PocketBase
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final pb = await getPocketbaseInstance();
    try {
      await pb.collection('orders').update(orderId, body: {'status': newStatus});
    } catch (_) {
      final list = await pb.collection('orders').getList(
        filter: 'order_code = "$orderId"',
        page: 1,
        perPage: 1,
      );
      if (list.items.isNotEmpty) {
        await pb.collection('orders').update(list.items.first.id, body: {'status': newStatus});
      }
    }
  }

  Order _recordToOrder(RecordModel record) {
    final data = record.data;
    List<OrderItem> items = [];
    final rawItems = data['items_jso'] ?? data['items_json'];
    if (rawItems is List) {
      items = rawItems.map((e) {
        if (e is Map<String, dynamic>) {
          return OrderItem.fromJson(e);
        } else if (e is Map) {
          return OrderItem.fromJson(Map<String, dynamic>.from(e));
        }
        return const OrderItem(bookId: '', title: '', quantity: 1, price: 0);
      }).toList();
    } else if (rawItems is String && rawItems.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawItems);
        if (decoded is List) {
          items = decoded.map((e) => OrderItem.fromJson(e as Map<String, dynamic>)).toList();
        }
      } catch (_) {}
    }

    final createdDate = DateTime.tryParse(record.created) ?? DateTime.now();

    return Order(
      id: record.getStringValue('order_code').isNotEmpty ? record.getStringValue('order_code') : record.id,
      userId: record.getStringValue('user_id'),
      orderDate: createdDate,
      items: items,
      shippingFee: (data['shipping_fee'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (data['discount_amount'] is num)
          ? (data['discount_amount'] as num).toDouble()
          : (double.tryParse(data['discount_amount']?.toString() ?? '') ?? 0.0),
      totalAmount: (data['total_amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: record.getStringValue('payment_method').isNotEmpty ? record.getStringValue('payment_method') : 'COD',
      status: record.getStringValue('status').isNotEmpty ? record.getStringValue('status') : 'Pending',
      shippingAddress: record.getStringValue('shipping_address'),
    );
  }
}
