import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../books/data/models/book_model.dart';
import '../../../books/data/mock_book_data.dart';
import '../../../books/presentation/bloc/book_cubit.dart';

/// Màn hình Admin – Thêm / Sửa sách lưu trực tiếp vào SQLite
class AdminAddEditBookScreen extends StatefulWidget {
  final Book? book; // null = thêm mới, not-null = chỉnh sửa
  const AdminAddEditBookScreen({super.key, this.book});

  @override
  State<AdminAddEditBookScreen> createState() => _AdminAddEditBookScreenState();
}

class _AdminAddEditBookScreenState extends State<AdminAddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _authorCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _originalPriceCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _publisherCtrl;
  late TextEditingController _pageCountCtrl;
  late TextEditingController _coverImageCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _sampleCtrl;
  String _selectedCategory = 'Văn học';
  bool _isLoading = false;

  bool get _isEdit => widget.book != null;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleCtrl = TextEditingController(text: b?.title ?? '');
    _authorCtrl = TextEditingController(text: b?.author ?? '');
    _priceCtrl = TextEditingController(text: b?.price.toInt().toString() ?? '');
    _originalPriceCtrl =
        TextEditingController(text: b?.originalPrice.toInt().toString() ?? '');
    _stockCtrl = TextEditingController(text: b?.stockQuantity.toString() ?? '10');
    _publisherCtrl = TextEditingController(text: b?.publisher ?? '');
    _pageCountCtrl = TextEditingController(text: b?.pageCount.toString() ?? '200');
    _coverImageCtrl = TextEditingController(text: b?.coverImage ?? '');
    _descCtrl = TextEditingController(text: b?.description ?? '');
    _sampleCtrl = TextEditingController(text: b?.sampleContent ?? '');
    _selectedCategory = b?.category ?? 'Văn học';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _priceCtrl.dispose();
    _originalPriceCtrl.dispose();
    _stockCtrl.dispose();
    _publisherCtrl.dispose();
    _pageCountCtrl.dispose();
    _coverImageCtrl.dispose();
    _descCtrl.dispose();
    _sampleCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final price = double.tryParse(_priceCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
    final origPriceText = _originalPriceCtrl.text.replaceAll(',', '').trim();
    final origPrice = origPriceText.isNotEmpty
        ? (double.tryParse(origPriceText) ?? price)
        : price;
    final stock = int.tryParse(_stockCtrl.text.trim()) ?? 1;
    final pages = int.tryParse(_pageCountCtrl.text.trim()) ?? 100;

    int discount = 0;
    if (origPrice > price && origPrice > 0) {
      discount = (((origPrice - price) / origPrice) * 100).round();
    }

    // Nếu không nhập link ảnh, tạo ảnh placeholder ngẫu nhiên đẹp mắt
    final cover = _coverImageCtrl.text.trim().isNotEmpty
        ? _coverImageCtrl.text.trim()
        : (widget.book?.coverImage.isNotEmpty == true
            ? widget.book!.coverImage
            : 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/300/450');

    if (_isEdit) {
      final updated = widget.book!.copyWith(
        title: _titleCtrl.text.trim(),
        author: _authorCtrl.text.trim(),
        category: _selectedCategory,
        price: price,
        originalPrice: origPrice,
        discountPercent: discount,
        stockQuantity: stock,
        pageCount: pages,
        publisher: _publisherCtrl.text.trim(),
        coverImage: cover,
        description: _descCtrl.text.trim(),
        sampleContent: _sampleCtrl.text.trim(),
      );

      await context.read<BookCubit>().updateBook(updated);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật sách "${updated.title}" thành công!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } else {
      final newBook = Book(
        id: 'book_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleCtrl.text.trim(),
        author: _authorCtrl.text.trim(),
        category: _selectedCategory,
        price: price,
        originalPrice: origPrice,
        discountPercent: discount,
        stockQuantity: stock,
        pageCount: pages,
        publisher: _publisherCtrl.text.trim(),
        coverImage: cover,
        description: _descCtrl.text.trim(),
        sampleContent: _sampleCtrl.text.trim(),
        rating: 5.0,
        reviewCount: 0,
      );

      await context.read<BookCubit>().addBook(newBook);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm sách "${newBook.title}" vào kho thành công!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Sửa thông tin sách' : 'Thêm sách mới'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Lưu',
                    style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Xem trước ảnh bìa
              Center(
                child: Container(
                  width: 120,
                  height: 170,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _coverImageCtrl.text.trim().isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: _coverImageCtrl.text.trim(),
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image,
                                    size: 36, color: AppColors.textSecondary),
                                SizedBox(height: 4),
                                Text('Link lỗi',
                                    style: TextStyle(fontSize: 11)),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  size: 36,
                                  color:
                                      AppColors.primary.withValues(alpha: 0.5)),
                              const SizedBox(height: 6),
                              Text('Ảnh bìa',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary
                                          .withValues(alpha: 0.5))),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                _coverImageCtrl,
                'URL Ảnh bìa sách',
                hintText: 'https://example.com/anh-bia.jpg (để trống nếu dùng mặc định)',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              _buildTextField(_titleCtrl, 'Tên sách', required: true),
              const SizedBox(height: 12),
              _buildTextField(_authorCtrl, 'Tác giả', required: true),
              const SizedBox(height: 12),

              // Category dropdown
              Text('Thể loại', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: MockBookData.categories
                    .map((c) => DropdownMenuItem(
                        value: c.name, child: Text(c.name)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                      child: _buildTextField(_priceCtrl, 'Giá bán (VNĐ)',
                          isNumber: true, required: true)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildTextField(
                          _originalPriceCtrl, 'Giá gốc (VNĐ)',
                          isNumber: true)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(_stockCtrl, 'Số lượng tồn kho',
                          isNumber: true, required: true)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildTextField(_pageCountCtrl, 'Số trang',
                          isNumber: true)),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(_publisherCtrl, 'Nhà xuất bản'),
              const SizedBox(height: 12),
              _buildTextField(_descCtrl, 'Mô tả tóm tắt sách', maxLines: 3),
              const SizedBox(height: 12),
              _buildTextField(_sampleCtrl, 'Nội dung đọc thử (Chương 1)',
                  maxLines: 4),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _save,
                  icon: Icon(_isEdit ? Icons.save : Icons.add),
                  label: Text(_isEdit ? 'Cập nhật sách' : 'Thêm sách vào kho'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    String? hintText,
    bool required = false,
    bool isNumber = false,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText ?? 'Nhập $label',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: required
              ? (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập $label' : null
              : null,
        ),
      ],
    );
  }
}
