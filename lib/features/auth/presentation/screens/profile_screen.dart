import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../data/models/user_model.dart';
import '../cubit/auth_cubit.dart';

/// Màn hình Cá nhân & Cài đặt – Phân quyền ẩn/hiện Admin
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final user = authState.user;
    final isLoggedIn = authState.isAuthenticated;
    final isAdmin = authState.isAdmin;

    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header thông tin người dùng ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryLight,
                  ],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    child: isLoggedIn
                        ? Text(
                            _getInitials(user?.name),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 46,
                            color: Colors.white,
                          ),
                  ),
                  const SizedBox(height: 12),
                  if (isLoggedIn) ...[
                    Text(
                      user?.name ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                      ),
                    ),
                    if (user?.phone != null && user!.phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '📞 ${user.phone}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ] else ...[
                    InkWell(
                      onTap: () => context.go('/login'),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Đăng nhập',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_ios_rounded,
                                color: Colors.white, size: 14),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bấm vào để đăng nhập hoặc đăng ký tài khoản',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),

                  // Huy hiệu Role (Vai trò): Chỉ hiển thị khi ĐÃ đăng nhập
                  if (isLoggedIn)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAdmin
                            ? AppColors.secondary
                            : Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isAdmin
                            ? '👑 QUẢN TRỊ VIÊN (ADMIN)'
                            : '👤 KHÁCH HÀNG (USER)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Danh sách menu ──
            _buildMenuSection(context, 'Tài khoản', [
              _MenuItem(
                icon: Icons.person_outline,
                label: 'Thông tin cá nhân',
                onTap: () {
                  if (!isLoggedIn) {
                    context.go('/login');
                  } else if (user != null) {
                    _showEditProfileDialog(context, user);
                  }
                },
              ),
              _MenuItem(
                icon: Icons.location_on_outlined,
                label: 'Sổ địa chỉ',
                onTap: () => context.push('/addresses'),
              ),
              _MenuItem(
                icon: Icons.lock_outline,
                label: 'Đổi mật khẩu',
                onTap: () {
                  if (!isLoggedIn) {
                    context.go('/login');
                  } else {
                    _showChangePasswordDialog(context);
                  }
                },
              ),
            ]),

            _buildMenuSection(context, 'Đơn hàng', [
              _MenuItem(
                icon: Icons.receipt_long_outlined,
                label: 'Đơn hàng của tôi',
                onTap: () => context.go('/orders'),
              ),
              _MenuItem(
                icon: Icons.favorite_border,
                label: 'Sách yêu thích',
                onTap: () => context.go('/wishlist'),
              ),
            ]),

            _buildMenuSection(context, 'Cài đặt', [
              _MenuItem(
                icon: Icons.dark_mode_outlined,
                label: 'Chế độ tối',
                trailing: BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, themeMode) {
                    final isDark = themeMode == ThemeMode.dark;
                    return Switch(
                      value: isDark,
                      onChanged: (v) =>
                          context.read<ThemeCubit>().toggleTheme(v),
                      activeThumbColor: AppColors.primary,
                    );
                  },
                ),
              ),
              _MenuItem(
                icon: Icons.notifications_outlined,
                label: 'Thông báo',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.language,
                label: 'Ngôn ngữ',
                trailing: const Text('Tiếng Việt',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ),
            ]),

            // ── Mục Quản trị: CHỈ HIỂN THỊ KHI ROLE === 'admin' ──
            if (isAdmin)
              _buildMenuSection(context, 'Quản trị hệ thống', [
                _MenuItem(
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Bảng điều khiển Admin',
                  onTap: () => context.push('/admin'),
                  iconColor: AppColors.secondary,
                ),
              ]),

            const SizedBox(height: 8),

            // Nút Đăng xuất / Đăng nhập
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: isLoggedIn
                    ? OutlinedButton.icon(
                        onPressed: () async {
                          await context.read<AuthCubit>().logout();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã đăng xuất!')),
                            );
                            context.go('/login');
                          }
                        },
                        icon: const Icon(Icons.logout, color: AppColors.error),
                        label: const Text('Đăng xuất',
                            style: TextStyle(color: AppColors.error)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => context.go('/login'),
                        icon: const Icon(Icons.login),
                        label: const Text('Đăng nhập tài khoản'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),

            // Version
            Text('BookVerse v1.0.0',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(
      BuildContext context, String title, List<_MenuItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4),
            child: Text(title,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children:
                  items.map((item) => _buildMenuTile(context, item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, _MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(item.icon,
                size: 22, color: item.iconColor ?? AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(item.label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
            ),
            if (item.trailing != null) item.trailing!,
            if (item.trailing == null && item.onTap != null)
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, UserModel user) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);
    final phoneCtrl = TextEditingController(text: user.phone);
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.edit_note_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Chỉnh sửa thông tin'),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên *',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Vui lòng nhập họ tên'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Gmail đăng nhập *',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!v.contains('@')) return 'Email không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isSaving = true);

                      final success =
                          await context.read<AuthCubit>().updateProfile(
                                name: nameCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                                phone: phoneCtrl.text.trim(),
                              );

                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? '✅ Cập nhật thông tin thành công!'
                                : '❌ Cập nhật thất bại, vui lòng thử lại!'),
                            backgroundColor:
                                success ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Lưu thay đổi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool isSaving = false;
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.lock_reset_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Đổi mật khẩu'),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: oldPassCtrl,
                    obscureText: obscureOld,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu hiện tại *',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(obscureOld
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setDialogState(() => obscureOld = !obscureOld),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Vui lòng nhập mật khẩu hiện tại'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: newPassCtrl,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu mới (tối thiểu 8 ký tự) *',
                      prefixIcon: const Icon(Icons.lock_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setDialogState(() => obscureNew = !obscureNew),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Vui lòng nhập mật khẩu mới';
                      }
                      if (v.length < 8) {
                        return 'Mật khẩu phải từ 8 ký tự trở lên';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmPassCtrl,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Xác nhận mật khẩu mới *',
                      prefixIcon: const Icon(Icons.lock_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setDialogState(
                            () => obscureConfirm = !obscureConfirm),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Vui lòng xác nhận mật khẩu';
                      }
                      if (v != newPassCtrl.text) {
                        return 'Mật khẩu xác nhận không khớp';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isSaving = true);

                      final success =
                          await context.read<AuthCubit>().changePassword(
                                oldPassword: oldPassCtrl.text.trim(),
                                newPassword: newPassCtrl.text.trim(),
                              );

                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? '✅ Đổi mật khẩu thành công!'
                                : '❌ Đổi mật khẩu thất bại, kiểm tra lại mật khẩu cũ!'),
                            backgroundColor:
                                success ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Đổi mật khẩu'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    this.iconColor,
  });
}
