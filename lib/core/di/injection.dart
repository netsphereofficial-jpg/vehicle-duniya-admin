import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/category/data/repositories/category_repository_impl.dart';
import '../../features/category/domain/repositories/category_repository.dart';
import '../../features/category/presentation/bloc/category_bloc.dart';
import '../../features/vehicle_auction/data/repositories/auction_repository_impl.dart';
import '../../features/vehicle_auction/domain/repositories/auction_repository.dart';
import '../../features/vehicle_auction/presentation/bloc/auction_bloc.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
/// Call this in main() before runApp()
Future<void> initDependencies() async {
  // ============ External Services ============
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
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
}
