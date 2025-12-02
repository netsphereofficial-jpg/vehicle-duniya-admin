import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'config/routes.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const VehicleDuniyaAdminApp());
}

class VehicleDuniyaAdminApp extends StatefulWidget {
  const VehicleDuniyaAdminApp({super.key});

  @override
  State<VehicleDuniyaAdminApp> createState() => _VehicleDuniyaAdminAppState();
}

class _VehicleDuniyaAdminAppState extends State<VehicleDuniyaAdminApp> {
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc()..add(const AuthCheckRequested());
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
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
