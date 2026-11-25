import 'package:equatable/equatable.dart';

/// Model Đơn hàng
class Order extends Equatable {
  final String id;
  final String userId;
  final DateTime orderDate;
  final List<OrderItem> items;
  final double shippingFee;
  final double discountAmount;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final String shippingAddress;

  const Order({
    required this.id,
    required this.userId,
    DateTime? orderDate,
    DateTime? createdAt,
    required this.items,
    this.shippingFee = 0,
    this.discountAmount = 0,
    required this.totalAmount,
    this.paymentMethod = 'COD',
    this.status = 'Pending',
    this.shippingAddress = '',
  }) : orderDate = orderDate ?? createdAt ?? const _DefaultDateTime();

  DateTime get createdAt => orderDate;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      orderDate: DateTime.tryParse(json['order_date'] as String? ?? '') ??
          DateTime.now(),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      shippingFee: (json['shipping_fee'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['payment_method'] as String? ?? 'COD',
      status: json['status'] as String? ?? 'Pending',
      shippingAddress: json['shipping_address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'order_date': orderDate.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
      'shipping_fee': shippingFee,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'status': status,
      'shipping_address': shippingAddress,
    };
  }

  Order copyWith({String? status}) {
    return Order(
      id: id,
      userId: userId,
      orderDate: orderDate,
      items: items,
      shippingFee: shippingFee,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      status: status ?? this.status,
      shippingAddress: shippingAddress,
    );
  }

  @override
  List<Object?> get props => [id];
}

class _DefaultDateTime implements DateTime {
  const _DefaultDateTime();
  @override
  dynamic noSuchMethod(Invocation invocation) => DateTime.now();
}

/// Alias cho Order để tương thích với OrderModel
typedef OrderModel = Order;

/// Một dòng sản phẩm trong đơn hàng
class OrderItem extends Equatable {
  final String bookId;
  final String title;
  final int quantity;
  final double price;
  final String imageUrl;

  const OrderItem({
    required this.bookId,
    required this.title,
    required this.quantity,
    required this.price,
    this.imageUrl = '',
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      bookId: json['book_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: json['image_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'book_id': bookId,
        'title': title,
        'quantity': quantity,
        'price': price,
        'image_url': imageUrl,
      };

  @override
  List<Object?> get props => [bookId, quantity];
}
