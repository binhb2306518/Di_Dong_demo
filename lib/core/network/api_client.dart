import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../database/database_helper.dart';
import '../../features/books/data/models/book_model.dart';

/// Client kết nối Backend (PocketBase / REST API) có fallback sang SQLite
class ApiClient {
  static final ApiClient instance = ApiClient._init();
  final http.Client _client;

  ApiClient._init() : _client = http.Client();

  /// Lấy danh sách sách từ Server hoặc fallback sang SQLite
  Future<List<Book>> fetchBooks() async {
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/api/collections/books/records');
      final response = await _client.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];
        return items.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Offline fallback sang SQLite
    }
    return await DatabaseHelper.instance.getAllBooks();
  }

  /// Lấy chi tiết sách theo ID
  Future<Book?> fetchBookById(String id) async {
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/api/collections/books/records/$id');
      final response = await _client.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Book.fromJson(data);
      }
    } catch (_) {
      // Fallback
    }
    return await DatabaseHelper.instance.getBookById(id);
  }

  /// Đăng nhập người dùng qua API
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/api/collections/users/auth-with-password');
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'identity': email, 'password': password}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // Fallback
    }
    return null;
  }
}
