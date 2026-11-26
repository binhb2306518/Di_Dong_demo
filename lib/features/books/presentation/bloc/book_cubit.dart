import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/pocketbase_book_service.dart';
import '../../data/models/book_model.dart';

enum BookStatus { initial, loading, loaded, error }

class BookState extends Equatable {
  final BookStatus status;
  final List<Book> books;
  final String? errorMessage;

  const BookState({
    this.status = BookStatus.initial,
    this.books = const [],
    this.errorMessage,
  });

  BookState copyWith({
    BookStatus? status,
    List<Book>? books,
    String? errorMessage,
  }) {
    return BookState(
      status: status ?? this.status,
      books: books ?? this.books,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, books, errorMessage];
}

class BookCubit extends Cubit<BookState> {
  static final BookCubit instance = BookCubit._internal();

  BookCubit._internal() : super(const BookState()) {
    loadBooks();
  }

  factory BookCubit() => instance;

  /// Tải toàn bộ danh sách sách từ PocketBase
  Future<void> loadBooks() async {
    emit(state.copyWith(status: BookStatus.loading));
    try {
      var list = await PocketBaseBookService.instance.getAllBooks();
      if (list.isEmpty) {
        await PocketBaseBookService.instance.seedSampleBooksIfEmpty();
        list = await PocketBaseBookService.instance.getAllBooks();
      }
      emit(state.copyWith(status: BookStatus.loaded, books: list));
    } catch (e) {
      emit(state.copyWith(
        status: BookStatus.error,
        errorMessage: 'Lỗi tải sách từ PocketBase: ${e.toString()}',
      ));
    }
  }

  /// Thêm sách mới lên PocketBase
  Future<void> addBook(Book book, {File? imageFile}) async {
    await PocketBaseBookService.instance.insertBook(book, imageFile: imageFile);
    await loadBooks();
  }

  /// Cập nhật sách trên PocketBase
  Future<void> updateBook(Book book, {File? imageFile}) async {
    await PocketBaseBookService.instance.updateBook(book, imageFile: imageFile);
    await loadBooks();
  }

  /// Xóa sách khỏi PocketBase
  Future<void> deleteBook(String id) async {
    await PocketBaseBookService.instance.deleteBook(id);
    await loadBooks();
  }
}
