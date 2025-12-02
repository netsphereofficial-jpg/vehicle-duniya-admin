import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.email,
    this.errorMessage,
  });

  const AuthState.initial() : this();

  const AuthState.loading()
      : this(status: AuthStatus.loading);

  const AuthState.authenticated({
    required String userId,
    required String email,
  }) : this(
          status: AuthStatus.authenticated,
          userId: userId,
          email: email,
        );

  const AuthState.unauthenticated()
      : this(status: AuthStatus.unauthenticated);

  const AuthState.error(String message)
      : this(
          status: AuthStatus.error,
          errorMessage: message,
        );

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;

  @override
  List<Object?> get props => [status, userId, email, errorMessage];
}
