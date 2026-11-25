import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/models/address_model.dart';

/// Màn hình Quản lý Sổ Địa chỉ – kết nối SQLite DatabaseHelper CRUD
class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  State<AddressManagementScreen> createState() =>
      _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  List<AddressModel> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final list = await DatabaseHelper.instance.getAddresses();
      if (mounted) {
        setState(() {
          _addresses = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAddress(String id) async {
    await DatabaseHelper.instance.deleteAddress(id);
    await _loadAddresses();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa địa chỉ')),
      );
    }
  }

  Future<void> _setDefaultAddress(String id) async {
    await DatabaseHelper.instance.setDefaultAddress(id);
    await _loadAddresses();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đặt làm địa chỉ mặc định')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sổ địa chỉ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_off,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      const Text('Chưa có địa chỉ nào'),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _addresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final addr = _addresses[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: addr.isDefault
                              ? AppColors.primary
                              : Colors.grey.shade200,
                          width: addr.isDefault ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(addr.recipientName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              const SizedBox(width: 8),
                              Text('(${addr.phoneNumber})',
                                  style: Theme.of(context).textTheme.bodySmall),
                              const Spacer(),
                              if (addr.isDefault)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('Mặc định',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(addr.fullAddress,
                              style: Theme.of(context).textTheme.bodyMedium),
                          const Divider(height: 16),
                          Row(
                            children: [
                              if (!addr.isDefault)
                                TextButton.icon(
                                  onPressed: () => _setDefaultAddress(addr.id),
                                  icon: const Icon(Icons.check_circle_outline,
                                      size: 16),
                                  label: const Text('Đặt mặc định',
                                      style: TextStyle(fontSize: 12)),
                                ),
                              const Spacer(),
                              IconButton(
                                onPressed: () =>
                                    _showEditDialog(context, addr),
                                icon: const Icon(Icons.edit_outlined,
                                    size: 20, color: AppColors.primary),
                              ),
                              IconButton(
                                onPressed: () => _deleteAddress(addr.id),
                                icon: const Icon(Icons.delete_outline,
                                    size: 20, color: AppColors.error),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditDialog(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Thêm địa chỉ'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showEditDialog(BuildContext context, AddressModel? editAddr) {
    final isEdit = editAddr != null;
    final nameCtrl =
        TextEditingController(text: isEdit ? editAddr.recipientName : '');
    final phoneCtrl =
        TextEditingController(text: isEdit ? editAddr.phoneNumber : '');
    final streetCtrl =
        TextEditingController(text: isEdit ? editAddr.streetAddress : '');
    final wardCtrl =
        TextEditingController(text: isEdit ? editAddr.ward : 'Phường Xuân Khánh');
    final districtCtrl =
        TextEditingController(text: isEdit ? editAddr.district : 'Quận Ninh Kiều');
    final cityCtrl =
        TextEditingController(text: isEdit ? editAddr.city : 'TP. Cần Thơ');
    bool isDefault = editAddr?.isDefault ?? false;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.fromLTRB(
                20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isEdit ? 'Sửa địa chỉ' : 'Thêm địa chỉ mới',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Tên người nhận'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Nhập tên người nhận' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration:
                          const InputDecoration(labelText: 'Số điện thoại'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Nhập số điện thoại' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: streetCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Số nhà, tên đường'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Nhập tên đường' : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: districtCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Quận/Huyện'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: cityCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Tỉnh/TP'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Đặt làm mặc định'),
                      value: isDefault,
                      onChanged: (v) => setSheetState(() => isDefault = v),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final address = AddressModel(
                            id: isEdit
                                ? editAddr.id
                                : 'addr_${DateTime.now().millisecondsSinceEpoch}',
                            recipientName: nameCtrl.text.trim(),
                            phoneNumber: phoneCtrl.text.trim(),
                            streetAddress: streetCtrl.text.trim(),
                            ward: wardCtrl.text.trim(),
                            district: districtCtrl.text.trim(),
                            city: cityCtrl.text.trim(),
                            isDefault: isDefault,
                          );

                          if (isEdit) {
                            await DatabaseHelper.instance
                                .updateAddress(address);
                          } else {
                            await DatabaseHelper.instance
                                .insertAddress(address);
                          }

                          if (context.mounted) {
                            Navigator.pop(ctx);
                            _loadAddresses();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: Text(isEdit ? 'Lưu thay đổi' : 'Thêm địa chỉ'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
