import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class SidebarMenu extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final width = isCollapsed ? 80.0 : 260.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      color: AppColors.sidebarBackground,
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: EdgeInsets.all(isCollapsed ? 16 : 20),
            child: isCollapsed
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
                _buildMenuItem(
                  context,
                  icon: Icons.directions_car_outlined,
                  activeIcon: Icons.directions_car,
                  label: AppStrings.vehicles,
                  route: '/vehicles',
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
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/images/vehicle_duniya_logo.png',
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
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/vehicle_duniya_logo.png',
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName,
                style: TextStyle(
                  color: AppColors.sidebarText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                AppStrings.appTagline,
                style: TextStyle(
                  color: AppColors.sidebarTextMuted,
                  fontSize: 12,
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
    final isActive = currentRoute == route;

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
                mainAxisAlignment:
                    isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Icon(
                    isActive ? activeIcon : icon,
                    color: isActive
                        ? AppColors.sidebarActive
                        : AppColors.sidebarTextMuted,
                    size: 22,
                  ),
                  if (!isCollapsed) ...[
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

  Widget _buildLogoutButton(BuildContext context) {
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
                mainAxisAlignment:
                    isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
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
