import 'package:equatable/equatable.dart';

/// Staff member entity
class StaffMember extends Equatable {
  final String id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String roleId;
  final String roleName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  const StaffMember({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.roleId,
    required this.roleName,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  /// Format phone for display (with +91)
  String get formattedPhone => phone.startsWith('+91') ? phone : '+91 $phone';

  /// Empty staff member for initial state
  static StaffMember get empty => StaffMember(
        id: '',
        name: '',
        username: '',
        email: '',
        phone: '',
        roleId: '',
        roleName: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  /// Create a copy with modified fields
  StaffMember copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? phone,
    String? roleId,
    String? roleName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return StaffMember(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        username,
        email,
        phone,
        roleId,
        roleName,
        isActive,
        createdAt,
        updatedAt,
        lastLoginAt,
      ];
}
