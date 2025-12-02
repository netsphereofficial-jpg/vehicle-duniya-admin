import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'config/routes.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/vehicle_auction/presentation/bloc/auction_bloc.dart';
import 'features/vehicle_auction/presentation/bloc/auction_event.dart';
import 'features/vehicle_auction/data/repositories/auction_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
  late final AuthBloc _authBloc;
  late final AuctionBloc _auctionBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc()..add(const AuthCheckRequested());
    _auctionBloc = AuctionBloc(
      repository: AuctionRepositoryImpl(),
    )..add(const LoadCategoriesRequested());
  }

  @override
  void dispose() {
    _authBloc.close();
    _auctionBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<AuctionBloc>.value(value: _auctionBloc),
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
