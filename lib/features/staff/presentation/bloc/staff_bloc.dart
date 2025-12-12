import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/staff_member.dart';
import '../../domain/entities/staff_role.dart';
import '../../domain/repositories/staff_repository.dart';
import 'staff_event.dart';
import 'staff_state.dart';

/// BLoC for staff management
/// Uses real-time streams for efficient updates
class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final StaffRepository _repository;

  StreamSubscription<List<StaffMember>>? _staffSubscription;
  StreamSubscription<List<StaffRole>>? _rolesSubscription;

  StaffBloc({required StaffRepository repository})
      : _repository = repository,
        super(StaffState.initial()) {
    on<StaffDataRequested>(_onDataRequested);
    on<StaffMembersStreamUpdated>(_onStaffMembersUpdated);
    on<RolesStreamUpdated>(_onRolesUpdated);
    on<CreateRoleRequested>(_onCreateRole);
    on<UpdateRoleRequested>(_onUpdateRole);
    on<DeleteRoleRequested>(_onDeleteRole);
    on<CreateStaffMemberRequested>(_onCreateStaffMember);
    on<UpdateStaffMemberRequested>(_onUpdateStaffMember);
    on<DeleteStaffMemberRequested>(_onDeleteStaffMember);
    on<ToggleStaffStatusRequested>(_onToggleStaffStatus);
    on<ClearStaffMessage>(_onClearMessage);
  }

  /// Load data and subscribe to real-time updates
  Future<void> _onDataRequested(
    StaffDataRequested event,
    Emitter<StaffState> emit,
  ) async {
    emit(state.copyWith(status: StaffStatus.loading, clearError: true));

    try {
      // Cancel existing subscriptions
      await _staffSubscription?.cancel();
      await _rolesSubscription?.cancel();

      // Subscribe to staff members stream
      _staffSubscription = _repository.watchStaffMembers().listen(
        (members) => add(StaffMembersStreamUpdated(members)),
        onError: (error) => add(const StaffMembersStreamUpdated([])),
      );

      // Subscribe to roles stream
      _rolesSubscription = _repository.watchRoles().listen(
        (roles) => add(RolesStreamUpdated(roles)),
        onError: (error) => add(const RolesStreamUpdated([])),
      );

      // Initial data will come through streams
      emit(state.copyWith(status: StaffStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: StaffStatus.error,
        errorMessage: 'Failed to load staff data: ${e.toString()}',
      ));
    }
  }

  void _onStaffMembersUpdated(
    StaffMembersStreamUpdated event,
    Emitter<StaffState> emit,
  ) {
    emit(state.copyWith(
      staffMembers: event.members.cast<StaffMember>(),
      status: StaffStatus.loaded,
    ));
  }

  void _onRolesUpdated(
    RolesStreamUpdated event,
    Emitter<StaffState> emit,
  ) {
    emit(state.copyWith(
      roles: event.roles.cast<StaffRole>(),
      status: StaffStatus.loaded,
    ));
  }

  // ============ ROLE OPERATIONS ============

  Future<void> _onCreateRole(
    CreateRoleRequested event,
    Emitter<StaffState> emit,
  ) async {
    emit(state.copyWith(status: StaffStatus.saving, clearError: true, clearSuccess: true));

    try {
      await _repository.createRole(
        name: event.name,
        permissions: event.permissions,
      );

      emit(state.copyWith(
        status: StaffStatus.loaded,
        successMessage: 'Role "${event.name}" created successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StaffStatus.error,
        errorMessage: 'Failed to create role: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateRole(
    UpdateRoleRequested event,
    Emitter<StaffState> emit,
  ) async {
    emit(state.copyWith(status: StaffStatus.saving, clearError: true, clearSuccess: true));

    try {
      await _repository.updateRole(
        roleId: event.roleId,
        name: event.name,
        permissions: event.permissions,
      );

      emit(state.copyWith(
        status: StaffStatus.loaded,
        successMessage: 'Role "${event.name}" updated successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StaffStatus.error,
        errorMessage: 'Failed to update role: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteRole(
    DeleteRoleRequested event,
    Emitter<StaffState> emit,
  ) async {
    emit(state.copyWith(status: StaffStatus.deleting, clearError: true, clearSuccess: true));

    try {
      await _repository.deleteRole(event.roleId);

      emit(state.copyWith(
        status: StaffStatus.loaded,
        successMessage: 'Role deleted successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StaffStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  // ============ STAFF MEMBER OPERATIONS ============

  Future<void> _onCreateStaffMember(
    CreateStaffMemberRequested event,
    Emitter<StaffState> emit,
  ) async {
    emit(state.copyWith(status: StaffStatus.saving, clearError: true, clearSuccess: true));

    try {
      await _repository.createStaffMember(
        name: event.name,
        username: event.username,
        email: event.email,
        phone: event.phone,
        password: event.password,
        roleId: event.roleId,
        roleName: event.roleName,
      );

      emit(state.copyWith(
        status: StaffStatus.loaded,
        successMessage: 'Staff member "${event.name}" created successfully',
      ));
    } catch (e) {
      String errorMessage = e.toString();

      // Handle Firebase Auth errors
      if (errorMessage.contains('email-already-in-use')) {
        errorMessage = 'This email is already registered';
      } else if (errorMessage.contains('weak-password')) {
        errorMessage = 'Password is too weak';
      } else if (errorMessage.contains('invalid-email')) {
        errorMessage = 'Invalid email format';
      }

      emit(state.copyWith(
        status: StaffStatus.error,
        errorMessage: errorMessage,
      ));
    }
  }

  Future<void> _onUpdateStaffMember(
    UpdateStaffMemberRequested event,
    Emitter<StaffState> emit,
  ) async {
    emit(state.copyWith(status: StaffStatus.saving, clearError: true, clearSuccess: true));

    try {
      await _repository.updateStaffMember(
        staffId: event.staffId,
        name: event.name,
        username: event.username,
        phone: event.phone,
        roleId: event.roleId,
        roleName: event.roleName,
        isActive: event.isActive,
      );

      emit(state.copyWith(
        status: StaffStatus.loaded,
        successMessage: 'Staff member updated successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StaffStatus.error,
        errorMessage: 'Failed to update staff member: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteStaffMember(
    DeleteStaffMemberRequested event,
    Emitter<StaffState> emit,
  ) async {
    emit(state.copyWith(status: StaffStatus.deleting, clearError: true, clearSuccess: true));

    try {
      await _repository.deleteStaffMember(event.staffId);

      emit(state.copyWith(
        status: StaffStatus.loaded,
        successMessage: 'Staff member deleted successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StaffStatus.error,
        errorMessage: 'Failed to delete staff member: ${e.toString()}',
      ));
    }
  }

  Future<void> _onToggleStaffStatus(
    ToggleStaffStatusRequested event,
    Emitter<StaffState> emit,
  ) async {
    try {
      await _repository.toggleStaffStatus(event.staffId, event.isActive);

      emit(state.copyWith(
        successMessage: event.isActive
            ? 'Staff member activated'
            : 'Staff member deactivated',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StaffStatus.error,
        errorMessage: 'Failed to update status: ${e.toString()}',
      ));
    }
  }

  void _onClearMessage(
    ClearStaffMessage event,
    Emitter<StaffState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  @override
  Future<void> close() async {
    await _staffSubscription?.cancel();
    await _rolesSubscription?.cancel();
    return super.close();
  }
}
