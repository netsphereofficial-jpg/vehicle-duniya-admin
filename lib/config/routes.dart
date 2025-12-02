import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/dashboard/presentation/pages/dashboard_shell.dart';
import '../features/vehicle_auction/presentation/pages/active_auctions_page.dart';
import '../features/vehicle_auction/presentation/pages/create_auction_page.dart';
import '../features/vehicle_auction/presentation/pages/inactive_auctions_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String vehicles = '/vehicles';
  static const String properties = '/properties';
  static const String carBazaar = '/car-bazaar';
  static const String users = '/users';
  static const String appConfig = '/app-config';

  // Vehicle Auction Routes
  static const String createAuction = '/vehicles/auctions/create';
  static const String activeAuctions = '/vehicles/auctions/active';
  static const String inactiveAuctions = '/vehicles/auctions/inactive';
  static const String auctionDetail = '/vehicles/auctions/:id';
  static const String editAuction = '/vehicles/auctions/:id/edit';
  static const String auctionAccessUsers = '/vehicles/auctions/access-users';
  static const String metaHighestBid = '/vehicles/auctions/highest-bids';

  static GoRouter router(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: login,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isLoggedIn = authState.isAuthenticated;
        final isLoggingIn = state.matchedLocation == login;

        // If not logged in and not on login page, redirect to login
        if (!isLoggedIn && !isLoggingIn) {
          return login;
        }

        // If logged in and on login page, redirect to dashboard
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
            GoRoute(
              path: dashboard,
              name: 'dashboard',
              builder: (context, state) => const DashboardPage(),
            ),
            // Vehicle routes - redirect base path to active auctions
            GoRoute(
              path: vehicles,
              name: 'vehicles',
              redirect: (context, state) => activeAuctions,
            ),
            GoRoute(
              path: createAuction,
              name: 'create-auction',
              builder: (context, state) => const CreateAuctionPage(),
            ),
            GoRoute(
              path: activeAuctions,
              name: 'active-auctions',
              builder: (context, state) => const ActiveAuctionsPage(),
            ),
            GoRoute(
              path: inactiveAuctions,
              name: 'inactive-auctions',
              builder: (context, state) => const InactiveAuctionsPage(),
            ),
            GoRoute(
              path: auctionDetail,
              name: 'auction-detail',
              builder: (context, state) {
                final auctionId = state.pathParameters['id']!;
                return _PlaceholderPage(title: 'Auction: $auctionId');
              },
            ),
            GoRoute(
              path: editAuction,
              name: 'edit-auction',
              builder: (context, state) {
                final auctionId = state.pathParameters['id']!;
                return CreateAuctionPage(auctionId: auctionId);
              },
            ),
            GoRoute(
              path: auctionAccessUsers,
              name: 'auction-access-users',
              builder: (context, state) => const _PlaceholderPage(title: 'Auction Access Users'),
            ),
            GoRoute(
              path: metaHighestBid,
              name: 'meta-highest-bid',
              builder: (context, state) => const _PlaceholderPage(title: 'Highest Bids'),
            ),
            GoRoute(
              path: properties,
              name: 'properties',
              builder: (context, state) => const _PlaceholderPage(title: 'Properties'),
            ),
            GoRoute(
              path: carBazaar,
              name: 'car-bazaar',
              builder: (context, state) => const _PlaceholderPage(title: 'Car Bazaar'),
            ),
            GoRoute(
              path: users,
              name: 'users',
              builder: (context, state) => const _PlaceholderPage(title: 'Users'),
            ),
            GoRoute(
              path: appConfig,
              name: 'app-config',
              builder: (context, state) => const _PlaceholderPage(title: 'App Config'),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page not found: ${state.matchedLocation}'),
        ),
      ),
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

// Placeholder page for routes not yet implemented
class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This section is under development',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
    );
  }
}
