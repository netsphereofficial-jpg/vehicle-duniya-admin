import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

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
  bool _isVehiclesExpanded = false;

  @override
  void initState() {
    super.initState();
    // Auto-expand if a vehicle route is active
    _isVehiclesExpanded = widget.currentRoute.startsWith('/vehicles');
  }

  @override
  void didUpdateWidget(SidebarMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-expand when navigating to vehicle routes
    if (widget.currentRoute.startsWith('/vehicles') && !_isVehiclesExpanded) {
      setState(() {
        _isVehiclesExpanded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.isCollapsed ? 80.0 : 260.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      color: AppColors.sidebarBackground,
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: EdgeInsets.all(widget.isCollapsed ? 16 : 20),
            child: widget.isCollapsed
                ? _buildCollapsedLogo()
                : _buildExpandedLogo(),
          ),

          const Divider(color: AppColors.sidebarHover, height: 1),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: AppStrings.dashboard,
                  route: '/dashboard',
                ),
                _buildExpandableMenuItem(
                  context,
                  icon: Icons.directions_car_outlined,
                  activeIcon: Icons.directions_car,
                  label: AppStrings.vehicles,
                  isExpanded: _isVehiclesExpanded,
                  onToggle: () {
                    setState(() {
                      _isVehiclesExpanded = !_isVehiclesExpanded;
                    });
                  },
                  children: [
                    _SubMenuItem(
                      label: 'Create Auction',
                      route: '/vehicles/auctions/create',
                      icon: Icons.add_circle_outline,
                    ),
                    _SubMenuItem(
                      label: 'Active Auctions',
                      route: '/vehicles/auctions/active',
                      icon: Icons.play_circle_outline,
                    ),
                    _SubMenuItem(
                      label: 'Inactive Auctions',
                      route: '/vehicles/auctions/inactive',
                      icon: Icons.pause_circle_outline,
                    ),
                    _SubMenuItem(
                      label: 'Access Users',
                      route: '/vehicles/auctions/access-users',
                      icon: Icons.people_outline,
                    ),
                    _SubMenuItem(
                      label: 'Highest Bids',
                      route: '/vehicles/auctions/highest-bids',
                      icon: Icons.trending_up,
                    ),
                  ],
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.home_work_outlined,
                  activeIcon: Icons.home_work,
                  label: AppStrings.properties,
                  route: '/properties',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.storefront_outlined,
                  activeIcon: Icons.storefront,
                  label: AppStrings.carBazaar,
                  route: '/car-bazaar',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  label: AppStrings.users,
                  route: '/users',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: AppStrings.appConfig,
                  route: '/app-config',
                ),
              ],
            ),
          ),

          // Logout Section
          const Divider(color: AppColors.sidebarHover, height: 1),
          _buildLogoutButton(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCollapsedLogo() {
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

  Widget _buildExpandedLogo() {
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

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
  }) {
    final isActive = widget.currentRoute == route;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCollapsed ? 8 : 12,
        vertical: 2,
      ),
      child: Tooltip(
        message: widget.isCollapsed ? label : '',
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
                horizontal: widget.isCollapsed ? 12 : 16,
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
                mainAxisAlignment:
                    widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Icon(
                    isActive ? activeIcon : icon,
                    color: isActive
                        ? AppColors.sidebarActive
                        : AppColors.sidebarTextMuted,
                    size: 22,
                  ),
                  if (!widget.isCollapsed) ...[
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        color: isActive
                            ? AppColors.sidebarText
                            : AppColors.sidebarTextMuted,
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildExpandableMenuItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<_SubMenuItem> children,
  }) {
    // Check if parent is active (any vehicle route)
    final isParentActive = widget.currentRoute.startsWith('/vehicles');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Parent Item
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? 8 : 12,
            vertical: 2,
          ),
          child: Tooltip(
            message: widget.isCollapsed ? label : '',
            preferBelow: false,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isCollapsed
                    ? () => context.go('/vehicles/auctions/active')
                    : onToggle,
                borderRadius: BorderRadius.circular(8),
                hoverColor: AppColors.sidebarHover,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.isCollapsed ? 12 : 16,
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
                    mainAxisAlignment:
                        widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: [
                      Icon(
                        isParentActive ? activeIcon : icon,
                        color: isParentActive
                            ? AppColors.sidebarActive
                            : AppColors.sidebarTextMuted,
                        size: 22,
                      ),
                      if (!widget.isCollapsed) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isParentActive
                                  ? AppColors.sidebarText
                                  : AppColors.sidebarTextMuted,
                              fontSize: 14,
                              fontWeight: isParentActive ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
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
        if (!widget.isCollapsed)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                children: children.map((child) {
                  final isChildActive = widget.currentRoute == child.route ||
                      widget.currentRoute.startsWith(child.route);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.go(child.route),
                        borderRadius: BorderRadius.circular(8),
                        hoverColor: AppColors.sidebarHover,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isChildActive
                                ? AppColors.sidebarActive.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                child.icon,
                                color: isChildActive
                                    ? AppColors.sidebarActive
                                    : AppColors.sidebarTextMuted,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                child.label,
                                style: TextStyle(
                                  color: isChildActive
                                      ? AppColors.sidebarActive
                                      : AppColors.sidebarTextMuted,
                                  fontSize: 13,
                                  fontWeight:
                                      isChildActive ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            crossFadeState:
                isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCollapsed ? 8 : 12,
        vertical: 8,
      ),
      child: Tooltip(
        message: widget.isCollapsed ? 'Logout' : '',
        preferBelow: false,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showLogoutDialog(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: widget.isCollapsed ? 12 : 16,
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
                mainAxisAlignment:
                    widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
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
                  if (!widget.isCollapsed) ...[
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
              context.go('/login');
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

/// Helper class for submenu items
class _SubMenuItem {
  final String label;
  final String route;
  final IconData icon;

  _SubMenuItem({
    required this.label,
    required this.route,
    required this.icon,
  });
}
