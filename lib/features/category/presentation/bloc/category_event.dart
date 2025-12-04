import 'package:equatable/equatable.dart';

import '../../../vehicle_auction/domain/entities/category.dart';

/// Base class for all category events
abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

/// Load all categories (starts real-time stream)
class LoadCategoriesRequested extends CategoryEvent {
  const LoadCategoriesRequested();
}

/// Internal event for real-time updates from Firestore stream
class CategoriesUpdated extends CategoryEvent {
  final List<Category> categories;

  const CategoriesUpdated(this.categories);

  @override
  List<Object?> get props => [categories];
}

/// Create a new category
class CreateCategoryRequested extends CategoryEvent {
  final String name;
  final String slug;

  const CreateCategoryRequested({
    required this.name,
    required this.slug,
  });

  @override
  List<Object?> get props => [name, slug];
}

/// Update an existing category
class UpdateCategoryRequested extends CategoryEvent {
  final String categoryId;
  final String name;
  final String slug;

  const UpdateCategoryRequested({
    required this.categoryId,
    required this.name,
    required this.slug,
  });

  @override
  List<Object?> get props => [categoryId, name, slug];
}

/// Delete a category
class DeleteCategoryRequested extends CategoryEvent {
  final String categoryId;

  const DeleteCategoryRequested(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Clear any error message
class ClearCategoryError extends CategoryEvent {
  const ClearCategoryError();
}

/// Clear success message
class ClearCategorySuccess extends CategoryEvent {
  const ClearCategorySuccess();
}
