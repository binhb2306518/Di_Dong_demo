import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../bloc/wishlist_bloc.dart';
import '../bloc/wishlist_event.dart';
import '../bloc/wishlist_state.dart';

/// Màn hình Sách Yêu Thích (Wishlist) – kết nối WishlistBloc & SQLite
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WishlistBloc, WishlistState>(
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      builder: (context, state) {
        final items = state.items;

        return Scaffold(
          appBar: AppBar(
            title: Text('Sách Yêu Thích (${items.length}) ❤️'),
          ),
          body: state.status == WishlistStatus.loading && items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite_border,
                              size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có sách yêu thích nào',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context.go('/home'),
                            child: const Text('Khám phá ngay'),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final bookId =
                            (item['book_id'] ?? item['id']) as String;
                        final title = (item['title'] ?? '') as String;
                        final author = (item['author'] ?? '') as String;
                        final price =
                            (item['price'] as num?)?.toDouble() ?? 0.0;
                        final imageUrl =
                            (item['image_url'] ?? item['coverImage'] ?? '')
                                as String;
                        final rating =
                            (item['rating'] as num?)?.toDouble() ?? 5.0;

                        return Dismissible(
                          key: Key(bookId),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.delete_outline,
                                color: AppColors.error, size: 28),
                          ),
                          onDismissed: (_) {
                            context
                                .read<WishlistBloc>()
                                .add(RemoveFromWishlistBook(bookId));
                          },
                          child: InkWell(
                            onTap: () => context.push('/book/$bookId'),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
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
                                      imageUrl: imageUrl,
                                      width: 65,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Container(
                                        width: 65,
                                        height: 90,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.book),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          author,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.star_rounded,
                                                size: 14,
                                                color: AppColors.starFilled),
                                            Text(
                                              ' $rating',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          CurrencyFormatter.format(price),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        tooltip: 'Xóa khỏi yêu thích',
                                        onPressed: () {
                                          context
                                              .read<WishlistBloc>()
                                              .add(RemoveFromWishlistBook(bookId));
                                        },
                                        icon: const Icon(Icons.favorite,
                                            color: AppColors.error),
                                      ),
                                      IconButton(
                                        tooltip: 'Thêm vào giỏ',
                                        onPressed: () {
                                          context.read<CartBloc>().add(
                                                AddToCart(
                                                  CartItem(
                                                    id: 'cart_${bookId}_${DateTime.now().millisecondsSinceEpoch}',
                                                    bookId: bookId,
                                                    title: title,
                                                    price: price,
                                                    imageUrl: imageUrl,
                                                    quantity: 1,
                                                    stockQuantity: 50,
                                                  ),
                                                ),
                                              );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Đã thêm "$title" vào giỏ hàng'),
                                              action: SnackBarAction(
                                                label: 'Xem giỏ',
                                                onPressed: () =>
                                                    context.push('/cart'),
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                            Icons.add_shopping_cart,
                                            size: 20),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
