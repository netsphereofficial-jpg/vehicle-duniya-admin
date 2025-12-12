import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/category/data/repositories/category_repository_impl.dart';
import '../../features/category/domain/repositories/category_repository.dart';
import '../../features/category/presentation/bloc/category_bloc.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/staff/data/repositories/staff_repository_impl.dart';
import '../../features/staff/domain/repositories/staff_repository.dart';
import '../../features/staff/presentation/bloc/staff_bloc.dart';
import '../../features/referral_link/data/repositories/referral_repository_impl.dart';
import '../../features/referral_link/domain/repositories/referral_repository.dart';
import '../../features/referral_link/presentation/bloc/referral_bloc.dart';
import '../../features/suggestion_box/data/repositories/suggestion_repository_impl.dart';
import '../../features/suggestion_box/domain/repositories/suggestion_repository.dart';
import '../../features/suggestion_box/presentation/bloc/suggestion_bloc.dart';
import '../../features/vehicle_auction/data/repositories/auction_repository_impl.dart';
import '../../features/vehicle_auction/domain/repositories/auction_repository.dart';
import '../../features/vehicle_auction/presentation/bloc/auction_bloc.dart';
import '../services/local_image_cache.dart';
import '../services/permission_service.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
/// Call this in main() before runApp()
Future<void> initDependencies() async {
  // ============ External Services ============
  // SharedPreferences (must be initialized before use)
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // Local Image Cache
  sl.registerLazySingleton<LocalImageCache>(
    () => LocalImageCache(prefs: sl<SharedPreferences>()),
  );

  // Permission Service (for role-based access control)
  sl.registerLazySingleton<PermissionService>(() => PermissionService());

  // Firebase services (singletons - same instance throughout app)
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // ============ Repositories ============
  // Repositories are singletons - one instance shared across the app

  sl.registerLazySingleton<AuctionRepository>(
    () => AuctionRepositoryImpl(
      firestore: sl<FirebaseFirestore>(),
      storage: sl<FirebaseStorage>(),
    ),
  );

  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      firestore: sl<FirebaseFirestore>(),
      storage: sl<FirebaseStorage>(),
    ),
  );

  sl.registerLazySingleton<StaffRepository>(
    () => StaffRepositoryImpl(
      firestore: sl<FirebaseFirestore>(),
      auth: sl<FirebaseAuth>(),
    ),
  );

  sl.registerLazySingleton<SuggestionRepository>(
    () => SuggestionRepositoryImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerLazySingleton<ReferralRepository>(
    () => ReferralRepositoryImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // ============ BLoCs ============
  // Global BLoCs (singleton) - needed throughout the app
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(firebaseAuth: sl<FirebaseAuth>()),
  );

  // Feature BLoCs (factory) - new instance each time, disposed when page closes
  sl.registerFactory<AuctionBloc>(
    () => AuctionBloc(
      repository: sl<AuctionRepository>(),
      auth: sl<FirebaseAuth>(),
    ),
  );

  sl.registerFactory<CategoryBloc>(
    () => CategoryBloc(
      repository: sl<CategoryRepository>(),
    ),
  );

  sl.registerFactory<SettingsBloc>(
    () => SettingsBloc(
      repository: sl<SettingsRepository>(),
    ),
  );

  sl.registerFactory<StaffBloc>(
    () => StaffBloc(
      repository: sl<StaffRepository>(),
    ),
  );

  sl.registerFactory<SuggestionBloc>(
    () => SuggestionBloc(
      repository: sl<SuggestionRepository>(),
    ),
  );

  sl.registerFactory<ReferralBloc>(
    () => ReferralBloc(
      repository: sl<ReferralRepository>(),
      auth: sl<FirebaseAuth>(),
    ),
  );
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
}
