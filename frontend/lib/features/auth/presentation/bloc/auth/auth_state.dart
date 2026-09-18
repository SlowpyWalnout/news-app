import 'package:equatable/equatable.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/features/auth/domain/entities/user_entity.dart';

// signingIn/signingOut are distinct from loading (not reused by
// login/register form submission) so AuthGate can show a splash for these
// two transitions specifically, without touching the "stay on Login while
// it submits" behavior loading already has.
enum AuthStatus { initial, loading, authenticated, unauthenticated, signingIn, signingOut }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.submitError,
    this.registerNameError,
    this.registerEmailError,
    this.registerPasswordError,
    this.registerPasswordValid = false,
    this.loginEmailValid = true,
    this.loginPasswordValid = true,
  });

  final AuthStatus status;
  final UserEntity? user;

  /// Set after a failed sign-in/sign-up submit (credential/network/etc.).
  final Failure? submitError;

  /// Live register-field validation, recomputed on every keystroke.
  final String? registerNameError;
  final String? registerEmailError;
  final String? registerPasswordError;
  final bool registerPasswordValid;

  /// Live login-field validation, recomputed on every keystroke — `true`
  /// while the field is empty (nothing to complain about yet) or valid.
  final bool loginEmailValid;
  final bool loginPasswordValid;

  const AuthState.initial() : this();

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    Failure? submitError,
    bool clearSubmitError = false,
    String? registerNameError,
    String? registerEmailError,
    String? registerPasswordError,
    bool? registerPasswordValid,
    bool? loginEmailValid,
    bool? loginPasswordValid,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      registerNameError: registerNameError,
      registerEmailError: registerEmailError,
      registerPasswordError: registerPasswordError,
      registerPasswordValid: registerPasswordValid ?? this.registerPasswordValid,
      loginEmailValid: loginEmailValid ?? this.loginEmailValid,
      loginPasswordValid: loginPasswordValid ?? this.loginPasswordValid,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        submitError,
        registerNameError,
        registerEmailError,
        registerPasswordError,
        registerPasswordValid,
        loginEmailValid,
        loginPasswordValid,
      ];
}
