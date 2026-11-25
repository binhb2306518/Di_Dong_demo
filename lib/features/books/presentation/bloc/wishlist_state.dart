import 'package:equatable/equatable.dart';

enum WishlistStatus { initial, loading, loaded, error }

class WishlistState extends Equatable {
  final WishlistStatus status;
  final List<Map<String, dynamic>> items;
  final String? message;
  final String? errorMessage;

  const WishlistState({
    this.status = WishlistStatus.initial,
    this.items = const [],
    this.message,
    this.errorMessage,
  });

  bool isFavorite(String bookId) {
    return items.any((e) => (e['book_id'] ?? e['id']) == bookId);
  }

  WishlistState copyWith({
    WishlistStatus? status,
    List<Map<String, dynamic>>? items,
    String? message,
    String? errorMessage,
  }) {
    return WishlistState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, message, errorMessage];
}
