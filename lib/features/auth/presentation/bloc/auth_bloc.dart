import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/app_logger.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const _tag = 'AuthBloc';
  final FirebaseAuth _firebaseAuth;

  AuthBloc({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(const AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'AuthCheckRequested');
    emit(const AuthState.loading());

    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        AppLogger.info(_tag, 'User authenticated: ${user.email}');
        emit(AuthState.authenticated(
          userId: user.uid,
          email: user.email ?? '',
        ));
      } else {
        AppLogger.info(_tag, 'No authenticated user found');
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      AppLogger.error(_tag, 'Auth check failed', e);
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'AuthLoginRequested');
    AppLogger.info(_tag, 'Login attempt for: ${event.email}');
    emit(const AuthState.loading());

    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final user = userCredential.user;
      if (user != null) {
        AppLogger.info(_tag, 'Login successful: ${user.email}');
        emit(AuthState.authenticated(
          userId: user.uid,
          email: user.email ?? '',
        ));
      } else {
        AppLogger.warning(_tag, 'Login failed: No user returned');
        emit(const AuthState.error('Login failed. Please try again.'));
      }
    } on FirebaseAuthException catch (e) {
      AppLogger.error(_tag, 'Firebase Auth error: ${e.code}', e);
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        default:
          message = 'Login failed. Please try again.';
      }
      emit(AuthState.error(message));
    } catch (e) {
      AppLogger.error(_tag, 'Unexpected login error', e);
      emit(AuthState.error('An unexpected error occurred.'));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.blocEvent(_tag, 'AuthLogoutRequested');
    emit(const AuthState.loading());

    try {
      await _firebaseAuth.signOut();
      AppLogger.info(_tag, 'Logout successful');
      emit(const AuthState.unauthenticated());
    } catch (e) {
      AppLogger.error(_tag, 'Logout failed', e);
      emit(AuthState.error('Logout failed: ${e.toString()}'));
    }
  }
}
