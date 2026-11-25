import 'package:equatable/equatable.dart';

/// Model Người dùng (Khách hàng 'user' / Quản trị viên 'admin')
class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String avatarUrl;
  final String role; // 'user' hoặc 'admin'

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone = '',
    this.avatarUrl = '',
    this.role = 'user',
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'phone': phone,
        'avatar_url': avatarUrl,
        'role': role,
      };

  @override
  List<Object?> get props => [id, email, name, phone, avatarUrl, role];
}
