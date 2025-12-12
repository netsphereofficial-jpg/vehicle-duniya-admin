import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../constants/app_colors.dart';

/// Optimized sidebar menu with efficient state management
class SidebarMenu extends StatefulWidget {
  final String currentRoute;
  final bool isCollapsed;
  final VoidCallback? onToggle;

  const SidebarMenu({
    super.key,
    required this.currentRoute,
    this.isCollapsed = false,
    this.onToggle,
  });

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  // Use a Set for efficient expansion state tracking
  final Set<String> _expandedMenus = {};

  // Define all expandable menu prefixes once
  static const _expandableMenuPrefixes = [
    '/vehicle-auctions',
    '/property-auctions',
    '/car-bazaar',
    '/bids',
    '/users',
    '/analytics',
    '/staff',
    '/settings',
  ];

  @override
  void initState() {
    super.initState();
    _autoExpandActiveMenu();
  }

  @override
  void didUpdateWidget(SidebarMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if route actually changed
    if (oldWidget.currentRoute != widget.currentRoute) {
      _autoExpandActiveMenu();
    }
  }

  void _autoExpandActiveMenu() {
    for (final prefix in _expandableMenuPrefixes) {
      if (widget.currentRoute.startsWith(prefix)) {
        _expandedMenus.add(prefix);
        break;
      }
    }
  }

  void _toggleMenu(String prefix) {
    setState(() {
      if (_expandedMenus.contains(prefix)) {
        _expandedMenus.remove(prefix);
      } else {
        _expandedMenus.add(prefix);
      }
    });
  }

  bool _isExpanded(String prefix) => _expandedMenus.contains(prefix);

