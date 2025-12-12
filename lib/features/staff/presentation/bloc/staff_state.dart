import 'package:equatable/equatable.dart';

import '../../domain/entities/staff_member.dart';
import '../../domain/entities/staff_role.dart';

/// Status for staff operations
enum StaffStatus {
  initial,
  loading,
  loaded,
  saving,
  deleting,
  error,
}

/// State for staff management
class StaffState extends Equatable {
  final StaffStatus status;
  final List<StaffMember> staffMembers;
  final List<StaffRole> roles;
  final String? errorMessage;
  final String? successMessage;

  const StaffState({
    this.status = StaffStatus.initial,
    this.staffMembers = const [],
    this.roles = const [],
    this.errorMessage,
    this.successMessage,
  });

  /// Initial state
  factory StaffState.initial() => const StaffState();

  /// Create a copy with modified fields
  StaffState copyWith({
    StaffStatus? status,
    List<StaffMember>? staffMembers,
    List<StaffRole>? roles,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return StaffState(
      status: status ?? this.status,
      staffMembers: staffMembers ?? this.staffMembers,
      roles: roles ?? this.roles,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  /// Check if data is loaded
  bool get isLoaded => status == StaffStatus.loaded;

  /// Check if currently saving
  bool get isSaving => status == StaffStatus.saving;

  /// Check if currently deleting
  bool get isDeleting => status == StaffStatus.deleting;

  /// Check if there's an error
  bool get hasError => errorMessage != null;

  /// Check if there's a success message
  bool get hasSuccess => successMessage != null;

  /// Get role by ID
  StaffRole? getRoleById(String roleId) {
    try {
      return roles.firstWhere((r) => r.id == roleId);
    } catch (_) {
      return null;
    }
  }

  /// Count staff members with a specific role
  int countStaffWithRole(String roleId) {
    return staffMembers.where((s) => s.roleId == roleId).length;
  }

  @override
  List<Object?> get props => [
        status,
        staffMembers,
        roles,
        errorMessage,
        successMessage,
      ];
}
