import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection.dart';
import 'config/routes.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize dependencies
  await initDependencies();

  // Print clickable URL for development
  if (kDebugMode) {
    debugPrint('');
    debugPrint('╔════════════════════════════════════════════════════════════╗');
    debugPrint('║                  Vehicle Duniya Admin Panel                ║');
    debugPrint('╠════════════════════════════════════════════════════════════╣');
    debugPrint('║  Open in browser:                                          ║');
    debugPrint('║  http://localhost:8080                                     ║');
    debugPrint('║                                                            ║');
    debugPrint('║  Or try these if port is different:                        ║');
    debugPrint('║  http://localhost:5000                                     ║');
    debugPrint('║  http://localhost:3000                                     ║');
    debugPrint('╚════════════════════════════════════════════════════════════╝');
    debugPrint('');
    developer.log('http://localhost:8080', name: 'APP_URL');
  }

  runApp(const VehicleDuniyaAdminApp());
}

class VehicleDuniyaAdminApp extends StatefulWidget {
  const VehicleDuniyaAdminApp({super.key});

  @override
  State<VehicleDuniyaAdminApp> createState() => _VehicleDuniyaAdminAppState();
}

class _VehicleDuniyaAdminAppState extends State<VehicleDuniyaAdminApp> {
  // Only global BLoCs that are needed throughout the app
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    // Get AuthBloc from service locator and check auth status
    _authBloc = sl<AuthBloc>()..add(const AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Only AuthBloc is global - needed for routing and auth state
        BlocProvider<AuthBloc>.value(value: _authBloc),

        // Other BLoCs (AuctionBloc, CategoryBloc, etc.) are provided
        // at route level - see config/routes.dart
      ],
      child: MaterialApp.router(
        title: 'Vehicle Duniya Admin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRoutes.router(_authBloc),
      ),
    );
  }
}
