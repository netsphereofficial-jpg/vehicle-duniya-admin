/// All available permissions in the admin panel
/// Each permission corresponds to a sidebar menu item
enum AppPermission {
  // Dashboard
  dashboard,

  // Vehicle Auctions
  vehicleAuctionsCreate,
  vehicleAuctionsActive,
  vehicleAuctionsInactive,
  vehicleAuctionsUploadImages,
  vehicleAuctionsBidReport,
  vehicleAuctionsHighestBids,
  vehicleAuctionsAccessUsers,

  // Property Auctions
  propertyAuctionsCreate,
  propertyAuctionsActive,
  propertyAuctionsInactive,
  propertyAuctionsUserSurvey,

  // Car Bazaar
  carBazaarAll,
  carBazaarAdd,

  // Management
  banners,
  kycDocuments,

  // Bids
  bidsVehicle,
  bidsProperty,

  // Other
  referralLink,
  suggestionBox,
  category,

  // Users
  usersManage,
  usersExpiredProfiles,

  // Analytics
  analyticsUsers,
  analyticsEmd,

  // Content
  blog,

  // Staff
  staffRoles,
  staffMembers,

  // Settings
  settingsNewsTicker,
  settingsPages,
  settingsSocial,
  settingsGeneral,
}

/// Information about a permission
class PermissionInfo {
  final String label;
  final String group;
  final String route;

  const PermissionInfo({
    required this.label,
    required this.group,
    required this.route,
  });
}