  @override
  Widget build(BuildContext context) {
    final width = widget.isCollapsed ? 80.0 : 280.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      color: AppColors.sidebarBackground,
      child: Column(
        children: [
          // Logo Section
          _SidebarLogo(isCollapsed: widget.isCollapsed),
          const Divider(color: AppColors.sidebarHover, height: 1),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                // Dashboard
                _MenuItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Dashboard',
                  route: '/dashboard',
                  currentRoute: widget.currentRoute,
                  isCollapsed: widget.isCollapsed,
                ),

                // ===== CORE FEATURES =====
                if (!widget.isCollapsed)
                  const _SectionHeader(title: 'Core Features'),

                // Vehicle Auctions
                _ExpandableMenuItem(
                  icon: Icons.directions_car_outlined,
                  activeIcon: Icons.directions_car,
                  label: 'Vehicle Auctions',
                  routePrefix: '/vehicle-auctions',
                  isExpanded: _isExpanded('/vehicle-auctions'),
                  currentRoute: widget.currentRoute,
                  isCollapsed: widget.isCollapsed,
                  onToggle: () => _toggleMenu('/vehicle-auctions'),
                  children: const [
                    _SubMenuItemData(label: 'Create Auction', route: '/vehicle-auctions/create', icon: Icons.add_circle_outline),
                    _SubMenuItemData(label: 'Active Auctions', route: '/vehicle-auctions/active', icon: Icons.play_circle_outline),
                    _SubMenuItemData(label: 'Inactive Auctions', route: '/vehicle-auctions/inactive', icon: Icons.pause_circle_outline),
                    _SubMenuItemData(label: 'Upload Images', route: '/vehicle-auctions/upload-images', icon: Icons.photo_library_outlined),
                    _SubMenuItemData(label: 'Bid Report', route: '/vehicle-auctions/bid-report', icon: Icons.assessment_outlined),
                    _SubMenuItemData(label: 'Highest Bids', route: '/vehicle-auctions/highest-bids', icon: Icons.trending_up),
                    _SubMenuItemData(label: 'Access Users', route: '/vehicle-auctions/access-users', icon: Icons.people_outline),
                  ],
                ),

                // Property Auctions
                _ExpandableMenuItem(
                  icon: Icons.home_work_outlined,
                  activeIcon: Icons.home_work,
                  label: 'Property Auctions',
                  routePrefix: '/property-auctions',
                  isExpanded: _isExpanded('/property-auctions'),
                  currentRoute: widget.currentRoute,
                  isCollapsed: widget.isCollapsed,
                  onToggle: () => _toggleMenu('/property-auctions'),
                  children: const [
                    _SubMenuItemData(label: 'Create Auction', route: '/property-auctions/create', icon: Icons.add_circle_outline),
                    _SubMenuItemData(label: 'Active Auctions', route: '/property-auctions/active', icon: Icons.play_circle_outline),
                    _SubMenuItemData(label: 'Inactive Auctions', route: '/property-auctions/inactive', icon: Icons.pause_circle_outline),
                    _SubMenuItemData(label: 'User Survey List', route: '/property-auctions/user-survey', icon: Icons.poll_outlined),
                  ],
                ),

                // Car Bazaar
                _ExpandableMenuItem(
                  icon: Icons.storefront_outlined,
                  activeIcon: Icons.storefront,
                  label: 'Car Bazaar',
                  routePrefix: '/car-bazaar',
                  isExpanded: _isExpanded('/car-bazaar'),
                  currentRoute: widget.currentRoute,
                  isCollapsed: widget.isCollapsed,
                  onToggle: () => _toggleMenu('/car-bazaar'),
                  children: const [
                    _SubMenuItemData(label: 'All Cars', route: '/car-bazaar/all', icon: Icons.list_alt),
                    _SubMenuItemData(label: 'Add Car', route: '/car-bazaar/add', icon: Icons.add_circle_outline),
                  ],
                ),

                // ===== MANAGEMENT =====
                if (!widget.isCollapsed)
                  const _SectionHeader(title: 'Management'),

                _MenuItem(
                  icon: Icons.view_carousel_outlined,
                  activeIcon: Icons.view_carousel,
                  label: 'Banner Management',
                  route: '/banners',
                  currentRoute: widget.currentRoute,
                  isCollapsed: widget.isCollapsed,
                ),

                _MenuItem(
                  icon: Icons.verified_user_outlined,
                  activeIcon: Icons.verified_user,
                  label: 'KYC Document',
                  route: '/kyc-documents',
                  currentRoute: widget.currentRoute,
                  isCollapsed: widget.isCollapsed,
                ),

                // Bids Section
                _ExpandableMenuItem(
                  icon: Icons.gavel_outlined,
                  activeIcon: Icons.gavel,
                  label: 'Bids',
                  routePrefix: '/bids',
                  isExpanded: _isExpanded('/bids'),
                  currentRoute: widget.currentRoute,
                  isCollapsed: widget.isCollapsed,
                  onToggle: () => _toggleMenu('/bids'),
                  children: const [
                    _SubMenuItemData(label: 'Vehicle Bids', route: '/bids/vehicle', icon: Icons.directions_car_outlined),
                    _SubMenuItemData(label: 'Property Bids', route: '/bids/property', icon: Icons.home_outlined),
                  ],
                ),

                _MenuItem(
                  icon: Icons.share_outlined,
                  activeIcon: Icons.share,
                  label: 'Referral Link',
                  route: '/referral-link',
                  currentRoute: widget.currentRoute,
                  isCollapsed: widget.isCollapsed,
                ),

                _MenuItem(
                  icon: Icons.lightbulb_outlined,
                  activeIcon: Icons.lightbulb,
                  label: 'Suggestion Box',
                  route: '/suggestion-box',
                  currentRoute: widget.currentRoute,
                  isCollapsed: widget.isCollapsed,
                ),

                _MenuItem(
                  icon: Icons.category_outlined,
                  activeIcon: Icons.category,
                  label: 'Category',
                  route: '/category',
                  currentRoute: widget.currentRoute,
                  isCollapsed: widget.isCollapsed,
                ),

                // ===== USERS & ANALYTICS =====
                if (!widget.isCollapsed)
                  const _SectionHeader(title: 'Users & Analytics'),

                _ExpandableMenuItem(
                  icon: Icons.people_alt_outlined,
                  activeIcon: Icons.people_alt,
                  label: 'User Management',
                  routePrefix: '/users',
                  isExpanded: _isExpanded('/users'),
                  currentRoute: widget.currentRoute,
                  isCollapsed: widget.isCollapsed,
                  onToggle: () => _toggleMenu('/users'),
                  children: const [
                    _SubMenuItemData(label: 'Manage Users', route: '/users/manage', icon: Icons.manage_accounts_outlined),
                    _SubMenuItemData(label: 'Expired Profiles', route: '/users/expired-profiles', icon: Icons.person_off_outlined),
                  ],
                ),

                _ExpandableMenuItem(
                  icon: Icons.analytics_outlined,
                  activeIcon: Icons.analytics,
                  label: 'Analytics',
                  routePrefix: '/analytics',
                  isExpanded: _isExpanded('/analytics'),
                  currentRoute: widget.currentRoute,
                  isCollapsed: widget.isCollapsed,
                  onToggle: () => _toggleMenu('/analytics'),
                  children: const [
                    _SubMenuItemData(label: 'User Analytics', route: '/analytics/users', icon: Icons.person_search_outlined),
                    _SubMenuItemData(label: 'EMD Analytics', route: '/analytics/emd', icon: Icons.account_balance_wallet_outlined),
                  ],
                ),

                _MenuItem(
                  icon: Icons.article_outlined,
                  activeIcon: Icons.article,
                  label: 'Blog Section',
                  route: '/blog',
                  currentRoute: widget.currentRoute,
                  isCollapsed: widget.isCollapsed,
                ),

                // ===== ADMINISTRATION =====
                if (!widget.isCollapsed)
                  const _SectionHeader(title: 'Administration'),

                _ExpandableMenuItem(
                  icon: Icons.admin_panel_settings_outlined,
                  activeIcon: Icons.admin_panel_settings,
                  label: 'Staff Management',
                  routePrefix: '/staff',
                  isExpanded: _isExpanded('/staff'),
                  currentRoute: widget.currentRoute,
                  isCollapsed: widget.isCollapsed,
                  onToggle: () => _toggleMenu('/staff'),
                  children: const [
                    _SubMenuItemData(label: 'Role Management', route: '/staff/roles', icon: Icons.security_outlined),
                    _SubMenuItemData(label: 'Staff Members', route: '/staff/members', icon: Icons.badge_outlined),
                  ],
                ),

                _ExpandableMenuItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Settings',
                  routePrefix: '/settings',
                  isExpanded: _isExpanded('/settings'),
                  currentRoute: widget.currentRoute,
                  isCollapsed: widget.isCollapsed,
                  onToggle: () => _toggleMenu('/settings'),
                  children: const [
                    _SubMenuItemData(label: 'App News Ticker', route: '/settings/news-ticker', icon: Icons.rss_feed_outlined),
                    _SubMenuItemData(label: 'Page Settings', route: '/settings/pages', icon: Icons.web_outlined),
                    _SubMenuItemData(label: 'Social Settings', route: '/settings/social', icon: Icons.public_outlined),
                    _SubMenuItemData(label: 'General Settings', route: '/settings/general', icon: Icons.tune_outlined),
                  ],
                ),
              ],
            ),
          ),

          // Logout Section
          const Divider(color: AppColors.sidebarHover, height: 1),
          _LogoutButton(isCollapsed: widget.isCollapsed),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ===== EXTRACTED WIDGETS FOR BETTER PERFORMANCE =====

