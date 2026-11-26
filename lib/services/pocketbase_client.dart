import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

PocketBase? _pbInstance;

/// Khởi tạo và trả về instance của PocketBase
/// Sử dụng AsyncAuthStore backed by SharedPreferences để giữ token đăng nhập qua các lần chạy app
Future<PocketBase> getPocketbaseInstance() async {
  if (_pbInstance != null) {
    return _pbInstance!;
  }

  final prefs = await SharedPreferences.getInstance();
  final authStore = AsyncAuthStore(
    save: (String data) async => prefs.setString('pb_auth', data),
    initial: prefs.getString('pb_auth'),
    clear: () async => prefs.remove('pb_auth'),
  );

  final url = dotenv.env['POCKETBASE_URL'] ?? 'http://10.0.2.2:8090';
  _pbInstance = PocketBase(
    url,
    authStore: authStore,
  );

  return _pbInstance!;
}

/// Helper lấy URL đầy đủ của file ảnh lưu trên PocketBase
String getPocketbaseFileUrl(String collectionName, String recordId, String filename) {
  if (filename.isEmpty) return '';
  if (filename.startsWith('http://') || filename.startsWith('https://')) {
    return filename;
  }
  final baseUrl = dotenv.env['POCKETBASE_URL'] ?? 'http://10.0.2.2:8090';
  return '$baseUrl/api/files/$collectionName/$recordId/$filename';
}
