import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/staff_member.dart';

/// Firestore model for StaffMember
class StaffMemberModel extends StaffMember {
  const StaffMemberModel({
    required super.id,
    required super.name,
    required super.username,
    required super.email,
    required super.phone,
    required super.roleId,
    required super.roleName,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.lastLoginAt,
  });

  /// Create from Firestore document
  factory StaffMemberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return StaffMemberModel(
      id: doc.id,
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      roleId: data['roleId'] ?? '',
      roleName: data['roleName'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      lastLoginAt: data['lastLoginAt'] != null
          ? _parseTimestamp(data['lastLoginAt'])
          : null,
    );
  }

  /// Create from entity
  factory StaffMemberModel.fromEntity(StaffMember member) {
    return StaffMemberModel(
      id: member.id,
      name: member.name,
      username: member.username,
      email: member.email,
      phone: member.phone,
      roleId: member.roleId,
      roleName: member.roleName,
      isActive: member.isActive,
      createdAt: member.createdAt,
      updatedAt: member.updatedAt,
      lastLoginAt: member.lastLoginAt,
    );
  }

  /// Convert to Firestore map (for create)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'roleId': roleId,
      'roleName': roleName,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (lastLoginAt != null) 'lastLoginAt': Timestamp.fromDate(lastLoginAt!),
    };
  }

  /// Convert to entity
  StaffMember toEntity() {
    return StaffMember(
      id: id,
      name: name,
      username: username,
      email: email,
      phone: phone,
      roleId: roleId,
      roleName: roleName,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLoginAt: lastLoginAt,
    );
  }

  /// Parse timestamp from Firestore
  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
