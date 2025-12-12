import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/permissions.dart';
import '../../domain/entities/staff_role.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';
import 'permission_selector.dart';

/// Dialog for creating or editing a role
class RoleFormDialog extends StatefulWidget {
  final StaffRole? role;

  const RoleFormDialog({super.key, this.role});

  /// Show the dialog
  static Future<void> show(BuildContext context, {StaffRole? role}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<StaffBloc>(),
        child: RoleFormDialog(role: role),
      ),
    );
  }

  @override
  State<RoleFormDialog> createState() => _RoleFormDialogState();
}

class _RoleFormDialogState extends State<RoleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late List<AppPermission> _selectedPermissions;

  bool get isEditing => widget.role != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.role?.name ?? '');
    _selectedPermissions = List.from(widget.role?.permissions ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPermissions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one permission'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (isEditing) {
      context.read<StaffBloc>().add(UpdateRoleRequested(
            roleId: widget.role!.id,
            name: _nameController.text.trim(),
            permissions: _selectedPermissions,
          ));
    } else {
      context.read<StaffBloc>().add(CreateRoleRequested(
            name: _nameController.text.trim(),
            permissions: _selectedPermissions,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffBloc, StaffState>(
      listener: (context, state) {
        if (state.hasSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 700,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNameField(),
                        const SizedBox(height: 24),
                        PermissionSelector(
                          selectedPermissions: _selectedPermissions,
                          onChanged: (permissions) {
                            setState(() => _selectedPermissions = permissions);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
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
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Role' : 'Create Role',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isEditing
                    ? 'Update role name and permissions'
                    : 'Define a new role with permissions',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.background,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role Name',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'e.g., Manager, Editor, Viewer',
            prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a role name';
            }
            return null;
          },
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildActions() {
    return BlocBuilder<StaffBloc, StaffState>(
      builder: (context, state) {
        final isSaving = state.isSaving;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              if (state.hasError)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.errorMessage ?? 'An error occurred',
                            style: TextStyle(color: AppColors.error, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!state.hasError) const Spacer(),
              const SizedBox(width: 12),
              TextButton(
                onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: isSaving ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(isEditing ? 'Update Role' : 'Create Role'),
              ),
            ],
          ),
        );
      },
    );
  }
}
