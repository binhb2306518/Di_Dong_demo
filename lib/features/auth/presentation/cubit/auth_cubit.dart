import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../services/pocketbase_auth_service.dart';
import '../../data/models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isAdmin => user?.role == 'admin';

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}

class AuthCubit extends Cubit<AuthState> {
  static final AuthCubit instance = AuthCubit._internal();
  static const String _userKey = 'current_user_session';

  AuthCubit._internal() : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    await PocketBaseAuthService.instance.seedDefaultUsersIfEmpty();
    await checkAuth();
  }

  factory AuthCubit() => instance;

  bool get isAdmin => state.isAdmin;
  bool get isAuthenticated => state.isAuthenticated;
  UserModel? get currentUser => state.user;

  /// Kiểm tra phiên đăng nhập đã lưu trong SharedPreferences / PocketBase
  Future<void> checkAuth() async {
    try {
      final pbUser = await PocketBaseAuthService.instance.getCurrentUser();
      if (pbUser != null) {
        emit(AuthState(status: AuthStatus.authenticated, user: pbUser));
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        final map = jsonDecode(userJson) as Map<String, dynamic>;
        final user = UserModel.fromJson(map);
        emit(AuthState(status: AuthStatus.authenticated, user: user));
        return;
      }
    } catch (_) {}
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  /// Đăng nhập tài khoản qua PocketBase
  Future<bool> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await PocketBaseAuthService.instance.login(email, password);
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(user.toJson()));
        emit(AuthState(status: AuthStatus.authenticated, user: user));
        return true;
      } else {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Email hoặc mật khẩu không chính xác!',
        ));
        return false;
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Lỗi đăng nhập: ${e.toString()}',
      ));
      return false;
    }
  }

  /// Đăng ký tài khoản người dùng mới trên PocketBase
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
    String role = 'user',
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final success = await PocketBaseAuthService.instance.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
      );
      if (!success) {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Đăng ký thất bại, vui lòng thử lại!',
        ));
        return false;
      }
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Lỗi đăng ký: ${e.toString()}',
      ));
      return false;
    }
  }

  /// Đăng xuất tài khoản
  Future<void> logout() async {
    try {
      await PocketBaseAuthService.instance.logout();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (_) {}
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  /// Cập nhật thông tin cá nhân (Tên, Gmail, Số điện thoại)
  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final user = state.user;
    if (user == null) return false;

    emit(state.copyWith(status: AuthStatus.loading));
    try {
      UserModel updatedUser;
      try {
        updatedUser = await PocketBaseAuthService.instance.updateProfile(
          id: user.id,
          name: name,
          email: email,
          phone: phone,
        );
      } catch (_) {
        updatedUser = UserModel(
          id: user.id,
          name: name,
          email: email,
          phone: phone,
          role: user.role,
          avatarUrl: user.avatarUrl,
        );
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(updatedUser.toJson()));

      emit(AuthState(status: AuthStatus.authenticated, user: updatedUser));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        errorMessage: 'Lỗi cập nhật thông tin: ${e.toString()}',
      ));
      return false;
    }
  }

  /// Đổi mật khẩu tài khoản
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = state.user;
    if (user == null) return false;

    try {
      await PocketBaseAuthService.instance.changePassword(
        id: user.id,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Đổi mật khẩu thất bại: ${e.toString()}',
      ));
      return false;
    }
  }
}
