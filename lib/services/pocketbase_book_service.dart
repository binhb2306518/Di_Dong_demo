import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import '../../features/books/data/models/book_model.dart';
import 'pocketbase_client.dart';

class PocketBaseBookService {
  PocketBaseBookService._();
  static final PocketBaseBookService instance = PocketBaseBookService._();

  /// Lấy toàn bộ danh sách sách từ collection 'books'
  Future<List<Book>> getAllBooks() async {
    final pb = await getPocketbaseInstance();
    final records = await pb.collection('books').getFullList(sort: '-created');
    return records.map((r) => _recordToBook(r)).toList();
  }

  /// Thêm sách mới lên PocketBase
  Future<Book> insertBook(Book book, {File? imageFile}) async {
    final pb = await getPocketbaseInstance();
    final body = _bookToMap(book);

    List<http.MultipartFile> files = [];
    File? uploadFile = imageFile;
    if (uploadFile == null && book.coverImage.isNotEmpty && !book.coverImage.startsWith('http')) {
      final f = File(book.coverImage);
      if (f.existsSync()) {
        uploadFile = f;
      }
    }

    if (uploadFile != null) {
      files.add(await http.MultipartFile.fromPath('cover_image', uploadFile.path));
    }

    final record = await pb.collection('books').create(
      body: body,
      files: files,
    );

    return _recordToBook(record);
  }

  /// Cập nhật sách trên PocketBase
  Future<Book> updateBook(Book book, {File? imageFile}) async {
    final pb = await getPocketbaseInstance();
    final body = _bookToMap(book);

    List<http.MultipartFile> files = [];
    File? uploadFile = imageFile;
    if (uploadFile == null && book.coverImage.isNotEmpty && !book.coverImage.startsWith('http')) {
      final f = File(book.coverImage);
      if (f.existsSync()) {
        uploadFile = f;
      }
    }

    if (uploadFile != null) {
      files.add(await http.MultipartFile.fromPath('cover_image', uploadFile.path));
    }

    final record = await pb.collection('books').update(
      book.id,
      body: body,
      files: files,
    );

    return _recordToBook(record);
  }

  /// Xóa sách khỏi PocketBase
  Future<void> deleteBook(String id) async {
    final pb = await getPocketbaseInstance();
    await pb.collection('books').delete(id);
  }

  /// Khởi tạo một số sách mẫu nếu bảng books trên PocketBase đang trống
  Future<void> seedSampleBooksIfEmpty() async {
    // Không tự động tạo sách mẫu để tôn trọng dữ liệu thực tế của người dùng
  }

  Book _recordToBook(RecordModel record) {
    final data = record.data;
    final coverFile = record.getStringValue('cover_image');
    final coverUrl = coverFile.isNotEmpty
        ? getPocketbaseFileUrl('books', record.id, coverFile)
        : '';

    return Book(
      id: record.id,
      title: record.getStringValue('title'),
      author: record.getStringValue('author'),
      category: record.getStringValue('category'),
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (data['original_price'] as num?)?.toDouble() ?? 0.0,
      discountPercent: (data['discount_percent'] as num?)?.toInt() ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: (data['review_count'] as num?)?.toInt() ?? 0,
      stockQuantity: (data['stock_quantity'] as num?)?.toInt() ?? 0,
      publisher: record.getStringValue('publisher'),
      publishYear: (data['publish_year'] as num?)?.toInt() ?? 2024,
      pageCount: (data['page_count'] as num?)?.toInt() ?? 0,
      coverImage: coverUrl.isNotEmpty ? coverUrl : record.getStringValue('cover_image'),
      sampleContent: record.getStringValue('sample_content'),
      description: record.getStringValue('description'),
    );
  }

  Map<String, dynamic> _bookToMap(Book book) {
    return {
      'title': book.title,
      'author': book.author,
      'category': book.category,
      'price': book.price,
      'original_price': book.originalPrice > 0 ? book.originalPrice : book.price,
      'stock_quantity': book.stockQuantity,
      'description': book.description,
      'rating': book.rating,
      'is_featured': false,
      'is_popular': false,
    };
  }
}
