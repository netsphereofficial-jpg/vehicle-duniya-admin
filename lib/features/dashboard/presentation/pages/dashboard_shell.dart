import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class DashboardShell extends StatefulWidget {
  final String currentRoute;
  final Widget child;

  const DashboardShell({
    super.key,
    required this.currentRoute,
    required this.child,
  });

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  bool _isSidebarCollapsed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < mobileBreakpoint;
    final isTablet = screenWidth >= mobileBreakpoint && screenWidth < tabletBreakpoint;

    // Auto-collapse sidebar on tablet
    if (isTablet && !_isSidebarCollapsed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _isSidebarCollapsed = true);
        }
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      // Mobile drawer
      drawer: isMobile
          ? Drawer(
              backgroundColor: AppColors.sidebarBackground,
              child: ResponsiveSidebar(
                currentRoute: widget.currentRoute,
                isCollapsed: false,
                onLogout: _handleLogout,
              ),
            )
          : null,
      body: Row(
        children: [
          // Desktop/Tablet Sidebar
          if (!isMobile)
            ResponsiveSidebar(
              currentRoute: widget.currentRoute,
              isCollapsed: _isSidebarCollapsed,
              onToggle: () {
                setState(() {
                  _isSidebarCollapsed = !_isSidebarCollapsed;
                });
              },
              onLogout: _handleLogout,
            ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                _buildTopBar(isMobile),
                // Content
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isMobile) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Menu button for mobile or toggle for desktop
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              tooltip: 'Open menu',
            )
          else
            IconButton(
              icon: Icon(
                _isSidebarCollapsed
                    ? Icons.menu_open
                    : Icons.menu,
              ),
              onPressed: () {
                setState(() {
                  _isSidebarCollapsed = !_isSidebarCollapsed;
                });
              },
              tooltip: _isSidebarCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
            ),

          const SizedBox(width: 16),

          // Page title or search
          Expanded(
            child: Text(
              _getPageTitle(widget.currentRoute),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),

          // Right side actions
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 8),
          // Admin avatar
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryLight,
              child: Icon(
                Icons.person,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle(String route) {
    switch (route) {
      case '/dashboard':
        return 'Dashboard';
      case '/vehicles':
        return 'Vehicles';
      case '/properties':
        return 'Properties';
      case '/car-bazaar':
        return 'Car Bazaar';
      case '/users':
        return 'Users';
      case '/app-config':
        return 'App Configuration';
      default:
        return 'Vehicle Duniya';
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Use the main context for navigation
              context.read<AuthBloc>().add(const AuthLogoutRequested());
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

// Responsive sidebar that handles logout via callback
class ResponsiveSidebar extends StatelessWidget {
  final String currentRoute;
  final bool isCollapsed;
  final VoidCallback? onToggle;
  final VoidCallback onLogout;

  const ResponsiveSidebar({
    super.key,
    required this.currentRoute,
    required this.isCollapsed,
    this.onToggle,
    required this.onLogout,
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
            child: isCollapsed ? _buildCollapsedLogo() : _buildExpandedLogo(),
          ),

          const Divider(color: AppColors.sidebarHover, height: 1),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildMenuItem(context, Icons.dashboard_outlined, Icons.dashboard, 'Dashboard', '/dashboard'),
                _buildMenuItem(context, Icons.directions_car_outlined, Icons.directions_car, 'Vehicles', '/vehicles'),
                _buildMenuItem(context, Icons.home_work_outlined, Icons.home_work, 'Properties', '/properties'),
                _buildMenuItem(context, Icons.storefront_outlined, Icons.storefront, 'Car Bazaar', '/car-bazaar'),
                _buildMenuItem(context, Icons.people_outline, Icons.people, 'Users', '/users'),
                _buildMenuItem(context, Icons.settings_outlined, Icons.settings, 'App Config', '/app-config'),
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
                'Vehicle Duniya',
                style: TextStyle(
                  color: AppColors.sidebarText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Admin Panel',
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
    BuildContext context,
    IconData icon,
    IconData activeIcon,
    String label,
    String route,
  ) {
    final isActive = currentRoute == route;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 12, vertical: 2),
      child: Tooltip(
        message: isCollapsed ? label : '',
        preferBelow: false,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Close drawer on mobile
              if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
                Navigator.pop(context);
              }
              context.go(route);
            },
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
                        left: BorderSide(color: AppColors.sidebarActive, width: 3),
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
                    Text(
                      label,
                      style: TextStyle(
                        color: isActive ? AppColors.sidebarText : AppColors.sidebarTextMuted,
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
      padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 12, vertical: 8),
      child: Tooltip(
        message: isCollapsed ? 'Logout' : '',
        preferBelow: false,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Close drawer on mobile first
              if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
                Navigator.pop(context);
              }
              onLogout();
            },
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
}
