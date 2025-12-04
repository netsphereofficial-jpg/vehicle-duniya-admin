import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/action_buttons.dart';
import '../../../../core/widgets/modern_data_table.dart';
import '../../../vehicle_auction/domain/entities/category.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.errorMessage!)),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              margin: const EdgeInsets.all(16),
            ),
          );
          context.read<CategoryBloc>().add(const ClearCategoryError());
        }
        if (state.hasSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.successMessage!)),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              margin: const EdgeInsets.all(16),
            ),
          );
          context.read<CategoryBloc>().add(const ClearCategorySuccess());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context),
                const SizedBox(height: 24),

                // Categories Table Card
                Expanded(
                  child: _buildCategoriesCard(context, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryLight,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.category,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category Management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage vehicle and property categories',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        // Add Category Button
        _AddCategoryButton(
          onPressed: () => _showCategoryDialog(context),
        ),
      ],
    );
  }

  Widget _buildCategoriesCard(BuildContext context, CategoryState state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ModernDataTable<Category>(
        data: state.categories,
        isLoading: state.isLoading,
        emptyMessage: 'No categories found',
        emptyIcon: Icons.category_outlined,
        searchHint: 'Search categories...',
        searchableText: (category) => '${category.name} ${category.slug}',
        columns: [
          TableColumnDef<Category>(
            header: 'S.No',
            width: 80,
            align: TextAlign.center,
            cellBuilder: (item, index) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          TableColumnDef<Category>(
            header: 'Category Name',
            flex: 2,
            cellBuilder: (item, index) => Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.label_outline,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          TableColumnDef<Category>(
            header: 'Category Slug',
            flex: 2,
            cellBuilder: (item, index) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
              ),
              child: Text(
                item.slug,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.info,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          TableColumnDef<Category>(
            header: 'Status',
            width: 100,
            align: TextAlign.center,
            cellBuilder: (item, index) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: item.isActive
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: item.isActive ? AppColors.success : AppColors.error,
                ),
              ),
            ),
          ),
          TableColumnDef<Category>(
            header: 'Actions',
            width: 120,
            align: TextAlign.center,
            cellBuilder: (item, index) => ActionButtonsRow(
              onEdit: () => _showCategoryDialog(context, category: item),
              onDelete: () => _showDeleteConfirmation(context, item),
              isLoading: state.isUpdating || state.isDeleting,
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {Category? category}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final slugController = TextEditingController(text: category?.slug ?? '');
    final formKey = GlobalKey<FormState>();
    final categoryBloc = context.read<CategoryBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: categoryBloc,
          child: BlocBuilder<CategoryBloc, CategoryState>(
            builder: (blocContext, state) {
              final isProcessing = state.isCreating || state.isUpdating;

              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  width: 480,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isEditing ? Icons.edit_outlined : Icons.add_circle_outline,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEditing ? 'Edit Category' : 'Add New Category',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  isEditing
                                      ? 'Update category details'
                                      : 'Create a new category',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: const Icon(Icons.close),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.background,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Form
                      Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display Name
                            Text(
                              'Category Display Name',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                hintText: 'e.g., Property Auction',
                                prefixIcon: Icon(Icons.label_outline, color: AppColors.textSecondary),
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.error),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Category name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Slug
                            Text(
                              'Category Slug',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: slugController,
                              decoration: InputDecoration(
                                hintText: 'e.g., property-auction',
                                prefixIcon: Icon(Icons.link, color: AppColors.textSecondary),
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.error),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Category slug is required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: isProcessing
                                  ? null
                                  : () {
                                      if (formKey.currentState!.validate()) {
                                        if (isEditing) {
                                          categoryBloc.add(
                                            UpdateCategoryRequested(
                                              categoryId: category.id,
                                              name: nameController.text.trim(),
                                              slug: slugController.text.trim(),
                                            ),
                                          );
                                        } else {
                                          categoryBloc.add(
                                            CreateCategoryRequested(
                                              name: nameController.text.trim(),
                                              slug: slugController.text.trim(),
                                            ),
                                          );
                                        }
                                        Navigator.pop(dialogContext);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: isProcessing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(isEditing ? Icons.save_outlined : Icons.add, size: 20),
                                        const SizedBox(width: 8),
                                        Text(isEditing ? 'Update Category' : 'Create Category'),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Category category) {
    final categoryBloc = context.read<CategoryBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: categoryBloc,
          child: BlocBuilder<CategoryBloc, CategoryState>(
            builder: (blocContext, state) {
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Warning Icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      const Text(
                        'Delete Category?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Message
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(text: 'Are you sure you want to delete '),
                            TextSpan(
                              text: '"${category.name}"',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const TextSpan(text: '?\n\nThis action cannot be undone.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: state.isDeleting
                                  ? null
                                  : () {
                                      categoryBloc.add(DeleteCategoryRequested(category.id));
                                      Navigator.pop(dialogContext);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: state.isDeleting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.delete_outline, size: 20),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Add Category Button with gradient and hover effect
class _AddCategoryButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AddCategoryButton({required this.onPressed});

  @override
  State<_AddCategoryButton> createState() => _AddCategoryButtonState();
}

class _AddCategoryButtonState extends State<_AddCategoryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton.icon(
          onPressed: widget.onPressed,
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Add Category'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: _isHovered ? 4 : 0,
            shadowColor: AppColors.primary.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
