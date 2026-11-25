import 'package:equatable/equatable.dart';

/// Model Sách – entity trung tâm của ứng dụng
class Book extends Equatable {
  final String id;
  final String title;
  final String author;
  final String category;
  final double price;
  final double originalPrice;
  final int discountPercent;
  final double rating;
  final int reviewCount;
  final int stockQuantity;
  final String publisher;
  final int publishYear;
  final int pageCount;
  final String coverImage;
  final String sampleContent;
  final String description;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.price,
    required this.originalPrice,
    this.discountPercent = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.stockQuantity = 0,
    this.publisher = '',
    this.publishYear = 2024,
    this.pageCount = 0,
    this.coverImage = '',
    this.sampleContent = '',
    this.description = '',
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0,
      discountPercent: json['discount_percent'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['review_count'] as int? ?? 0,
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      publisher: json['publisher'] as String? ?? '',
      publishYear: json['publish_year'] as int? ?? 2024,
      pageCount: json['page_count'] as int? ?? 0,
      coverImage: json['cover_image'] as String? ?? '',
      sampleContent: json['sample_content'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'category': category,
      'price': price,
      'original_price': originalPrice,
      'discount_percent': discountPercent,
      'rating': rating,
      'review_count': reviewCount,
      'stock_quantity': stockQuantity,
      'publisher': publisher,
      'publish_year': publishYear,
      'page_count': pageCount,
      'cover_image': coverImage,
      'sample_content': sampleContent,
      'description': description,
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? category,
    double? price,
    double? originalPrice,
    int? discountPercent,
    double? rating,
    int? reviewCount,
    int? stockQuantity,
    String? publisher,
    int? publishYear,
    int? pageCount,
    String? coverImage,
    String? sampleContent,
    String? description,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      category: category ?? this.category,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      publisher: publisher ?? this.publisher,
      publishYear: publishYear ?? this.publishYear,
      pageCount: pageCount ?? this.pageCount,
      coverImage: coverImage ?? this.coverImage,
      sampleContent: sampleContent ?? this.sampleContent,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [id];
}
