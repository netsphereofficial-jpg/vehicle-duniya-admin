import '../constants/permissions.dart';

/// Service for managing user permissions
/// Initialized on login, cleared on logout
class PermissionService {
  Set<AppPermission> _permissions = {};
  bool _isSuperAdmin = false;

  /// Whether the current user is a super admin (full access)
  bool get isSuperAdmin => _isSuperAdmin;

  /// Get all current permissions
  Set<AppPermission> get permissions => Set.unmodifiable(_permissions);

  /// Initialize with permissions from staff role
  void initialize({
    required List<AppPermission> permissions,
    bool isSuperAdmin = false,
  }) {
    _permissions = permissions.toSet();
    _isSuperAdmin = isSuperAdmin;
  }

  /// Initialize as super admin with all permissions
  void initializeAsSuperAdmin() {
    _permissions = AppPermission.values.toSet();
    _isSuperAdmin = true;
  }

  /// Check if user has a specific permission
  bool hasPermission(AppPermission permission) {
    if (_isSuperAdmin) return true;
    return _permissions.contains(permission);
  }

  /// Check if user has any of the given permissions
  bool hasAnyPermission(List<AppPermission> permissions) {
    if (_isSuperAdmin) return true;
    return permissions.any((p) => _permissions.contains(p));
  }

  /// Check if user has all of the given permissions
  bool hasAllPermissions(List<AppPermission> permissions) {
    if (_isSuperAdmin) return true;
    return permissions.every((p) => _permissions.contains(p));
  }

  /// Check if user can access a route
  bool canAccessRoute(String route) {
    if (_isSuperAdmin) return true;

    final permission = permissionFromRoute(route);
    if (permission == null) {
      // If no permission found for route, check if it's a parent route
      // Allow access if user has any child permissions
      for (final p in _permissions) {
        final info = permissionInfo[p];
        if (info != null && info.route.startsWith(route)) {
          return true;
        }
      }
      return false;
    }

    return _permissions.contains(permission);
  }

  /// Get permitted routes
  List<String> get permittedRoutes {
    if (_isSuperAdmin) {
      return permissionInfo.values.map((info) => info.route).toList();
    }
    return _permissions
        .map((p) => permissionInfo[p]?.route)
        .whereType<String>()
        .toList();
  }

  /// Clear all permissions (on logout)
  void clear() {
    _permissions = {};
    _isSuperAdmin = false;
  }
}
