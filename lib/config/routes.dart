import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/injection.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/category/presentation/bloc/category_bloc.dart';
import '../features/category/presentation/bloc/category_event.dart' as category_events;
import '../features/category/presentation/pages/category_page.dart';
import '../features/referral_link/presentation/bloc/referral_bloc.dart';
import '../features/referral_link/presentation/pages/referral_link_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/dashboard/presentation/pages/dashboard_shell.dart';
import '../features/settings/presentation/bloc/settings_bloc.dart';
import '../features/settings/presentation/bloc/settings_event.dart' as settings_events;
import '../features/settings/presentation/pages/general_settings_page.dart';
import '../features/staff/presentation/bloc/staff_bloc.dart';
import '../features/staff/presentation/pages/staff_management_page.dart';
import '../features/suggestion_box/presentation/bloc/suggestion_bloc.dart';
import '../features/suggestion_box/presentation/pages/suggestion_box_page.dart';
import '../features/vehicle_auction/presentation/bloc/auction_bloc.dart';
import '../features/vehicle_auction/presentation/bloc/auction_event.dart' as auction_events;
import '../features/vehicle_auction/presentation/pages/active_auctions_page.dart';
import '../features/vehicle_auction/presentation/pages/auction_detail_page.dart';
import '../features/vehicle_auction/presentation/pages/create_auction_page.dart';
import '../features/vehicle_auction/presentation/pages/inactive_auctions_page.dart';

class AppRoutes {
  // Auth
  static const String login = '/login';
  static const String dashboard = '/dashboard';

  // ===== CORE FEATURES =====
  // Vehicle Auctions
  static const String vehicleAuctions = '/vehicle-auctions';
  static const String vehicleAuctionsCreate = '/vehicle-auctions/create';
  static const String vehicleAuctionsActive = '/vehicle-auctions/active';
  static const String vehicleAuctionsInactive = '/vehicle-auctions/inactive';
  static const String vehicleAuctionsUploadImages = '/vehicle-auctions/upload-images';
  static const String vehicleAuctionsBidReport = '/vehicle-auctions/bid-report';
  static const String vehicleAuctionsAccessUsers = '/vehicle-auctions/access-users';
  static const String vehicleAuctionsHighestBids = '/vehicle-auctions/highest-bids';
  static const String vehicleAuctionDetail = '/vehicle-auctions/:id';
  static const String vehicleAuctionEdit = '/vehicle-auctions/:id/edit';

  // Property Auctions
  static const String propertyAuctions = '/property-auctions';
  static const String propertyAuctionsCreate = '/property-auctions/create';
  static const String propertyAuctionsActive = '/property-auctions/active';
  static const String propertyAuctionsInactive = '/property-auctions/inactive';
  static const String propertyAuctionsUserSurvey = '/property-auctions/user-survey';

  // Car Bazaar
  static const String carBazaar = '/car-bazaar';
  static const String carBazaarAll = '/car-bazaar/all';
  static const String carBazaarAdd = '/car-bazaar/add';

  // ===== MANAGEMENT =====
  static const String banners = '/banners';
  static const String kycDocuments = '/kyc-documents';

  // Bids
  static const String bids = '/bids';
  static const String bidsVehicle = '/bids/vehicle';
  static const String bidsProperty = '/bids/property';

  // Other
  static const String referralLink = '/referral-link';
  static const String suggestionBox = '/suggestion-box';
  static const String category = '/category';

  // ===== USERS & ANALYTICS =====
  static const String users = '/users';
  static const String usersManage = '/users/manage';
  static const String usersExpiredProfiles = '/users/expired-profiles';

  static const String analytics = '/analytics';
  static const String analyticsUsers = '/analytics/users';
  static const String analyticsEmd = '/analytics/emd';

  static const String blog = '/blog';

  // ===== ADMINISTRATION =====
  static const String staff = '/staff';
  static const String staffRoles = '/staff/roles';
  static const String staffMembers = '/staff/members';

