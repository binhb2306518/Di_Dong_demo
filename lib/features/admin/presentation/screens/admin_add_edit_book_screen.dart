import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:ct484project/core/constants/app_colors.dart';
import 'package:ct484project/features/books/data/models/book_model.dart';
import 'package:ct484project/features/books/presentation/bloc/book_cubit.dart';

/// Màn hình Admin – Thêm / Sửa sách – Image Picker thay cho URL ảnh
class AdminAddEditBookScreen extends StatefulWidget {
  final Book? book; // null = thêm mới, not-null = chỉnh sửa
  const AdminAddEditBookScreen({super.key, this.book});

  @override
  State<AdminAddEditBookScreen> createState() => _AdminAddEditBookScreenState();
}

class _AdminAddEditBookScreenState extends State<AdminAddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _titleCtrl;
  late TextEditingController _authorCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _originalPriceCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _publisherCtrl;
  late TextEditingController _pageCountCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _sampleCtrl;
  String _selectedCategory = 'Văn học';
  bool _isLoading = false;

  /// Ảnh bìa chọn từ thiết bị
  File? _coverImageFile;
  /// URL ảnh bìa hiện có (nếu đang sửa)
  String _existingCoverUrl = '';

  bool get _isEdit => widget.book != null;

  static const _categories = [
    'Văn học',
    'Kinh tế',
    'Kỹ năng sống',
    'Công nghệ',
    'Truyện tranh',
    'Thiếu nhi',
    'Lịch sử',
    'Ngoại ngữ',
  ];

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleCtrl = TextEditingController(text: b?.title ?? '');
    _authorCtrl = TextEditingController(text: b?.author ?? '');
    _priceCtrl =
        TextEditingController(text: b != null ? b.price.toInt().toString() : '');
    _originalPriceCtrl = TextEditingController(
        text: b != null ? b.originalPrice.toInt().toString() : '');
    _stockCtrl =
        TextEditingController(text: b != null ? b.stockQuantity.toString() : '10');
    _publisherCtrl = TextEditingController(text: b?.publisher ?? '');
    _pageCountCtrl =
        TextEditingController(text: b != null ? b.pageCount.toString() : '200');
    _descCtrl = TextEditingController(text: b?.description ?? '');
    _sampleCtrl = TextEditingController(text: b?.sampleContent ?? '');
    _selectedCategory = b?.category ?? 'Văn học';
    _existingCoverUrl = b?.coverImage ?? '';

    // Nếu coverImage là file path local
    if (_existingCoverUrl.startsWith('/')) {
      final file = File(_existingCoverUrl);
      if (file.existsSync()) {
        _coverImageFile = file;
      }
    }
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
    _descCtrl.dispose();
    _sampleCtrl.dispose();
    super.dispose();
  }

  /// Chọn ảnh bìa sách từ thư viện hoặc camera
  Future<void> _pickCoverImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Chọn ảnh bìa sách',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded,
                    color: AppColors.primary),
                title: const Text('Chọn từ thư viện ảnh'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded,
                    color: AppColors.secondary),
                title: const Text('Chụp ảnh mới'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 900,
        imageQuality: 85,
      );
      if (picked != null) {
        // Copy ảnh vào thư mục app để lưu trữ lâu dài
        final appDir = await getApplicationDocumentsDirectory();
        final coverDir = Directory(p.join(appDir.path, 'book_covers'));
        if (!coverDir.existsSync()) {
          coverDir.createSync(recursive: true);
        }
        final fileName =
            'cover_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';
        final savedFile = await File(picked.path).copy(
          p.join(coverDir.path, fileName),
        );

        setState(() {
          _coverImageFile = savedFile;
          _existingCoverUrl = savedFile.path;
        });
      }
    }
  }

  /// Xóa ảnh bìa đã chọn
  void _removeCoverImage() {
    setState(() {
      _coverImageFile = null;
      _existingCoverUrl = '';
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final price =
        double.tryParse(_priceCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
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

    // Xác định đường dẫn ảnh bìa
    String coverPath = '';
    if (_coverImageFile != null) {
      coverPath = _coverImageFile!.path; // File local path
    } else if (_existingCoverUrl.isNotEmpty) {
      coverPath = _existingCoverUrl;
    }

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
        coverImage: coverPath,
        description: _descCtrl.text.trim(),
        sampleContent: _sampleCtrl.text.trim(),
      );

      await context.read<BookCubit>().updateBook(updated);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đã cập nhật "${updated.title}" thành công!'),
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
        coverImage: coverPath,
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
            content: Text('✅ Đã thêm "${newBook.title}" vào kho thành công!'),
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
              // ══════════════════════════════════════════
              // ẢNH BÌA – Image Picker (BẮT BUỘC)
              // ══════════════════════════════════════════
              Center(
                child: GestureDetector(
                  onTap: _pickCoverImage,
                  child: Container(
                    width: 140,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildCoverPreview(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Nút chọn / xóa ảnh
              Center(
                child: Wrap(
                  spacing: 10,
                  children: [
                    TextButton.icon(
                      onPressed: _pickCoverImage,
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: Text(_coverImageFile != null || _existingCoverUrl.isNotEmpty
                          ? 'Chọn lại ảnh'
                          : 'Chọn ảnh bìa'),
                    ),
                    if (_coverImageFile != null || _existingCoverUrl.isNotEmpty)
                      TextButton.icon(
                        onPressed: _removeCoverImage,
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: AppColors.error),
                        label: const Text('Xóa ảnh',
                            style: TextStyle(color: AppColors.error)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ══════════════════════════════════════════
              // CÁC TRƯỜNG THÔNG TIN
              // ══════════════════════════════════════════
              _buildTextField(_titleCtrl, 'Tên sách', required: true),
              const SizedBox(height: 12),
              _buildTextField(_authorCtrl, 'Tác giả', required: true),
              const SizedBox(height: 12),

              // Thể loại (Dropdown)
              Text('Thể loại', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _categories.contains(_selectedCategory)
                    ? _selectedCategory
                    : _categories.first,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
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

  /// Widget xem trước ảnh bìa
  Widget _buildCoverPreview() {
    // 1. File local đã chọn
    if (_coverImageFile != null && _coverImageFile!.existsSync()) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(_coverImageFile!, fit: BoxFit.cover),
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, size: 14, color: Colors.white),
            ),
          ),
        ],
      );
    }

    // 2. URL ảnh mạng hiện có (khi sửa)
    if (_existingCoverUrl.isNotEmpty && _existingCoverUrl.startsWith('http')) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: _existingCoverUrl,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => _placeholderWidget(),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, size: 14, color: Colors.white),
            ),
          ),
        ],
      );
    }

    // 3. Đường dẫn file local hiện có (khi sửa)
    if (_existingCoverUrl.isNotEmpty) {
      final file = File(_existingCoverUrl);
      if (file.existsSync()) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.file(file, fit: BoxFit.cover),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 14, color: Colors.white),
              ),
            ),
          ],
        );
      }
    }

    // 4. Placeholder
    return _placeholderWidget();
  }

  Widget _placeholderWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 40, color: AppColors.primary.withValues(alpha: 0.5)),
        const SizedBox(height: 8),
        Text(
          'Bấm để chọn ảnh bìa',
          style: TextStyle(
              fontSize: 12, color: AppColors.primary.withValues(alpha: 0.5)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool isNumber = false,
    int maxLines = 1,
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
          decoration: InputDecoration(
            hintText: 'Nhập $label',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: required
              ? (v) => v == null || v.trim().isEmpty
                  ? 'Vui lòng nhập $label'
                  : null
              : null,
        ),
      ],
    );
  }
}
