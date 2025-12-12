import 'package:equatable/equatable.dart';

import '../../../../core/constants/permissions.dart';

/// Staff role entity with permissions
class StaffRole extends Equatable {
  final String id;
  final String name;
  final List<AppPermission> permissions;
  final bool isSystemRole;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StaffRole({
    required this.id,
    required this.name,
    required this.permissions,
    this.isSystemRole = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if role has a specific permission
  bool hasPermission(AppPermission permission) {
    return permissions.contains(permission);
  }

  /// Check if role has any of the given permissions
  bool hasAnyPermission(List<AppPermission> permissions) {
    return permissions.any((p) => this.permissions.contains(p));
  }

  /// Empty role for initial state
  static StaffRole get empty => StaffRole(
        id: '',
        name: '',
        permissions: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  /// Create a copy with modified fields
  StaffRole copyWith({
    String? id,
    String? name,
    List<AppPermission>? permissions,
    bool? isSystemRole,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StaffRole(
      id: id ?? this.id,
      name: name ?? this.name,
      permissions: permissions ?? this.permissions,
      isSystemRole: isSystemRole ?? this.isSystemRole,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, permissions, isSystemRole, createdAt, updatedAt];
}
