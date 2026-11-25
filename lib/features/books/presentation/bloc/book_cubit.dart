import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/database_helper.dart';
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

  /// Tải toàn bộ danh sách sách từ SQLite
  Future<void> loadBooks() async {
    emit(state.copyWith(status: BookStatus.loading));
    try {
      final list = await DatabaseHelper.instance.getAllBooks();
      emit(state.copyWith(status: BookStatus.loaded, books: list));
    } catch (e) {
      emit(state.copyWith(
        status: BookStatus.error,
        errorMessage: 'Lỗi tải sách: ${e.toString()}',
      ));
    }
  }

  /// Thêm sách mới vào SQLite
  Future<void> addBook(Book book) async {
    await DatabaseHelper.instance.insertBook(book);
    await loadBooks();
  }

  /// Cập nhật sách trong SQLite
  Future<void> updateBook(Book book) async {
    await DatabaseHelper.instance.updateBook(book);
    await loadBooks();
  }

  /// Xóa sách khỏi SQLite
  Future<void> deleteBook(String id) async {
    await DatabaseHelper.instance.deleteBook(id);
    await loadBooks();
  }
}
