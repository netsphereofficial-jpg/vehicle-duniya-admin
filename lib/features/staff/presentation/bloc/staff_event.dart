import 'package:equatable/equatable.dart';

import '../../../../core/constants/permissions.dart';

/// Base event for staff management
sealed class StaffEvent extends Equatable {
  const StaffEvent();

  @override
  List<Object?> get props => [];
}

/// Load all staff and roles data
class StaffDataRequested extends StaffEvent {
  const StaffDataRequested();
}

/// Subscription update events (internal use via BLoC only)
class StaffMembersStreamUpdated extends StaffEvent {
  final List<dynamic> members;
  const StaffMembersStreamUpdated(this.members);

  @override
  List<Object?> get props => [members];
}

class RolesStreamUpdated extends StaffEvent {
  final List<dynamic> roles;
  const RolesStreamUpdated(this.roles);

  @override
  List<Object?> get props => [roles];
}

// ============ ROLE EVENTS ============

/// Create a new role
class CreateRoleRequested extends StaffEvent {
  final String name;
  final List<AppPermission> permissions;

  const CreateRoleRequested({
    required this.name,
    required this.permissions,
  });

  @override
  List<Object?> get props => [name, permissions];
}

/// Update an existing role
class UpdateRoleRequested extends StaffEvent {
  final String roleId;
  final String name;
  final List<AppPermission> permissions;

  const UpdateRoleRequested({
    required this.roleId,
    required this.name,
    required this.permissions,
  });

  @override
  List<Object?> get props => [roleId, name, permissions];
}

/// Delete a role
class DeleteRoleRequested extends StaffEvent {
  final String roleId;

  const DeleteRoleRequested(this.roleId);

  @override
  List<Object?> get props => [roleId];
}

// ============ STAFF MEMBER EVENTS ============

/// Create a new staff member
class CreateStaffMemberRequested extends StaffEvent {
  final String name;
  final String username;
  final String email;
  final String phone;
  final String password;
  final String roleId;
  final String roleName;

  const CreateStaffMemberRequested({
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
    required this.roleId,
    required this.roleName,
  });

  @override
  List<Object?> get props => [name, username, email, phone, password, roleId, roleName];
}

/// Update staff member details
class UpdateStaffMemberRequested extends StaffEvent {
  final String staffId;
  final String name;
  final String username;
  final String phone;
  final String roleId;
  final String roleName;
  final bool isActive;

  const UpdateStaffMemberRequested({
    required this.staffId,
    required this.name,
    required this.username,
    required this.phone,
    required this.roleId,
    required this.roleName,
    required this.isActive,
  });

  @override
  List<Object?> get props => [staffId, name, username, phone, roleId, roleName, isActive];
}

/// Delete a staff member
class DeleteStaffMemberRequested extends StaffEvent {
  final String staffId;

  const DeleteStaffMemberRequested(this.staffId);

  @override
  List<Object?> get props => [staffId];
}

/// Toggle staff member active status
class ToggleStaffStatusRequested extends StaffEvent {
  final String staffId;
  final bool isActive;

  const ToggleStaffStatusRequested({
    required this.staffId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [staffId, isActive];
}

/// Clear any error or success messages
class ClearStaffMessage extends StaffEvent {
  const ClearStaffMessage();
}
