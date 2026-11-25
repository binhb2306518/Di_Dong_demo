import 'package:equatable/equatable.dart';
import '../../data/models/book_model.dart';

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();

  @override
  List<Object?> get props => [];
}

class LoadWishlist extends WishlistEvent {
  const LoadWishlist();
}

class ToggleWishlistBook extends WishlistEvent {
  final Book book;

  const ToggleWishlistBook(this.book);

  @override
  List<Object?> get props => [book];
}

class RemoveFromWishlistBook extends WishlistEvent {
  final String bookId;

  const RemoveFromWishlistBook(this.bookId);

  @override
  List<Object?> get props => [bookId];
}
