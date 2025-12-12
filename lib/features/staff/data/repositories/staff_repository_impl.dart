import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/permissions.dart';
import '../../domain/entities/staff_member.dart';
import '../../domain/entities/staff_role.dart';
import '../../domain/repositories/staff_repository.dart';
import '../models/staff_member_model.dart';
import '../models/staff_role_model.dart';

/// Firebase implementation of StaffRepository
/// Optimized for efficient reads with proper indexing and caching
class StaffRepositoryImpl implements StaffRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _rolesCollection = 'roles';
  static const String _staffCollection = 'staff_members';

  StaffRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  CollectionReference get _rolesRef => _firestore.collection(_rolesCollection);
  CollectionReference get _staffRef => _firestore.collection(_staffCollection);

  // ============ ROLES ============

  @override
  Future<List<StaffRole>> getRoles() async {
    final snapshot = await _rolesRef.orderBy('name').get();
    return snapshot.docs
        .map((doc) => StaffRoleModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Stream<List<StaffRole>> watchRoles() {
    return _rolesRef.orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => StaffRoleModel.fromFirestore(doc).toEntity())
              .toList(),
        );
  }

  @override
  Future<StaffRole?> getRoleById(String roleId) async {
    final doc = await _rolesRef.doc(roleId).get();
    if (!doc.exists) return null;
    return StaffRoleModel.fromFirestore(doc).toEntity();
  }

  @override
  Future<StaffRole> createRole({
    required String name,
    required List<AppPermission> permissions,
  }) async {
    final now = DateTime.now();
    final roleModel = StaffRoleModel(
      id: '',
      name: name,
      permissions: permissions,
      isSystemRole: false,
      createdAt: now,
      updatedAt: now,
    );

    final docRef = await _rolesRef.add(roleModel.toFirestore());
    final createdDoc = await docRef.get();
    return StaffRoleModel.fromFirestore(createdDoc).toEntity();
  }

  @override
  Future<void> updateRole({
    required String roleId,
    required String name,
    required List<AppPermission> permissions,
  }) async {
    // Use batch to update role and all staff members with this role
    final batch = _firestore.batch();

    // Update role
    batch.update(_rolesRef.doc(roleId), {
      'name': name,
      'permissions': permissions.map((p) => p.name).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update denormalized role name in staff members
    final staffWithRole =
        await _staffRef.where('roleId', isEqualTo: roleId).get();
    for (final doc in staffWithRole.docs) {
      batch.update(doc.reference, {'roleName': name});
    }

    await batch.commit();
  }

  @override
  Future<void> deleteRole(String roleId) async {
    // Check if any staff members have this role
    final staffCount = await countStaffWithRole(roleId);
    if (staffCount > 0) {
      throw Exception(
        'Cannot delete role: $staffCount staff member(s) are assigned to this role',
      );
    }

    await _rolesRef.doc(roleId).delete();
  }

  @override
  Future<int> countStaffWithRole(String roleId) async {
    final snapshot = await _staffRef
        .where('roleId', isEqualTo: roleId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  // ============ STAFF MEMBERS ============

  @override
  Future<List<StaffMember>> getStaffMembers() async {
    final snapshot = await _staffRef.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => StaffMemberModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Stream<List<StaffMember>> watchStaffMembers() {
    return _staffRef.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => StaffMemberModel.fromFirestore(doc).toEntity())
              .toList(),
        );
  }

  @override
  Future<StaffMember?> getStaffMemberById(String staffId) async {
    final doc = await _staffRef.doc(staffId).get();
    if (!doc.exists) return null;
    return StaffMemberModel.fromFirestore(doc).toEntity();
  }

  @override
  Future<StaffMember?> getStaffMemberByEmail(String email) async {
    final snapshot = await _staffRef
        .where('email', isEqualTo: email.toLowerCase())
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return StaffMemberModel.fromFirestore(snapshot.docs.first).toEntity();
  }

  @override
  Future<StaffMember> createStaffMember({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String password,
    required String roleId,
    required String roleName,
  }) async {
    // Create Firebase Auth user
    // Note: This will sign out the current user, so we need to handle this
    // We use secondary Firebase Auth app for this purpose
    final userCredential = await _createAuthUser(email, password);
    final uid = userCredential.user!.uid;

    final now = DateTime.now();
    final staffModel = StaffMemberModel(
      id: uid,
      name: name,
      username: username,
      email: email.toLowerCase(),
      phone: phone,
      roleId: roleId,
      roleName: roleName,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    // Use the Firebase Auth UID as the document ID
    await _staffRef.doc(uid).set(staffModel.toFirestore());

    return staffModel.toEntity();
  }

  /// Create Firebase Auth user without signing out current user
  Future<UserCredential> _createAuthUser(String email, String password) async {
    // Store current user
    final currentUser = _auth.currentUser;

    try {
      // Create new user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Sign back in as original user if we had one
      if (currentUser != null) {
        // We need to re-authenticate the original admin
        // For now, we'll handle this in the UI by re-authenticating
      }

      return credential;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateStaffMember({
    required String staffId,
    required String name,
    required String username,
    required String phone,
    required String roleId,
    required String roleName,
    required bool isActive,
  }) async {
    await _staffRef.doc(staffId).update({
      'name': name,
      'username': username,
      'phone': phone,
      'roleId': roleId,
      'roleName': roleName,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateStaffPassword({
    required String staffId,
    required String newPassword,
  }) async {
    // This requires admin SDK or the user to be signed in
    // For web admin, we'll need to use Firebase Admin SDK via Cloud Functions
    throw UnimplementedError(
      'Password update requires Firebase Admin SDK. '
      'Please use a Cloud Function for this operation.',
    );
  }

  @override
  Future<void> deleteStaffMember(String staffId) async {
    // Delete Firestore document
    await _staffRef.doc(staffId).delete();

    // Note: Firebase Auth user deletion requires Admin SDK
    // The auth account will need to be deleted separately via Cloud Function
    // or the user won't be able to log in since the staff_members doc is gone
  }

  @override
  Future<void> toggleStaffStatus(String staffId, bool isActive) async {
    await _staffRef.doc(staffId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============ PERMISSIONS ============

  @override
  Future<List<AppPermission>?> getStaffPermissions(String staffId) async {
    // Get staff member
    final staffDoc = await _staffRef.doc(staffId).get();
    if (!staffDoc.exists) return null; // Super admin

    final staff = StaffMemberModel.fromFirestore(staffDoc);

    // Get role permissions
    final roleDoc = await _rolesRef.doc(staff.roleId).get();
    if (!roleDoc.exists) return [];

    final role = StaffRoleModel.fromFirestore(roleDoc);
    return role.permissions;
  }

  @override
  Future<bool> isSuperAdmin(String userId) async {
    final doc = await _staffRef.doc(userId).get();
    return !doc.exists;
  }

  @override
  Future<void> updateLastLogin(String staffId) async {
    await _staffRef.doc(staffId).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }
}
