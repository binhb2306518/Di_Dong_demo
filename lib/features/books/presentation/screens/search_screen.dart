import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/mock_book_data.dart';
import '../../data/models/book_model.dart';

/// Màn hình Tìm kiếm & Bộ lọc nâng cao – kết nối SQLite Search History
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _selectedCategory = 'Tất cả';
  RangeValues _priceRange = const RangeValues(0, 500000);
  String _sortBy = 'Mặc định';
  List<Book> _allBooks = [];
  List<Book> _results = [];
  List<String> _history = [];
  bool _showFilters = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooksAndHistory();
  }

  Future<void> _loadBooksAndHistory() async {
    try {
      final books = await DatabaseHelper.instance.getAllBooks();
      final history = await DatabaseHelper.instance.getSearchHistory();
      if (mounted) {
        setState(() {
          _allBooks = books;
          _results = books;
          _history = history;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadHistory() async {
    try {
      final list = await DatabaseHelper.instance.getSearchHistory();
      if (mounted) setState(() => _history = list);
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _performSearch();
    });
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      DatabaseHelper.instance.addSearchQuery(query).then((_) => _loadHistory());
    }

    setState(() {
      _results = _allBooks.where((book) {
        final matchesQuery = query.isEmpty ||
            book.title.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query);
        final matchesCategory = _selectedCategory == 'Tất cả' ||
            book.category == _selectedCategory;
        final matchesPrice =
            book.price >= _priceRange.start && book.price <= _priceRange.end;
        return matchesQuery && matchesCategory && matchesPrice;
      }).toList();

      // Sort
      if (_sortBy == 'Giá tăng') {
        _results.sort((a, b) => a.price.compareTo(b.price));
      } else if (_sortBy == 'Giá giảm') {
        _results.sort((a, b) => b.price.compareTo(a.price));
      } else if (_sortBy == 'Đánh giá') {
        _results.sort((a, b) => b.rating.compareTo(a.rating));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm sách'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tựa sách, tác giả...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                _performSearch();
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  icon: Icon(
                    _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                    color: _showFilters ? AppColors.primary : null,
                  ),
                  onPressed: () =>
                      setState(() => _showFilters = !_showFilters),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Lịch sử tìm kiếm gần đây ──
          if (_searchController.text.isEmpty && _history.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lịch sử tìm kiếm',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await DatabaseHelper.instance.clearSearchHistory();
                          _loadHistory();
                        },
                        child: const Text('Xóa',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.error)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: _history
                        .take(6)
                        .map(
                          (q) => ActionChip(
                            label: Text(q,
                                style: const TextStyle(fontSize: 12)),
                            avatar: const Icon(Icons.history, size: 14),
                            onPressed: () {
                              _searchController.text = q;
                              _performSearch();
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),

          // ── Bộ lọc mở rộng ──
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _showFilters
                ? _buildFilterPanel(context)
                : const SizedBox.shrink(),
          ),

          // ── Số lượng kết quả ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tìm thấy ${_results.length} kết quả',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _allBooks.isEmpty
                                  ? Icons.menu_book_outlined
                                  : Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _allBooks.isEmpty
                                  ? 'Chưa có sản phẩm nào'
                                  : 'Không tìm thấy sách phù hợp',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_allBooks.isEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Kho sách chưa có sản phẩm nào từ trang Admin.',
                                style: TextStyle(
                                    color: Colors.grey.shade500, fontSize: 13),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _SearchResultTile(book: _results[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thể loại
          Text('Thể loại', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Tất cả', ...MockBookData.categories.map((c) => c.name)]
                  .map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(cat, style: const TextStyle(fontSize: 12)),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedCategory = cat);
                      _performSearch();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Khoảng giá
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Khoảng giá', style: Theme.of(context).textTheme.titleSmall),
              Text(
                '${CurrencyFormatter.format(_priceRange.start)} - ${CurrencyFormatter.format(_priceRange.end)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 500000,
            divisions: 20,
            onChanged: (vals) {
              setState(() => _priceRange = vals);
              _performSearch();
            },
          ),
          const SizedBox(height: 6),

          // Sắp xếp
          Row(
            children: [
              Text('Sắp xếp: ', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(width: 8),
              ...['Mặc định', 'Giá tăng', 'Giá giảm', 'Đánh giá'].map((sort) {
                final isSelected = _sortBy == sort;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(sort, style: const TextStyle(fontSize: 11)),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        setState(() => _sortBy = sort);
                        _performSearch();
                      }
                    },
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Search Result Tile
// ═══════════════════════════════════════════════════════

class _SearchResultTile extends StatelessWidget {
  final Book book;
  const _SearchResultTile({required this.book});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/book/${book.id}', extra: book),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh bìa
            Hero(
              tag: 'book_cover_${book.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: book.coverImage,
                  width: 70,
                  height: 100,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => Container(
                    width: 70,
                    height: 100,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.book),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      book.category,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyFormatter.format(book.price),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppColors.starFilled),
                          Text(
                            ' ${book.rating}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
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
  }
}
