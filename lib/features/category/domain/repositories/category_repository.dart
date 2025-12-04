import '../../../vehicle_auction/domain/entities/category.dart';

/// Abstract repository for category operations
abstract class CategoryRepository {
  /// Get all categories
  Future<List<Category>> getCategories();

  /// Get category by ID
  Future<Category> getCategoryById(String id);

  /// Create a new category
  Future<Category> createCategory({
    required String name,
    required String slug,
  });

  /// Update an existing category
  Future<void> updateCategory(String id, Map<String, dynamic> updates);

  /// Delete a category
  Future<void> deleteCategory(String id);

  /// Watch categories stream
  Stream<List<Category>> watchCategories();
}
