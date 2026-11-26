import 'package:pocketbase/pocketbase.dart';
import '../../features/auth/data/models/user_model.dart';
import 'pocketbase_client.dart';

class PocketBaseAuthService {
  PocketBaseAuthService._();
  static final PocketBaseAuthService instance = PocketBaseAuthService._();

  /// Đăng nhập bằng Email và Mật khẩu qua PocketBase
  Future<UserModel?> login(String email, String password) async {
    final pb = await getPocketbaseInstance();
    final authData = await pb.collection('users').authWithPassword(email.trim(), password);
    final record = authData.record;
    if (record == null) return null;

    final avatarUrl = record.getStringValue('avatar').isNotEmpty
        ? getPocketbaseFileUrl('users', record.id, record.getStringValue('avatar'))
        : '';

    final name = record.getStringValue('name');
    var role = record.getStringValue('role');
    final recEmail = record.getStringValue('email');
    if (role.isEmpty) {
      role = (recEmail.toLowerCase().startsWith('admin') || recEmail.toLowerCase() == 'admin@gmail.com')
          ? 'admin'
          : 'user';
    }

    return UserModel(
      id: record.id,
      email: recEmail,
      name: name.isNotEmpty ? name : recEmail.split('@').first,
      phone: record.getStringValue('phone'),
      role: role,
      avatarUrl: avatarUrl,
    );
  }

  /// Đăng ký tài khoản người dùng mới trên PocketBase
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
    String role = 'user',
  }) async {
    final pb = await getPocketbaseInstance();
    try {
      final body = <String, dynamic>{
        'email': email.trim(),
        'password': password,
        'passwordConfirm': password,
        'name': name.trim(),
        'phone': phone.trim(),
        'role': role,
      };
      await pb.collection('users').create(body: body);
      return true;
    } catch (_) {
      // Trường hợp users collection chưa tạo thêm trường phone/role trên PocketBase UI
      final fallbackBody = <String, dynamic>{
        'email': email.trim(),
        'password': password,
        'passwordConfirm': password,
        'name': name.trim(),
      };
      await pb.collection('users').create(body: fallbackBody);
      return true;
    }
  }

  /// Lấy user hiện tại từ PocketBase authStore (nếu token còn hạn)
  Future<UserModel?> getCurrentUser() async {
    final pb = await getPocketbaseInstance();
    if (!pb.authStore.isValid) return null;
    final record = pb.authStore.model;
    if (record is RecordModel) {
      final avatarUrl = record.getStringValue('avatar').isNotEmpty
          ? getPocketbaseFileUrl('users', record.id, record.getStringValue('avatar'))
          : '';
      final name = record.getStringValue('name');
      var role = record.getStringValue('role');
      final recEmail = record.getStringValue('email');
      if (role.isEmpty) {
        role = (recEmail.toLowerCase().startsWith('admin') || recEmail.toLowerCase() == 'admin@gmail.com')
            ? 'admin'
            : 'user';
      }

      return UserModel(
        id: record.id,
        email: recEmail,
        name: name.isNotEmpty ? name : recEmail.split('@').first,
        phone: record.getStringValue('phone'),
        role: role,
        avatarUrl: avatarUrl,
      );
    }
    return null;
  }

  /// Đăng xuất khỏi PocketBase
  Future<void> logout() async {
    final pb = await getPocketbaseInstance();
    pb.authStore.clear();
  }

  /// Cập nhật thông tin cá nhân (Tên, Gmail đăng nhập, Số điện thoại)
  Future<UserModel> updateProfile({
    required String id,
    required String name,
    required String email,
    required String phone,
  }) async {
    final pb = await getPocketbaseInstance();
    final body = <String, dynamic>{
      'name': name.trim(),
      'phone': phone.trim(),
    };

    // Kiểm tra xem email có thay đổi so với hiện tại không
    final currentEmail = pb.authStore.model is RecordModel
        ? (pb.authStore.model as RecordModel).getStringValue('email')
        : '';
    if (email.trim().isNotEmpty && email.toLowerCase().trim() != currentEmail.toLowerCase().trim()) {
      body['email'] = email.toLowerCase().trim();
    }

    RecordModel record;
    try {
      record = await pb.collection('users').update(id, body: body);
    } catch (_) {
      // Fallback 1: Nếu chưa có trường phone trên PB UI
      body.remove('phone');
      try {
        record = await pb.collection('users').update(id, body: body);
      } catch (_) {
        // Fallback 2: Nếu đổi email trực tiếp bị chặn bởi rule
        body.remove('email');
        record = await pb.collection('users').update(id, body: body);
      }
    }

    final avatarUrl = record.getStringValue('avatar').isNotEmpty
        ? getPocketbaseFileUrl('users', record.id, record.getStringValue('avatar'))
        : '';

    var role = record.getStringValue('role');
    final recEmail = record.getStringValue('email');
    if (role.isEmpty) {
      role = (recEmail.toLowerCase().startsWith('admin') || recEmail.toLowerCase() == 'admin@gmail.com')
          ? 'admin'
          : 'user';
    }

    return UserModel(
      id: record.id,
      email: recEmail.isNotEmpty ? recEmail : email,
      name: record.getStringValue('name').isNotEmpty ? record.getStringValue('name') : name,
      phone: record.getStringValue('phone').isNotEmpty ? record.getStringValue('phone') : phone,
      role: role,
      avatarUrl: avatarUrl,
    );
  }

  /// Đổi mật khẩu tài khoản người dùng hoặc admin trên PocketBase
  Future<bool> changePassword({
    required String id,
    required String oldPassword,
    required String newPassword,
  }) async {
    final pb = await getPocketbaseInstance();
    await pb.collection('users').update(
      id,
      body: {
        'oldPassword': oldPassword,
        'password': newPassword,
        'passwordConfirm': newPassword,
      },
    );
    return true;
  }

  /// Tự động khởi tạo sẵn tài khoản Admin và User mẫu nếu chưa có
  Future<void> seedDefaultUsersIfEmpty() async {
    final pb = await getPocketbaseInstance();
    try {
      // 1. Kiểm tra và tạo tài khoản Admin mặc định
      try {
        await pb.collection('users').getFirstListItem('email = "admin@gmail.com"');
      } catch (_) {
        try {
          await pb.collection('users').create(body: {
            'email': 'admin@gmail.com',
            'password': 'admin123456',
            'passwordConfirm': 'admin123456',
            'name': 'Quản Trị Viên',
            'phone': '0909999999',
            'role': 'admin',
          });
        } catch (_) {
          // Thử tạo không có phone và role nếu collection chưa có
          await pb.collection('users').create(body: {
            'email': 'admin@gmail.com',
            'password': 'admin123456',
            'passwordConfirm': 'admin123456',
            'name': 'Quản Trị Viên',
          });
        }
      }

      // 2. Kiểm tra và tạo tài khoản Khách hàng mặc định
      try {
        await pb.collection('users').getFirstListItem('email = "user@gmail.com"');
      } catch (_) {
        try {
          await pb.collection('users').create(body: {
            'email': 'user@gmail.com',
            'password': 'user123456',
            'passwordConfirm': 'user123456',
            'name': 'Nguyễn Văn A',
            'phone': '0901234567',
            'role': 'user',
          });
        } catch (_) {
          await pb.collection('users').create(body: {
            'email': 'user@gmail.com',
            'password': 'user123456',
            'passwordConfirm': 'user123456',
            'name': 'Nguyễn Văn A',
          });
        }
      }
    } catch (_) {}
  }
}
