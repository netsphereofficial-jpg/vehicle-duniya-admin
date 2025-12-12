import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/permissions.dart';
import '../../domain/entities/staff_role.dart';

/// Firestore model for StaffRole
class StaffRoleModel extends StaffRole {
  const StaffRoleModel({
    required super.id,
    required super.name,
    required super.permissions,
    super.isSystemRole,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from Firestore document
  factory StaffRoleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Convert permission strings to enum values
    final permissionStrings = List<String>.from(data['permissions'] ?? []);
    final permissions = permissionStrings
        .map((name) => _permissionFromString(name))
        .whereType<AppPermission>()
        .toList();

    return StaffRoleModel(
      id: doc.id,
      name: data['name'] ?? '',
      permissions: permissions,
      isSystemRole: data['isSystemRole'] ?? false,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
    );
  }

  /// Create from entity
  factory StaffRoleModel.fromEntity(StaffRole role) {
    return StaffRoleModel(
      id: role.id,
      name: role.name,
      permissions: role.permissions,
      isSystemRole: role.isSystemRole,
      createdAt: role.createdAt,
      updatedAt: role.updatedAt,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'permissions': permissions.map((p) => p.name).toList(),
      'isSystemRole': isSystemRole,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Convert to entity
  StaffRole toEntity() {
    return StaffRole(
      id: id,
      name: name,
      permissions: permissions,
      isSystemRole: isSystemRole,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Parse timestamp from Firestore
  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  /// Convert permission name string to enum
  static AppPermission? _permissionFromString(String name) {
    try {
      return AppPermission.values.firstWhere(
        (p) => p.name == name,
      );
    } catch (_) {
      return null;
    }
  }
}
