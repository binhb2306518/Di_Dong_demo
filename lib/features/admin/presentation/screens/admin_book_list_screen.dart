import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../books/data/models/book_model.dart';
import '../../../books/presentation/bloc/book_cubit.dart';

/// Màn hình Admin – Quản lý danh mục sách với CRUD hoàn chỉnh
class AdminBookListScreen extends StatelessWidget {
  const AdminBookListScreen({super.key});

  void _confirmDelete(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa sách?'),
        content: Text('Bạn có chắc muốn xóa "${book.title}" khỏi cơ sở dữ liệu?'),
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
                    content: Text('Đã xóa "${book.title}" khỏi kho thành công!'),
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
        title: const Text('Quản lý kho sách (Admin)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
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
      body: BlocBuilder<BookCubit, BookState>(
        builder: (context, state) {
          if (state.status == BookStatus.loading && state.books.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = state.books;

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
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.library_books_outlined,
                        size: 40,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Kho sách hiện đang trống',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Hãy bấm nút "Thêm sách mới" bên dưới để nhập cuốn sách đầu tiên vào hệ thống.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/admin/books/edit'),
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm sách ngay'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<BookCubit>().loadBooks(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: books.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final book = books[index];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: book.coverImage.isNotEmpty
                              ? book.coverImage
                              : 'https://picsum.photos/seed/${book.id}/300/450',
                          width: 55,
                          height: 75,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 55,
                            height: 75,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.book, size: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(book.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text('${book.author} · ${book.category}',
                                style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(CurrencyFormatter.format(book.price),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    )),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: book.stockQuantity > 0
                                        ? AppColors.success
                                            .withValues(alpha: 0.1)
                                        : AppColors.error
                                            .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Kho: ${book.stockQuantity}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: book.stockQuantity > 0
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () => context.push(
                              '/admin/books/edit',
                              extra: book,
                            ),
                            icon: const Icon(Icons.edit_outlined,
                                size: 20, color: AppColors.primary),
                            tooltip: 'Chỉnh sửa',
                          ),
                          IconButton(
                            onPressed: () => _confirmDelete(context, book),
                            icon: const Icon(Icons.delete_outline,
                                size: 20, color: AppColors.error),
                            tooltip: 'Xóa sách',
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/books/edit'),
        icon: const Icon(Icons.add),
        label: const Text('Thêm sách mới'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
