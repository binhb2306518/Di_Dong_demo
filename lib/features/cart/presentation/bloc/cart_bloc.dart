import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/database_helper.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final DatabaseHelper _dbHelper;

  CartBloc({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        super(const CartState()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<UpdateCartQuantity>(_onUpdateQuantity);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ApplyVoucher>(_onApplyVoucher);
    on<RemoveVoucher>(_onRemoveVoucher);
    on<ClearCart>(_onClearCart);
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      final items = await _dbHelper.getCartItems();
      emit(state.copyWith(status: CartStatus.loaded, items: items));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: 'Lỗi tải giỏ hàng: ${e.toString()}',
      ));
    }
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    try {
      await _dbHelper.insertOrUpdateCart(event.item);
      final items = await _dbHelper.getCartItems();
      emit(state.copyWith(
        status: CartStatus.loaded,
        items: items,
        message: 'Đã thêm "${event.item.title}" vào giỏ hàng!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: 'Không thể thêm vào giỏ hàng: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateQuantity(
      UpdateCartQuantity event, Emitter<CartState> emit) async {
    try {
      await _dbHelper.updateCartQuantity(event.id, event.quantity);
      final items = await _dbHelper.getCartItems();
      emit(state.copyWith(status: CartStatus.loaded, items: items));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: 'Lỗi cập nhật số lượng: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRemoveFromCart(
      RemoveFromCart event, Emitter<CartState> emit) async {
    try {
      await _dbHelper.deleteCartItem(event.id);
      final items = await _dbHelper.getCartItems();
      emit(state.copyWith(
        status: CartStatus.loaded,
        items: items,
        message: 'Đã xóa sản phẩm khỏi giỏ hàng',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: 'Lỗi xóa sản phẩm: ${e.toString()}',
      ));
    }
  }

  void _onApplyVoucher(ApplyVoucher event, Emitter<CartState> emit) {
    final code = event.voucherCode.trim().toUpperCase();
    double discount = 0.0;
    String? message;

    if (code == 'BOOK10') {
      discount = state.subtotal * 0.10;
      message = 'Đã áp dụng mã BOOK10 (Giảm 10%)!';
    } else if (code == 'FREESHIP') {
      discount = state.shippingFee;
      message = 'Đã áp dụng mã FREESHIP (Miễn phí vận chuyển)!';
    } else if (code == 'WELCOME') {
      discount = 20000.0;
      message = 'Đã áp dụng mã WELCOME (Giảm 20.000đ)!';
    } else {
      emit(state.copyWith(errorMessage: 'Mã giảm giá không hợp lệ!'));
      return;
    }

    emit(state.copyWith(
      voucherCode: code,
      discountAmount: discount,
      message: message,
    ));
  }

  void _onRemoveVoucher(RemoveVoucher event, Emitter<CartState> emit) {
    emit(state.copyWith(clearVoucher: true, message: 'Đã gỡ mã giảm giá'));
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    try {
      await _dbHelper.clearCart();
      emit(const CartState(status: CartStatus.loaded, items: []));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: 'Lỗi làm trống giỏ hàng',
      ));
    }
  }
}