/// Sidebar logo widget - extracted for const optimization
class _SidebarLogo extends StatelessWidget {
  final bool isCollapsed;

  const _SidebarLogo({required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCollapsed ? 16 : 20),
      child: isCollapsed ? _buildCollapsed() : _buildExpanded(),
    );
  }

  Widget _buildCollapsed() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/images/vehicle_duniya_logo_with_bg.png',
        width: 48,
        height: 48,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildExpanded() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/vehicle_duniya_logo_with_bg.png',
            width: 55,
            height: 55,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Panel',
                style: TextStyle(
                  color: AppColors.sidebarText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Manage your platform',
                style: TextStyle(
                  color: AppColors.sidebarTextMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Section header widget
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 12, top: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppColors.sidebarTextMuted.withValues(alpha: 0.7),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// Single menu item widget
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final String currentRoute;
  final bool isCollapsed;

  const _MenuItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.currentRoute,
    required this.isCollapsed,
  });

  bool get isActive => currentRoute == route || currentRoute.startsWith('$route/');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 8 : 12,
        vertical: 2,
      ),
      child: Tooltip(
        message: isCollapsed ? label : '',
        preferBelow: false,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.go(route),
            borderRadius: BorderRadius.circular(8),
            hoverColor: AppColors.sidebarHover,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? 12 : 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isActive ? AppColors.sidebarHover : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isActive
                    ? const Border(
                        left: BorderSide(
                          color: AppColors.sidebarActive,
                          width: 3,
                        ),
                      )
                    : null,
              ),
              child: Row(
                mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Icon(
                    isActive ? activeIcon : icon,
                    color: isActive ? AppColors.sidebarActive : AppColors.sidebarTextMuted,
                    size: 22,
                  ),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isActive ? AppColors.sidebarText : AppColors.sidebarTextMuted,
                          fontSize: 14,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Data class for submenu items - immutable for const usage
class _SubMenuItemData {
  final String label;
  final String route;
  final IconData icon;

  const _SubMenuItemData({
    required this.label,
    required this.route,
    required this.icon,
  });
}

/// Expandable menu item widget
class _ExpandableMenuItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String routePrefix;
  final bool isExpanded;
  final String currentRoute;
  final bool isCollapsed;
  final VoidCallback onToggle;
  final List<_SubMenuItemData> children;

  const _ExpandableMenuItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.routePrefix,
    required this.isExpanded,
    required this.currentRoute,
    required this.isCollapsed,
    required this.onToggle,
    required this.children,
  });

  bool get isParentActive => currentRoute.startsWith(routePrefix);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Parent Item
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 8 : 12,
            vertical: 2,
          ),
          child: Tooltip(
            message: isCollapsed ? label : '',
            preferBelow: false,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isCollapsed ? () => context.go(children.first.route) : onToggle,
                borderRadius: BorderRadius.circular(8),
                hoverColor: AppColors.sidebarHover,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: isCollapsed ? 12 : 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isParentActive ? AppColors.sidebarHover : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isParentActive
                        ? const Border(
                            left: BorderSide(
                              color: AppColors.sidebarActive,
                              width: 3,
                            ),
                          )
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: [
                      Icon(
                        isParentActive ? activeIcon : icon,
                        color: isParentActive ? AppColors.sidebarActive : AppColors.sidebarTextMuted,
                        size: 22,
                      ),
                      if (!isCollapsed) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isParentActive ? AppColors.sidebarText : AppColors.sidebarTextMuted,
                              fontSize: 14,
                              fontWeight: isParentActive ? FontWeight.w600 : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.sidebarTextMuted,
                            size: 20,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Child Items
        if (!isCollapsed)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                children: children.map((child) {
                  final isChildActive = currentRoute == child.route ||
                      currentRoute.startsWith('${child.route}/');

                  return _SubMenuItem(
                    data: child,
                    isActive: isChildActive,
                  );
                }).toList(),
              ),
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
      ],
    );
  }
}

/// Sub menu item widget
class _SubMenuItem extends StatelessWidget {
  final _SubMenuItemData data;
  final bool isActive;

  const _SubMenuItem({
    required this.data,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(data.route),
          borderRadius: BorderRadius.circular(8),
          hoverColor: AppColors.sidebarHover,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? AppColors.sidebarActive.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  data.icon,
                  color: isActive ? AppColors.sidebarActive : AppColors.sidebarTextMuted,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    data.label,
                    style: TextStyle(
                      color: isActive ? AppColors.sidebarActive : AppColors.sidebarTextMuted,
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Logout button widget
class _LogoutButton extends StatelessWidget {
  final bool isCollapsed;

  const _LogoutButton({required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 8 : 12,
        vertical: 8,
      ),
      child: Tooltip(
        message: isCollapsed ? 'Logout' : '',
        preferBelow: false,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showLogoutDialog(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? 12 : 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.error.withValues(alpha: 0.15),
                    AppColors.error.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                      size: 18,
                    ),
                  ),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 12),
                    const Text(
                      'Logout',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.error.withValues(alpha: 0.5),
                      size: 14,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Logout'),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout from the admin panel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Properly logout via AuthBloc
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
