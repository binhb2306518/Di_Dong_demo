import 'package:equatable/equatable.dart';

/// Model Thể loại sách
class Category extends Equatable {
  final String id;
  final String name;
  final String icon; // Material icon name hoặc URL

  const Category({
    required this.id,
    required this.name,
    this.icon = '',
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'icon': icon};

  @override
  List<Object?> get props => [id];
}
