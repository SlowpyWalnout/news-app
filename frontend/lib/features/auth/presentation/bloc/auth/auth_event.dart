import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched once at app start to resolve whether a session already exists.
class AuthSessionChecked extends AuthEvent {
  const AuthSessionChecked();
}

class AuthSignInSubmitted extends AuthEvent {
  const AuthSignInSubmitted({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Fired on every register keystroke so the bloc can recompute live field
/// errors via the domain validators (only blocs may touch domain code).
class AuthRegisterFieldsChanged extends AuthEvent {
  const AuthRegisterFieldsChanged({
    required this.displayName,
    required this.email,
    required this.password,
  });

  final String displayName;
  final String email;
  final String password;

  @override
  List<Object?> get props => [displayName, email, password];
}

class AuthSignUpSubmitted extends AuthEvent {
  const AuthSignUpSubmitted({
    required this.displayName,
    required this.email,
    required this.password,
  });

  final String displayName;
  final String email;
  final String password;

  @override
  List<Object?> get props => [displayName, email, password];
}

class AuthSignedOut extends AuthEvent {
  const AuthSignedOut();
}
