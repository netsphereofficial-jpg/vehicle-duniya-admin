import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/sidebar_menu.dart';

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
              child: SidebarMenu(
                currentRoute: widget.currentRoute,
                isCollapsed: false,
              ),
            )
          : null,
      body: Row(
        children: [
          // Desktop/Tablet Sidebar
          if (!isMobile)
            SidebarMenu(
              currentRoute: widget.currentRoute,
              isCollapsed: _isSidebarCollapsed,
              onToggle: () {
                setState(() {
                  _isSidebarCollapsed = !_isSidebarCollapsed;
                });
              },
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
    if (route.startsWith('/vehicles/auctions/create')) {
      return 'Create Auction';
    } else if (route.startsWith('/vehicles/auctions/active')) {
      return 'Active Auctions';
    } else if (route.startsWith('/vehicles/auctions/inactive')) {
      return 'Inactive Auctions';
    } else if (route.startsWith('/vehicles/auctions/access-users')) {
      return 'Auction Access Users';
    } else if (route.startsWith('/vehicles/auctions/highest-bids')) {
      return 'Highest Bids';
    } else if (route.startsWith('/vehicles/auctions/')) {
      return 'Auction Details';
    }

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
}