/// Mapping of permissions to their info
const Map<AppPermission, PermissionInfo> permissionInfo = {
  // Dashboard
  AppPermission.dashboard: PermissionInfo(
    label: 'Dashboard',
    group: 'Dashboard',
    route: '/dashboard',
  ),

  // Vehicle Auctions
  AppPermission.vehicleAuctionsCreate: PermissionInfo(
    label: 'Create Auction',
    group: 'Vehicle Auctions',
    route: '/vehicle-auctions/create',
  ),
  AppPermission.vehicleAuctionsActive: PermissionInfo(
    label: 'Active Auctions',
    group: 'Vehicle Auctions',
    route: '/vehicle-auctions/active',
  ),
  AppPermission.vehicleAuctionsInactive: PermissionInfo(
    label: 'Inactive Auctions',
    group: 'Vehicle Auctions',
    route: '/vehicle-auctions/inactive',
  ),
  AppPermission.vehicleAuctionsUploadImages: PermissionInfo(
    label: 'Upload Images',
    group: 'Vehicle Auctions',
    route: '/vehicle-auctions/upload-images',
  ),
  AppPermission.vehicleAuctionsBidReport: PermissionInfo(
    label: 'Bid Report',
    group: 'Vehicle Auctions',
    route: '/vehicle-auctions/bid-report',
  ),
  AppPermission.vehicleAuctionsHighestBids: PermissionInfo(
    label: 'Highest Bids',
    group: 'Vehicle Auctions',
    route: '/vehicle-auctions/highest-bids',
  ),
  AppPermission.vehicleAuctionsAccessUsers: PermissionInfo(
    label: 'Access Users',
    group: 'Vehicle Auctions',
    route: '/vehicle-auctions/access-users',
  ),

  // Property Auctions
  AppPermission.propertyAuctionsCreate: PermissionInfo(
    label: 'Create Auction',
    group: 'Property Auctions',
    route: '/property-auctions/create',
  ),
  AppPermission.propertyAuctionsActive: PermissionInfo(
    label: 'Active Auctions',
    group: 'Property Auctions',
    route: '/property-auctions/active',
  ),
  AppPermission.propertyAuctionsInactive: PermissionInfo(
    label: 'Inactive Auctions',
    group: 'Property Auctions',
    route: '/property-auctions/inactive',
  ),
  AppPermission.propertyAuctionsUserSurvey: PermissionInfo(
    label: 'User Survey List',
    group: 'Property Auctions',
    route: '/property-auctions/user-survey',
  ),

  // Car Bazaar
  AppPermission.carBazaarAll: PermissionInfo(
    label: 'All Cars',
    group: 'Car Bazaar',
    route: '/car-bazaar/all',
  ),
  AppPermission.carBazaarAdd: PermissionInfo(
    label: 'Add Car',
    group: 'Car Bazaar',
    route: '/car-bazaar/add',
  ),

  // Management
  AppPermission.banners: PermissionInfo(
    label: 'Banner Management',
    group: 'Management',
    route: '/banners',
  ),
  AppPermission.kycDocuments: PermissionInfo(
    label: 'KYC Document',
    group: 'Management',
    route: '/kyc-documents',
  ),

  // Bids
  AppPermission.bidsVehicle: PermissionInfo(
    label: 'Vehicle Bids',
    group: 'Bids',
    route: '/bids/vehicle',
  ),
  AppPermission.bidsProperty: PermissionInfo(
    label: 'Property Bids',
    group: 'Bids',
    route: '/bids/property',
  ),

  // Other
  AppPermission.referralLink: PermissionInfo(
    label: 'Referral Link',
    group: 'Other',
    route: '/referral-link',
  ),
  AppPermission.suggestionBox: PermissionInfo(
    label: 'Suggestion Box',
    group: 'Other',
    route: '/suggestion-box',
  ),
  AppPermission.category: PermissionInfo(
    label: 'Category',
    group: 'Other',
    route: '/category',
  ),

  // Users
  AppPermission.usersManage: PermissionInfo(
    label: 'Manage Users',
    group: 'Users',
    route: '/users/manage',
  ),
  AppPermission.usersExpiredProfiles: PermissionInfo(
    label: 'Expired Profiles',
    group: 'Users',
    route: '/users/expired-profiles',
  ),

  // Analytics
  AppPermission.analyticsUsers: PermissionInfo(
    label: 'User Analytics',
    group: 'Analytics',
    route: '/analytics/users',
  ),
  AppPermission.analyticsEmd: PermissionInfo(
    label: 'EMD Analytics',
    group: 'Analytics',
    route: '/analytics/emd',
  ),

  // Content
  AppPermission.blog: PermissionInfo(
    label: 'Blog Section',
    group: 'Content',
    route: '/blog',
  ),

  // Staff
  AppPermission.staffRoles: PermissionInfo(
    label: 'Role Management',
    group: 'Staff',
    route: '/staff/roles',
  ),
  AppPermission.staffMembers: PermissionInfo(
    label: 'Staff Members',
    group: 'Staff',
    route: '/staff/members',
  ),

  // Settings
  AppPermission.settingsNewsTicker: PermissionInfo(
    label: 'App News Ticker',
    group: 'Settings',
    route: '/settings/news-ticker',
  ),
  AppPermission.settingsPages: PermissionInfo(
    label: 'Page Settings',
    group: 'Settings',
    route: '/settings/pages',
  ),
  AppPermission.settingsSocial: PermissionInfo(
    label: 'Social Settings',
    group: 'Settings',
    route: '/settings/social',
  ),
  AppPermission.settingsGeneral: PermissionInfo(
    label: 'General Settings',
    group: 'Settings',
    route: '/settings/general',
  ),
};

/// Get permissions grouped by their group name
/// Returns a map with group names as keys and lists of permissions as values
Map<String, List<AppPermission>> get permissionsByGroup {
  final groups = <String, List<AppPermission>>{};

  for (final permission in AppPermission.values) {
    final info = permissionInfo[permission]!;
    groups.putIfAbsent(info.group, () => []).add(permission);
  }

  return groups;
}

/// Ordered list of groups for UI display
const List<String> permissionGroupOrder = [
  'Dashboard',
  'Vehicle Auctions',
  'Property Auctions',
  'Car Bazaar',
  'Management',
  'Bids',
  'Other',
  'Users',
  'Analytics',
  'Content',
  'Staff',
  'Settings',
];

/// Get permission from route
AppPermission? permissionFromRoute(String route) {
  for (final entry in permissionInfo.entries) {
    if (entry.value.route == route) {
      return entry.key;
    }
  }
  return null;
}

/// Get all permissions for a group prefix (e.g., 'Vehicle Auctions')
List<AppPermission> permissionsForGroup(String group) {
  return AppPermission.values
      .where((p) => permissionInfo[p]?.group == group)
      .toList();
}
