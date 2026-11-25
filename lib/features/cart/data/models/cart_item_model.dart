import 'package:equatable/equatable.dart';

/// Model mục trong giỏ hàng – hỗ trợ SQLite toMap/fromMap
class CartItem extends Equatable {
  final String id;
  final String bookId;
  final String title;
  final double price;
  final String imageUrl;
  final int quantity;
  final int stockQuantity;

  const CartItem({
    required this.id,
    required this.bookId,
    required this.title,
    required this.price,
    this.imageUrl = '',
    this.quantity = 1,
    this.stockQuantity = 0,
  });

  double get subtotal => price * quantity;

  /// Từ SQLite row
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as String,
      bookId: map['book_id'] as String,
      title: map['title'] as String,
      price: (map['price'] as num).toDouble(),
      imageUrl: map['image_url'] as String? ?? '',
      quantity: map['quantity'] as int,
      stockQuantity: map['stock_quantity'] as int? ?? 0,
    );
  }

  /// Sang SQLite row
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'title': title,
      'price': price,
      'image_url': imageUrl,
      'quantity': quantity,
      'stock_quantity': stockQuantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      bookId: bookId,
      title: title,
      price: price,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
      stockQuantity: stockQuantity,
    );
  }

  @override
  List<Object?> get props => [id, bookId, quantity];
}
