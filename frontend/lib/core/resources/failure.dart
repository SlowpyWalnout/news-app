/// Stable, translatable identifier for a [Failure], independent of
/// [Failure.message] (which may carry a raw SDK string, e.g. Firebase's
/// English exception text). The presentation layer maps [code] to a
/// localized string; domain/data stay free of l10n imports.
enum FailureCode {
  network,
  invalidCredentials,
  emailAlreadyInUse,
  weakPassword,
  storage,
  server,
  cancelled,
  unknown,
}

abstract class Failure {
  final String message;
  final FailureCode code;

  const Failure(this.message, {this.code = FailureCode.unknown});
}

class ServerFailure extends Failure {
  const ServerFailure(super.message) : super(code: FailureCode.server);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message) : super(code: FailureCode.network);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

class StorageFailure extends Failure {
  const StorageFailure(super.message) : super(code: FailureCode.storage);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// User dismissed the Google account picker; not a real error, so the UI
/// should stay silent instead of showing a submit-error banner.
class AuthCancelledFailure extends Failure {
  const AuthCancelledFailure() : super('', code: FailureCode.cancelled);
}
