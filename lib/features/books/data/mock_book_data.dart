import 'models/book_model.dart';
import 'models/category_model.dart';

/// Danh mục thể loại và Banner trang chủ
class MockBookData {
  MockBookData._();

  static const List<Category> categories = [
    Category(id: 'cat_01', name: 'Văn học', icon: 'menu_book'),
    Category(id: 'cat_02', name: 'Kinh tế', icon: 'trending_up'),
    Category(id: 'cat_03', name: 'Kỹ năng sống', icon: 'psychology'),
    Category(id: 'cat_04', name: 'Công nghệ', icon: 'computer'),
    Category(id: 'cat_05', name: 'Truyện tranh', icon: 'auto_stories'),
    Category(id: 'cat_06', name: 'Thiếu nhi', icon: 'child_care'),
    Category(id: 'cat_07', name: 'Lịch sử', icon: 'history_edu'),
    Category(id: 'cat_08', name: 'Ngoại ngữ', icon: 'translate'),
  ];

  /// Toàn bộ dữ liệu sách mẫu cứng đã được xóa bỏ hoàn toàn.
  /// Dữ liệu hiện được lưu trữ và truy xuất 100% từ SQLite (Bảng 'books').
  static final List<Book> books = [];

  /// Banner quảng cáo trang chủ
  static const List<String> bannerImages = [
    'https://picsum.photos/seed/banner1/800/350',
    'https://picsum.photos/seed/banner2/800/350',
    'https://picsum.photos/seed/banner3/800/350',
  ];

  static List<Book> get bestSellers =>
      books.where((b) => b.rating >= 4.7 && b.reviewCount >= 200).toList();

  static List<Book> get newReleases =>
      books.where((b) => b.publishYear >= 2024).toList();

  static List<Book> byCategory(String category) =>
      books.where((b) => b.category == category).toList();

  static Book? findById(String id) {
    try {
      return books.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
