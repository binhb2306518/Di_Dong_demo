import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/database_helper.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final DatabaseHelper _dbHelper;

  WishlistBloc({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        super(const WishlistState()) {
    on<LoadWishlist>(_onLoadWishlist);
    on<ToggleWishlistBook>(_onToggleWishlist);
    on<RemoveFromWishlistBook>(_onRemoveWishlist);
  }

  Future<void> _onLoadWishlist(
      LoadWishlist event, Emitter<WishlistState> emit) async {
    emit(state.copyWith(status: WishlistStatus.loading));
    try {
      final items = await _dbHelper.getWishlist();
      emit(state.copyWith(status: WishlistStatus.loaded, items: items));
    } catch (e) {
      emit(state.copyWith(
        status: WishlistStatus.error,
        errorMessage: 'Lỗi tải sách yêu thích: ${e.toString()}',
      ));
    }
  }

  Future<void> _onToggleWishlist(
      ToggleWishlistBook event, Emitter<WishlistState> emit) async {
    try {
      final isFav = await _dbHelper.isWishlisted(event.book.id);
      if (isFav) {
        await _dbHelper.removeFromWishlist(event.book.id);
        final items = await _dbHelper.getWishlist();
        emit(state.copyWith(
          status: WishlistStatus.loaded,
          items: items,
          message: 'Đã bỏ "${event.book.title}" khỏi danh sách yêu thích',
        ));
      } else {
        await _dbHelper.addToWishlist({
          'book_id': event.book.id,
          'title': event.book.title,
          'author': event.book.author,
          'price': event.book.price,
          'image_url': event.book.coverImage,
          'rating': event.book.rating,
        });
        final items = await _dbHelper.getWishlist();
        emit(state.copyWith(
          status: WishlistStatus.loaded,
          items: items,
          message: 'Đã thêm "${event.book.title}" vào danh sách yêu thích ❤️',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: WishlistStatus.error,
        errorMessage: 'Lỗi cập nhật yêu thích: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRemoveWishlist(
      RemoveFromWishlistBook event, Emitter<WishlistState> emit) async {
    try {
      await _dbHelper.removeFromWishlist(event.bookId);
      final items = await _dbHelper.getWishlist();
      emit(state.copyWith(
        status: WishlistStatus.loaded,
        items: items,
        message: 'Đã xóa khỏi yêu thích',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WishlistStatus.error,
        errorMessage: 'Lỗi xóa khỏi yêu thích: ${e.toString()}',
      ));
    }
  }
}
