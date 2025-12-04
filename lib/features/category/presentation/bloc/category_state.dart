import 'package:equatable/equatable.dart';
import '../../../vehicle_auction/domain/entities/category.dart';

/// Status enum for category operations
enum CategoryStateStatus {
  initial,
  loading,
  loaded,
  creating,
  created,
  updating,
  updated,
  deleting,
  deleted,
  error,
}

/// State class for category bloc
class CategoryState extends Equatable {
  final CategoryStateStatus status;
  final List<Category> categories;
  final String? errorMessage;
  final String? successMessage;
  final String searchQuery;

  const CategoryState({
    this.status = CategoryStateStatus.initial,
    this.categories = const [],
    this.errorMessage,
    this.successMessage,
    this.searchQuery = '',
  });

  /// Initial state
  const CategoryState.initial() : this();

  /// Copy with method for immutable updates
  CategoryState copyWith({
    CategoryStateStatus? status,
    List<Category>? categories,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    String? searchQuery,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Check if currently loading
  bool get isLoading => status == CategoryStateStatus.loading;

  /// Check if currently creating
  bool get isCreating => status == CategoryStateStatus.creating;

  /// Check if currently updating
  bool get isUpdating => status == CategoryStateStatus.updating;

  /// Check if currently deleting
  bool get isDeleting => status == CategoryStateStatus.deleting;

  /// Check if there's an error
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// Check if there's a success message
  bool get hasSuccess => successMessage != null && successMessage!.isNotEmpty;

  /// Get filtered categories based on search query
  List<Category> get filteredCategories {
    if (searchQuery.isEmpty) return categories;
    final query = searchQuery.toLowerCase();
    return categories.where((c) =>
        c.name.toLowerCase().contains(query) ||
        c.slug.toLowerCase().contains(query)).toList();
  }

  /// Total category count
  int get totalCategoryCount => categories.length;

  @override
  List<Object?> get props => [
        status,
        categories,
        errorMessage,
        successMessage,
        searchQuery,
      ];

  @override
  String toString() =>
      'CategoryState(status: $status, categories: ${categories.length})';
}
