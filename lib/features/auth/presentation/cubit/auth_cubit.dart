import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/database/database_helper.dart';
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
    checkAuth();
  }

  factory AuthCubit() => instance;

  bool get isAdmin => state.isAdmin;
  bool get isAuthenticated => state.isAuthenticated;
  UserModel? get currentUser => state.user;

  /// Kiểm tra phiên đăng nhập đã lưu trong SharedPreferences
  Future<void> checkAuth() async {
    try {
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

  /// Đăng nhập tài khoản
  Future<bool> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await DatabaseHelper.instance.login(email, password);
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

  /// Đăng ký tài khoản người dùng mới (mặc định role = 'user')
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
    String role = 'user',
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final success = await DatabaseHelper.instance.registerUser(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
      );
      if (!success) {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Email này đã tồn tại trong hệ thống!',
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (_) {}
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
