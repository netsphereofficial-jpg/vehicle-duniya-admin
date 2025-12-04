import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

/// BLoC for managing category state and operations with real-time updates
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  static const _tag = 'CategoryBloc';
  final CategoryRepository _repository;
  StreamSubscription? _categoriesSubscription;

  CategoryBloc({
    required CategoryRepository repository,
  })  : _repository = repository,
        super(const CategoryState.initial()) {
    on<LoadCategoriesRequested>(_onLoadCategories);
    on<CategoriesUpdated>(_onCategoriesUpdated);
    on<CreateCategoryRequested>(_onCreateCategory);
    on<UpdateCategoryRequested>(_onUpdateCategory);
    on<DeleteCategoryRequested>(_onDeleteCategory);
    on<ClearCategoryError>(_onClearError);
    on<ClearCategorySuccess>(_onClearSuccess);
  }

  Future<void> _onLoadCategories(
    LoadCategoriesRequested event,
    Emitter<CategoryState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'LoadCategoriesRequested');
    emit(state.copyWith(status: CategoryStateStatus.loading));

    try {
      // Cancel existing subscription if any
      await _categoriesSubscription?.cancel();

      // Subscribe to real-time updates
      _categoriesSubscription = _repository.watchCategories().listen(
        (categories) {
          AppLogger.info(_tag, 'Real-time update: ${categories.length} categories');
          add(CategoriesUpdated(categories));
        },
        onError: (error) {
          AppLogger.error(_tag, 'Stream error', error);
          add(ClearCategoryError());
        },
      );
    } catch (e) {
      AppLogger.error(_tag, 'Failed to load categories', e);
      emit(state.copyWith(
        status: CategoryStateStatus.error,
        errorMessage: 'Failed to load categories: ${e.toString()}',
      ));
    }
  }

  void _onCategoriesUpdated(
    CategoriesUpdated event,
    Emitter<CategoryState> emit,
  ) {
    emit(state.copyWith(
      status: CategoryStateStatus.loaded,
      categories: event.categories,
    ));
  }

  Future<void> _onCreateCategory(
    CreateCategoryRequested event,
    Emitter<CategoryState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'CreateCategoryRequested');
    AppLogger.debug(_tag, 'Creating category: ${event.name}');
    emit(state.copyWith(status: CategoryStateStatus.creating));

    try {
      await _repository.createCategory(
        name: event.name,
        slug: event.slug,
      );

      AppLogger.info(_tag, 'Category created successfully');
      emit(state.copyWith(
        status: CategoryStateStatus.created,
        successMessage: 'Category created successfully!',
      ));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to create category', e);
      emit(state.copyWith(
        status: CategoryStateStatus.error,
        errorMessage: 'Failed to create category: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryRequested event,
    Emitter<CategoryState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'UpdateCategoryRequested');
    AppLogger.debug(_tag, 'Updating category: ${event.categoryId}');
    emit(state.copyWith(status: CategoryStateStatus.updating));

    try {
      await _repository.updateCategory(event.categoryId, {
        'name': event.name,
        'slug': event.slug,
      });

      AppLogger.info(_tag, 'Category updated: ${event.categoryId}');
      emit(state.copyWith(
        status: CategoryStateStatus.updated,
        successMessage: 'Category updated successfully!',
      ));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to update category', e);
      emit(state.copyWith(
        status: CategoryStateStatus.error,
        errorMessage: 'Failed to update category: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryRequested event,
    Emitter<CategoryState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'DeleteCategoryRequested');
    AppLogger.warning(_tag, 'Deleting category: ${event.categoryId}');
    emit(state.copyWith(status: CategoryStateStatus.deleting));

    try {
      await _repository.deleteCategory(event.categoryId);

      AppLogger.info(_tag, 'Category deleted: ${event.categoryId}');
      emit(state.copyWith(
        status: CategoryStateStatus.deleted,
        successMessage: 'Category deleted successfully!',
      ));
    } catch (e) {
      AppLogger.error(_tag, 'Failed to delete category', e);
      emit(state.copyWith(
        status: CategoryStateStatus.error,
        errorMessage: 'Failed to delete category: ${e.toString()}',
      ));
    }
  }

  void _onClearError(
    ClearCategoryError event,
    Emitter<CategoryState> emit,
  ) {
    emit(state.copyWith(
      status: CategoryStateStatus.loaded,
      clearError: true,
    ));
  }

  void _onClearSuccess(
    ClearCategorySuccess event,
    Emitter<CategoryState> emit,
  ) {
    emit(state.copyWith(
      clearSuccess: true,
    ));
  }

  @override
  Future<void> close() {
    _categoriesSubscription?.cancel();
    return super.close();
  }
}
