import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:ct484project/core/constants/app_colors.dart';
import 'package:ct484project/core/utils/currency_formatter.dart';
import 'package:ct484project/features/books/data/models/book_model.dart';
import 'package:ct484project/features/books/presentation/bloc/book_cubit.dart';

/// Tab Quản lý Sách – Thanh tìm kiếm, bộ lọc thể loại, danh sách Card + Switch trạng thái
class AdminBookListScreen extends StatefulWidget {
  const AdminBookListScreen({super.key});

  @override
  State<AdminBookListScreen> createState() => _AdminBookListScreenState();
}

class _AdminBookListScreenState extends State<AdminBookListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'Tất cả';
  final Set<String> _hiddenBookIds = {}; // Quản lý trạng thái hiển thị (switch)

  static const _filterCategories = [
    'Tất cả',
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
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Book> _filterBooks(List<Book> books) {
    var filtered = books;

    // Lọc theo thể loại
    if (_selectedCategory != 'Tất cả') {
      filtered = filtered.where((b) => b.category == _selectedCategory).toList();
    }

    // Tìm kiếm theo tên sách
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((b) =>
              b.title.toLowerCase().contains(query) ||
              b.author.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }

  void _confirmDelete(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa sách?'),
        content: Text('Bạn có chắc muốn xóa "${book.title}" khỏi kho?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<BookCubit>().deleteBook(book.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa "${book.title}" thành công!'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Quản lý sách'),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          BlocBuilder<BookCubit, BookState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Chip(
                  label: Text('${state.books.length} sách',
                      style: const TextStyle(fontSize: 12)),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Thanh tìm kiếm ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Tìm theo tên sách, tác giả...',
                prefixIcon: const Icon(Icons.search, size: 22),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear, size: 20),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),

          // ── Bộ lọc ngang theo thể loại ──
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filterCategories.length,
              itemBuilder: (context, index) {
                final cat = _filterCategories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = cat);
                    },
                    selectedColor: AppColors.secondary.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.secondary,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),

          // ── Danh sách sách ──
          Expanded(
            child: BlocBuilder<BookCubit, BookState>(
              builder: (context, state) {
                if (state.status == BookStatus.loading && state.books.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final books = _filterBooks(state.books);

                if (books.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.secondary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.library_books_outlined,
                              size: 40,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchCtrl.text.isNotEmpty
                                ? 'Không tìm thấy sách phù hợp'
                                : 'Kho sách đang trống',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _searchCtrl.text.isNotEmpty
                                ? 'Thử tìm kiếm với từ khóa khác'
                                : 'Bấm nút (+) để thêm sách mới',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => context.read<BookCubit>().loadBooks(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 100),
                    itemCount: books.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final book = books[index];
                      final isVisible = !_hiddenBookIds.contains(book.id);

                      return GestureDetector(
                        onTap: () => context.push('/admin/books/edit', extra: book),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Ảnh bìa sách
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _buildBookImage(book),
                              ),
                              const SizedBox(width: 12),

                              // Thông tin sách
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${book.author} · ${book.category}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          CurrencyFormatter.format(book.price),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                        const Spacer(),
                                        // Badge tồn kho
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: book.stockQuantity > 5
                                                ? AppColors.success
                                                    .withValues(alpha: 0.1)
                                                : book.stockQuantity > 0
                                                    ? AppColors.warning
                                                        .withValues(alpha: 0.1)
                                                    : AppColors.error
                                                        .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Kho: ${book.stockQuantity}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: book.stockQuantity > 5
                                                  ? AppColors.success
                                                  : book.stockQuantity > 0
                                                      ? AppColors.warning
                                                      : AppColors.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    // Switch hiển thị + nút xóa
                                    Row(
                                      children: [
                                        const Text('Hiển thị',
                                            style: TextStyle(fontSize: 11)),
                                        const SizedBox(width: 4),
                                        SizedBox(
                                          height: 24,
                                          child: Switch(
                                            value: isVisible,
                                            onChanged: (v) {
                                              setState(() {
                                                if (v) {
                                                  _hiddenBookIds
                                                      .remove(book.id);
                                                } else {
                                                  _hiddenBookIds.add(book.id);
                                                }
                                              });
                                            },
                                            activeColor: AppColors.success,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                        ),
                                        const Spacer(),
                                        // Nút sửa
                                        IconButton(
                                          onPressed: () => context.push(
                                            '/admin/books/edit',
                                            extra: book,
                                          ),
                                          icon: const Icon(Icons.edit_outlined,
                                              size: 18,
                                              color: AppColors.primary),
                                          tooltip: 'Sửa',
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(6),
                                        ),
                                        const SizedBox(width: 4),
                                        // Nút xóa
                                        IconButton(
                                          onPressed: () =>
                                              _confirmDelete(context, book),
                                          icon: const Icon(
                                              Icons.delete_outline,
                                              size: 18,
                                              color: AppColors.error),
                                          tooltip: 'Xóa',
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(6),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ── FAB Thêm sách mới ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/books/edit'),
        icon: const Icon(Icons.add),
        label: const Text('Thêm sách mới'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Hiển thị ảnh sách – hỗ trợ cả file local và URL
  Widget _buildBookImage(Book book) {
    final img = book.coverImage;
    if (img.isNotEmpty && !img.startsWith('http')) {
      // Ảnh local (file path từ ImagePicker)
      final file = File(img);
      if (file.existsSync()) {
        return Image.file(file, width: 60, height: 80, fit: BoxFit.cover);
      }
    }
    // Ảnh URL hoặc placeholder
    return CachedNetworkImage(
      imageUrl: img.isNotEmpty
          ? img
          : 'https://picsum.photos/seed/${book.id}/300/450',
      width: 60,
      height: 80,
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) => Container(
        width: 60,
        height: 80,
        color: Colors.grey.shade200,
        child: const Icon(Icons.book, size: 24),
      ),
    );
  }
}
