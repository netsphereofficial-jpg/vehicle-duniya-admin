import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/staff_member.dart';
import '../../domain/entities/staff_role.dart';
import '../bloc/staff_bloc.dart';
import '../bloc/staff_event.dart';
import '../bloc/staff_state.dart';

/// Dialog for creating or editing a staff member
class StaffFormDialog extends StatefulWidget {
  final StaffMember? staff;

  const StaffFormDialog({super.key, this.staff});

  /// Show the dialog
  static Future<void> show(BuildContext context, {StaffMember? staff}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<StaffBloc>(),
        child: StaffFormDialog(staff: staff),
      ),
    );
  }

  @override
  State<StaffFormDialog> createState() => _StaffFormDialogState();
}

class _StaffFormDialogState extends State<StaffFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  StaffRole? _selectedRole;
  late bool _isActive;

  bool get isEditing => widget.staff != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.staff?.name ?? '');
    _usernameController = TextEditingController(text: widget.staff?.username ?? '');
    _emailController = TextEditingController(text: widget.staff?.email ?? '');
    _phoneController = TextEditingController(
      text: widget.staff?.phone.replaceFirst('+91', '').trim() ?? '',
    );
    _passwordController = TextEditingController();
    _isActive = widget.staff?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a role'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final phone = '+91${_phoneController.text.trim()}';

    if (isEditing) {
      context.read<StaffBloc>().add(UpdateStaffMemberRequested(
            staffId: widget.staff!.id,
            name: _nameController.text.trim(),
            username: _usernameController.text.trim(),
            phone: phone,
            roleId: _selectedRole!.id,
            roleName: _selectedRole!.name,
            isActive: _isActive,
          ));
    } else {
      context.read<StaffBloc>().add(CreateStaffMemberRequested(
            name: _nameController.text.trim(),
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            phone: phone,
            password: _passwordController.text,
            roleId: _selectedRole!.id,
            roleName: _selectedRole!.name,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffBloc, StaffState>(
      listener: (context, state) {
        if (state.hasSuccess) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        // Set initial role selection
        if (_selectedRole == null && widget.staff != null && state.roles.isNotEmpty) {
          _selectedRole = state.getRoleById(widget.staff!.roleId);
        }

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 500,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                          const SizedBox(height: 16),
                          _buildUsernameField(),
                          const SizedBox(height: 16),
                          _buildEmailField(),
                          const SizedBox(height: 16),
                          _buildPhoneField(),
                          if (!isEditing) ...[
                            const SizedBox(height: 16),
                            _buildPasswordField(),
                          ],
                          const SizedBox(height: 16),
                          _buildRoleDropdown(state.roles),
                          if (isEditing) ...[
                            const SizedBox(height: 16),
                            _buildActiveSwitch(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                _buildActions(state),
              ],
            ),
          ),
        );
      },
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
              isEditing ? Icons.edit_outlined : Icons.person_add_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Staff Member' : 'Add Staff Member',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isEditing
                    ? 'Update staff member details'
                    : 'Create a new staff account',
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
    return _buildField(
      label: 'Full Name',
      controller: _nameController,
      hint: 'Enter full name',
      icon: Icons.person_outline,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the name';
        }
        return null;
      },
    );
  }

  Widget _buildUsernameField() {
    return _buildField(
      label: 'Username',
      controller: _usernameController,
      hint: 'Enter username',
      icon: Icons.alternate_email,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a username';
        }
        if (value.contains(' ')) {
          return 'Username cannot contain spaces';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return _buildField(
      label: 'Email',
      controller: _emailController,
      hint: 'Enter email address',
      icon: Icons.email_outlined,
      enabled: !isEditing,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter an email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            hintText: '9876543210',
            prefixIcon: Container(
              width: 80,
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone_outlined, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '+91',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
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
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter phone number';
            }
            if (value.length != 10) {
              return 'Phone number must be 10 digits';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return _buildField(
      label: 'Password',
      controller: _passwordController,
      hint: 'Enter password (min 6 characters)',
      icon: Icons.lock_outline,
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildRoleDropdown(List<StaffRole> roles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<StaffRole>(
          initialValue: _selectedRole,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.security_outlined, color: AppColors.textSecondary),
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
          hint: const Text('Select a role'),
          items: roles.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Row(
                children: [
                  Text(role.name),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${role.permissions.length} permissions',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (role) => setState(() => _selectedRole = role),
          validator: (value) {
            if (value == null) {
              return 'Please select a role';
            }
            return null;
          },
        ),
        if (roles.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'No roles available. Create a role first.',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActiveSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            _isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: _isActive ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Status',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _isActive ? 'Active - Can log in' : 'Inactive - Cannot log in',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
            activeTrackColor: AppColors.success.withValues(alpha: 0.5),
            activeThumbColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool enabled = true,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: enabled ? AppColors.surface : AppColors.background,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildActions(StaffState state) {
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
                : Text(isEditing ? 'Update Staff' : 'Add Staff'),
          ),
        ],
      ),
    );
  }
}
