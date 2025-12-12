import '../../../../core/constants/permissions.dart';
import '../entities/staff_member.dart';
import '../entities/staff_role.dart';

/// Repository interface for staff and role management
abstract class StaffRepository {
  // ============ ROLES ============

  /// Get all roles
  Future<List<StaffRole>> getRoles();

  /// Watch roles for real-time updates
  Stream<List<StaffRole>> watchRoles();

  /// Get role by ID
  Future<StaffRole?> getRoleById(String roleId);

  /// Create a new role
  Future<StaffRole> createRole({
    required String name,
    required List<AppPermission> permissions,
  });

  /// Update an existing role
  Future<void> updateRole({
    required String roleId,
    required String name,
    required List<AppPermission> permissions,
  });

  /// Delete a role
  /// Throws exception if staff members are assigned
  Future<void> deleteRole(String roleId);

  /// Count staff members with a specific role
  Future<int> countStaffWithRole(String roleId);

  // ============ STAFF MEMBERS ============

  /// Get all staff members
  Future<List<StaffMember>> getStaffMembers();

  /// Watch staff members for real-time updates
  Stream<List<StaffMember>> watchStaffMembers();

  /// Get staff member by ID
  Future<StaffMember?> getStaffMemberById(String staffId);

  /// Get staff member by email
  Future<StaffMember?> getStaffMemberByEmail(String email);

  /// Create a new staff member with Firebase Auth account
  Future<StaffMember> createStaffMember({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String password,
    required String roleId,
    required String roleName,
  });

  /// Update staff member details (except password)
  Future<void> updateStaffMember({
    required String staffId,
    required String name,
    required String username,
    required String phone,
    required String roleId,
    required String roleName,
    required bool isActive,
  });

  /// Update staff member password
  Future<void> updateStaffPassword({
    required String staffId,
    required String newPassword,
  });

  /// Delete staff member (also deletes Firebase Auth account)
  Future<void> deleteStaffMember(String staffId);

  /// Toggle staff member active status
  Future<void> toggleStaffStatus(String staffId, bool isActive);

  // ============ PERMISSIONS ============

  /// Get permissions for a staff member by their ID
  /// Returns null if not found (indicates super admin)
  Future<List<AppPermission>?> getStaffPermissions(String staffId);

  /// Check if current user is super admin (not in staff_members)
  Future<bool> isSuperAdmin(String userId);

  /// Update last login time for staff member
  Future<void> updateLastLogin(String staffId);
}
