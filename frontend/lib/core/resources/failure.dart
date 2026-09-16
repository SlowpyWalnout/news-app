abstract class Failure {
  final String message;

  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// User dismissed the Google account picker; not a real error, so the UI
/// should stay silent instead of showing a submit-error banner.
class AuthCancelledFailure extends Failure {
  const AuthCancelledFailure() : super('');
}
