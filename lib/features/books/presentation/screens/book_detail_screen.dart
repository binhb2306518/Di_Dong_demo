import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../data/models/book_model.dart';
import '../bloc/wishlist_bloc.dart';
import '../bloc/wishlist_event.dart';
import '../bloc/wishlist_state.dart';
import '../widgets/sample_preview_dialog.dart';

/// Màn hình Chi tiết Sách – Hero animation bìa sách, đọc thử, đánh giá
class BookDetailScreen extends StatefulWidget {
  final String bookId;
  final Book? book;

  const BookDetailScreen({super.key, required this.bookId, this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Book? _book;
  bool _isLoading = true;
  bool _descriptionExpanded = false;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _book = widget.book;
      _isLoading = false;
    } else {
      _loadBook();
    }
  }

  Future<void> _loadBook() async {
    try {
      final b = await DatabaseHelper.instance.getBookById(widget.bookId);
      if (mounted) {
        setState(() {
          _book = b;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final book = _book;
    if (book == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết sách')),
        body: const Center(
          child: Text('Không tìm thấy thông tin cuốn sách này.'),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, book),
          SliverToBoxAdapter(child: _buildBookInfo(context, book)),
          SliverToBoxAdapter(child: _buildDescription(context, book)),
          SliverToBoxAdapter(child: _buildSampleReadButton(context, book)),
          SliverToBoxAdapter(child: _buildReviewSection(context)),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, book),
    );
  }

  // ── Sliver AppBar với Hero Image ──
  Widget _buildSliverAppBar(BuildContext context, Book book) {
    return SliverAppBar(
      expandedHeight: 360,
      pinned: true,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.black38,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      actions: [
        BlocBuilder<WishlistBloc, WishlistState>(
          builder: (context, state) {
            final isFav = state.isFavorite(book.id);
            return CircleAvatar(
              backgroundColor: Colors.black38,
              child: IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.redAccent : Colors.white,
                ),
                onPressed: () {
                  context.read<WishlistBloc>().add(ToggleWishlistBook(book));
                },
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          backgroundColor: Colors.black38,
          child: IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withValues(alpha: 0.8),
                AppColors.primaryDark,
              ],
            ),
          ),
          child: Center(
            child: Hero(
              tag: 'book_cover_${book.id}',
              child: Container(
                height: 240,
                width: 165,
                margin: const EdgeInsets.only(top: 40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: book.coverImage.isNotEmpty
                        ? book.coverImage
                        : 'https://picsum.photos/seed/${book.id}/300/450',
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.book, size: 60),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Thông tin sách ──
  Widget _buildBookInfo(BuildContext context, Book book) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            book.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            book.author,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),

          // Rating row
          Row(
            children: [
              RatingBarIndicator(
                rating: book.rating,
                itemSize: 20,
                itemBuilder: (_, __) =>
                    const Icon(Icons.star_rounded, color: AppColors.starFilled),
              ),
              const SizedBox(width: 8),
              Text(
                '${book.rating}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                ' (${book.reviewCount} đánh giá)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Giá
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(book.price),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (book.discountPercent > 0) ...[
                const SizedBox(width: 10),
                Text(
                  CurrencyFormatter.format(book.originalPrice),
                  style: const TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.discountBadge.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '-${book.discountPercent}%',
                    style: const TextStyle(
                      color: AppColors.discountBadge,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Thông số nhanh
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoItem(icon: Icons.business, label: 'NXB', value: book.publisher),
                _InfoItem(
                    icon: Icons.menu_book,
                    label: 'Số trang',
                    value: '${book.pageCount}'),
                _InfoItem(
                    icon: Icons.calendar_month,
                    label: 'Năm XB',
                    value: '${book.publishYear}'),
                _InfoItem(
                    icon: Icons.inventory_2,
                    label: 'Tồn kho',
                    value: '${book.stockQuantity}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Mô tả sách ──
  Widget _buildDescription(BuildContext context, Book book) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mô tả sách',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          AnimatedCrossFade(
            firstChild: Text(
              book.description.isNotEmpty ? book.description : 'Đang cập nhật mô tả.',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
            secondChild: Text(
              book.description.isNotEmpty ? book.description : 'Đang cập nhật mô tả.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
            crossFadeState: _descriptionExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          TextButton(
            onPressed: () =>
                setState(() => _descriptionExpanded = !_descriptionExpanded),
            child: Text(
              _descriptionExpanded ? 'Thu gọn ▲' : 'Xem thêm ▼',
              style: const TextStyle(color: AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }

  // ── Nút đọc thử ──
  Widget _buildSampleReadButton(BuildContext context, Book book) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: OutlinedButton.icon(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (_) => SamplePreviewDialog(
              title: book.title,
              content: book.sampleContent.isNotEmpty
                  ? book.sampleContent
                  : 'Nội dung đọc thử đang được cập nhật.',
            ),
          );
        },
        icon: const Icon(Icons.auto_stories),
        label: const Text('Đọc thử trích đoạn'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          minimumSize: const Size(double.infinity, 50),
          side: const BorderSide(color: AppColors.secondary, width: 1.5),
          foregroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ── Khu vực đánh giá ──
  Widget _buildReviewSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Đánh giá từ độc giả',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          const _ReviewTile(
            name: 'Nguyễn Văn A',
            rating: 5,
            date: '15/10/2026',
            comment: 'Sách rất hay, nội dung phong phú. Đóng gói cẩn thận, giao hàng nhanh!',
          ),
          const SizedBox(height: 8),
          const _ReviewTile(
            name: 'Trần Thị B',
            rating: 4,
            date: '10/10/2026',
            comment: 'Nội dung tốt, tuy nhiên bìa sách hơi mỏng. Nhìn chung rất đáng đọc.',
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar cố định: Chọn SL + Thêm vào giỏ + Mua ngay ──
  Widget _buildBottomBar(BuildContext context, Book book) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Bộ chọn số lượng
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _QtyButton(
                    icon: Icons.remove,
                    onPressed: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('$_quantity',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  _QtyButton(
                    icon: Icons.add,
                    onPressed: () {
                      if (_quantity < book.stockQuantity || book.stockQuantity == 0) {
                        setState(() => _quantity++);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Thêm vào giỏ
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<CartBloc>().add(AddToCart(CartItem(
                        id: 'cart_${book.id}_${DateTime.now().millisecondsSinceEpoch}',
                        bookId: book.id,
                        title: book.title,
                        price: book.price,
                        imageUrl: book.coverImage,
                        quantity: _quantity,
                        stockQuantity: book.stockQuantity,
                      )));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Đã thêm $_quantity x "${book.title}" vào giỏ'),
                      action: SnackBarAction(
                        label: 'Xem giỏ',
                        onPressed: () => context.push('/cart'),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart, size: 20),
                label: const Text('Thêm giỏ'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Mua ngay
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<CartBloc>().add(AddToCart(CartItem(
                        id: 'cart_${book.id}_${DateTime.now().millisecondsSinceEpoch}',
                        bookId: book.id,
                        title: book.title,
                        price: book.price,
                        imageUrl: book.coverImage,
                        quantity: _quantity,
                        stockQuantity: book.stockQuantity,
                      )));
                  context.push('/checkout');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.secondary,
                ),
                child: const Text('Mua ngay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Widget phụ trợ
// ═══════════════════════════════════════════════════════

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _QtyButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final String name;
  final int rating;
  final String date;
  final String comment;
  const _ReviewTile({
    required this.name,
    required this.rating,
    required this.date,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(name[0],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(date, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              RatingBarIndicator(
                rating: rating.toDouble(),
                itemSize: 14,
                itemBuilder: (_, __) =>
                    const Icon(Icons.star_rounded, color: AppColors.starFilled),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
