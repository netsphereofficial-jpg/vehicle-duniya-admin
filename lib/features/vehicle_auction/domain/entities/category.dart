import 'package:equatable/equatable.dart';

/// Category entity for vehicle auction categories
class Category extends Equatable {
  final String id;
  final String name;
  final String slug;
  final bool isActive;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.isActive = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, slug, isActive, createdAt];

  @override
  String toString() => 'Category(id: $id, name: $name)';
}