  static const String settings = '/settings';
  static const String settingsNewsTicker = '/settings/news-ticker';
  static const String settingsPages = '/settings/pages';
  static const String settingsSocial = '/settings/social';
  static const String settingsGeneral = '/settings/general';

  static GoRouter router(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: login,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isLoggedIn = authState.isAuthenticated;
        final isLoggingIn = state.matchedLocation == login;

        if (!isLoggedIn && !isLoggingIn) {
          return login;
        }

        if (isLoggedIn && isLoggingIn) {
          return dashboard;
        }

        return null;
      },
      routes: [
        // Login Route
        GoRoute(
          path: login,
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),

        // Dashboard Shell with nested routes
        ShellRoute(
          builder: (context, state, child) {
            return DashboardShell(
              currentRoute: state.matchedLocation,
              child: child,
            );
          },
          routes: [
            // Dashboard
            GoRoute(
              path: dashboard,
              name: 'dashboard',
              builder: (context, state) => const DashboardPage(),
            ),

            // ===== VEHICLE AUCTIONS (with shared AuctionBloc) =====
            ShellRoute(
              builder: (context, state, child) {
                // Provide AuctionBloc for all vehicle auction routes
                return BlocProvider<AuctionBloc>(
                  create: (_) => sl<AuctionBloc>()..add(const auction_events.LoadCategoriesRequested()),
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  path: vehicleAuctions,
                  redirect: (context, state) => vehicleAuctionsActive,
                ),
                GoRoute(
                  path: vehicleAuctionsCreate,
                  name: 'vehicle-auctions-create',
                  builder: (context, state) => const CreateAuctionPage(),
                ),
                GoRoute(
                  path: vehicleAuctionsActive,
                  name: 'vehicle-auctions-active',
                  builder: (context, state) => const ActiveAuctionsPage(),
                ),
                GoRoute(
                  path: vehicleAuctionsInactive,
                  name: 'vehicle-auctions-inactive',
                  builder: (context, state) => const InactiveAuctionsPage(),
                ),
                GoRoute(
                  path: vehicleAuctionsUploadImages,
                  name: 'vehicle-auctions-upload-images',
                  builder: (context, state) => const _ComingSoonPage(
                    title: 'Upload Images',
                    description: 'Upload vehicle images as ZIP file',
                    icon: Icons.photo_library_outlined,
                  ),
                ),
                GoRoute(
                  path: vehicleAuctionsBidReport,
                  name: 'vehicle-auctions-bid-report',
                  builder: (context, state) => const _ComingSoonPage(
                    title: 'Bid Report',
                    description: 'View and manage bid reports',
                    icon: Icons.assessment_outlined,
                  ),
                ),
                GoRoute(
                  path: vehicleAuctionsAccessUsers,
                  name: 'vehicle-auctions-access-users',
                  builder: (context, state) => const _ComingSoonPage(
                    title: 'Access Users',
                    description: 'Manage users with access to vehicle auctions',
                    icon: Icons.people_outline,
                  ),
                ),
                GoRoute(
                  path: vehicleAuctionsHighestBids,
                  name: 'vehicle-auctions-highest-bids',
                  builder: (context, state) => const _ComingSoonPage(
                    title: 'Highest Bids',
                    description: 'View highest bids across all vehicle auctions',
                    icon: Icons.trending_up,
                  ),
                ),
                GoRoute(
                  path: vehicleAuctionDetail,
                  name: 'vehicle-auction-detail',
                  builder: (context, state) {
                    final auctionId = state.pathParameters['id']!;
                    return AuctionDetailPage(auctionId: auctionId);
                  },
                ),
                GoRoute(
                  path: vehicleAuctionEdit,
                  name: 'vehicle-auction-edit',
                  builder: (context, state) {
                    final auctionId = state.pathParameters['id']!;
                    return CreateAuctionPage(auctionId: auctionId);
                  },
                ),
              ],
            ),

            // ===== PROPERTY AUCTIONS =====
            GoRoute(
              path: propertyAuctions,
              redirect: (context, state) => propertyAuctionsActive,
            ),
            GoRoute(
              path: propertyAuctionsCreate,
              name: 'property-auctions-create',
              builder: (context, state) => const _ComingSoonPage(
                title: 'Create Property Auction',
                description: 'Create a new property auction listing',
                icon: Icons.add_home_work,
              ),
            ),
            GoRoute(
              path: propertyAuctionsActive,
              name: 'property-auctions-active',
              builder: (context, state) => const _ComingSoonPage(
                title: 'Active Property Auctions',
                description: 'View and manage active property auctions',
                icon: Icons.home_work,
              ),
            ),
            GoRoute(
              path: propertyAuctionsInactive,
              name: 'property-auctions-inactive',
              builder: (context, state) => const _ComingSoonPage(
                title: 'Inactive Property Auctions',
                description: 'View inactive and expired property auctions',
                icon: Icons.home_work_outlined,
              ),
            ),
            GoRoute(
              path: propertyAuctionsUserSurvey,
              name: 'property-auctions-user-survey',
              builder: (context, state) => const _ComingSoonPage(
                title: 'User Survey List',
                description: 'View interested users and survey data',
                icon: Icons.poll_outlined,
              ),
            ),

            // ===== CAR BAZAAR =====
            GoRoute(
              path: carBazaar,
              redirect: (context, state) => carBazaarAll,
            ),
            GoRoute(
              path: carBazaarAll,
              name: 'car-bazaar-all',
              builder: (context, state) => const _ComingSoonPage(
                title: 'All Cars',
                description: 'Browse all cars listed in the bazaar',
                icon: Icons.directions_car,
              ),
            ),
            GoRoute(
              path: carBazaarAdd,
              name: 'car-bazaar-add',
              builder: (context, state) => const _ComingSoonPage(
                title: 'Add Car',
                description: 'Add a new car to the bazaar',
                icon: Icons.add_circle_outline,
              ),
            ),

            // ===== MANAGEMENT =====
            GoRoute(
              path: banners,
              name: 'banners',
              builder: (context, state) => const _ComingSoonPage(
                title: 'Banner Management',
                description: 'Manage promotional banners across the app',
                icon: Icons.view_carousel,
              ),
            ),
            GoRoute(
              path: kycDocuments,
              name: 'kyc-documents',
              builder: (context, state) => const _ComingSoonPage(
                title: 'KYC Documents',
                description: 'Review and verify user KYC documents',
                icon: Icons.verified_user,
              ),
            ),

            // ===== BIDS =====
            GoRoute(
              path: bids,
              redirect: (context, state) => bidsVehicle,
            ),
            GoRoute(
              path: bidsVehicle,
              name: 'bids-vehicle',
              builder: (context, state) => const _ComingSoonPage(
                title: 'Vehicle Bids',
                description: 'View all user bids and winning transactions on vehicle auctions',
                icon: Icons.directions_car_outlined,
              ),
            ),
            GoRoute(
              path: bidsProperty,
              name: 'bids-property',
              builder: (context, state) => const _ComingSoonPage(
                title: 'Property Bids',
                description: 'View all bids on property auctions',
                icon: Icons.real_estate_agent,
              ),
            ),

            // ===== OTHER MANAGEMENT =====
            GoRoute(
              path: referralLink,
              name: 'referral-link',
              builder: (context, state) => BlocProvider<ReferralBloc>(
                create: (_) => sl<ReferralBloc>(),
                child: const ReferralLinkPage(),
              ),
            ),

            // ===== SUGGESTION BOX (with SuggestionBloc) =====
            GoRoute(
              path: suggestionBox,
              name: 'suggestion-box',
              builder: (context, state) => BlocProvider<SuggestionBloc>(
                create: (_) => sl<SuggestionBloc>(),
                child: const SuggestionBoxPage(),
              ),
            ),

            // ===== CATEGORY (with CategoryBloc) =====
            GoRoute(
              path: category,
              name: 'category',
              builder: (context, state) => BlocProvider<CategoryBloc>(
                create: (_) => sl<CategoryBloc>()..add(const category_events.LoadCategoriesRequested()),
                child: const CategoryPage(),
              ),
            ),

            // ===== USERS & ANALYTICS =====
            GoRoute(
              path: users,
              redirect: (context, state) => usersManage,
            ),
            GoRoute(
              path: usersManage,
              name: 'users-manage',
              builder: (context, state) => const _ComingSoonPage(
                title: 'Manage Users',
                description: 'View and manage all user accounts',
                icon: Icons.manage_accounts,
              ),
            ),
            GoRoute(
              path: usersExpiredProfiles,
              name: 'users-expired-profiles',
              builder: (context, state) => const _ComingSoonPage(
                title: 'Expired Profiles',
                description: 'View users with expired subscriptions',
                icon: Icons.person_off,
              ),
            ),

            GoRoute(
              path: analytics,
              redirect: (context, state) => analyticsUsers,
            ),
            GoRoute(
              path: analyticsUsers,
              name: 'analytics-users',
              builder: (context, state) => const _ComingSoonPage(
                title: 'User Analytics',
                description: 'View user engagement and activity metrics',
                icon: Icons.analytics,
              ),
            ),
            GoRoute(
              path: analyticsEmd,
              name: 'analytics-emd',
              builder: (context, state) => const _ComingSoonPage(
                title: 'EMD Analytics',
                description: 'Track Earnest Money Deposit statistics',
                icon: Icons.account_balance_wallet,
              ),
            ),

            GoRoute(
              path: blog,
              name: 'blog',
              builder: (context, state) => const _ComingSoonPage(
                title: 'Blog Section',
                description: 'Create and manage blog posts',
                icon: Icons.article,
              ),
            ),

            // ===== ADMINISTRATION (with shared StaffBloc) =====
            ShellRoute(
              builder: (context, state, child) {
                return BlocProvider<StaffBloc>(
                  create: (_) => sl<StaffBloc>(),
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  path: staff,
                  redirect: (context, state) => staffMembers,
                ),
                GoRoute(
                  path: staffRoles,
                  name: 'staff-roles',
                  builder: (context, state) => const StaffManagementPage(initialTab: 1),
                ),
                GoRoute(
                  path: staffMembers,
                  name: 'staff-members',
                  builder: (context, state) => const StaffManagementPage(initialTab: 0),
                ),
              ],
            ),

            // ===== SETTINGS (with shared SettingsBloc) =====
            ShellRoute(
              builder: (context, state, child) {
                return BlocProvider<SettingsBloc>(
                  create: (_) => sl<SettingsBloc>()..add(const settings_events.LoadSettingsRequested()),
                  child: child,
                );
              },
              routes: [
                GoRoute(
                  path: settings,
                  redirect: (context, state) => settingsGeneral,
                ),
                GoRoute(
                  path: settingsNewsTicker,
                  name: 'settings-news-ticker',
                  builder: (context, state) => const _ComingSoonPage(
                    title: 'App News Ticker',
                    description: 'Manage the scrolling news ticker displayed in the app',
                    icon: Icons.rss_feed,
                  ),
                ),
                GoRoute(
                  path: settingsPages,
                  name: 'settings-pages',
                  redirect: (context, state) => settingsGeneral,
                ),
                GoRoute(
                  path: settingsSocial,
                  name: 'settings-social',
                  redirect: (context, state) => settingsGeneral,
                ),
                GoRoute(
                  path: settingsGeneral,
                  name: 'settings-general',
                  builder: (context, state) => const GeneralSettingsPage(),
                ),
              ],
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => _ErrorPage(location: state.matchedLocation),
    );
  }
}

// Helper class to refresh GoRouter when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    stream.listen((_) {
      notifyListeners();
    });
  }
}

// Coming Soon page for routes not yet implemented
class _ComingSoonPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _ComingSoonPage({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.construction,
                    size: 20,
                    color: Colors.amber[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: Colors.amber[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Error page with navigation options
class _ErrorPage extends StatelessWidget {
  final String location;

  const _ErrorPage({required this.location});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Page Not Found',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'The page "$location" does not exist.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.dashboard),
                icon: const Icon(Icons.home),
                label: const Text('Go to Dashboard'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
