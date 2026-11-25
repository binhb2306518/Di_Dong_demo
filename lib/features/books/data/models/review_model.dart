import 'package:equatable/equatable.dart';

/// Model Đánh giá & Nhận xét sách
class ReviewModel extends Equatable {
  final String id;
  final String bookId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.bookId,
    required this.userName,
    this.userAvatar = '',
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String? ?? '',
      bookId: json['book_id'] as String? ?? json['bookId'] as String? ?? '',
      userName: json['user_name'] as String? ?? json['userName'] as String? ?? 'Độc giả',
      userAvatar: json['user_avatar'] as String? ?? json['userAvatar'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      comment: json['comment'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'book_id': bookId,
        'user_name': userName,
        'user_avatar': userAvatar,
        'rating': rating,
        'comment': comment,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, bookId, userName, rating, comment, createdAt];
}
