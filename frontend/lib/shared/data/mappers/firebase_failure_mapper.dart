import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app/core/resources/failure.dart';

Failure mapFirebaseAuthExceptionToFailure(FirebaseAuthException exception) {
  switch (exception.code) {
    case 'network-request-failed':
      return NetworkFailure(exception.message ?? 'Error de red.');
    case 'invalid-email':
    case 'user-disabled':
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return AuthFailure(exception.message ?? 'Email o contraseña incorrectos.');
    case 'email-already-in-use':
      return AuthFailure(exception.message ?? 'Ya existe una cuenta con este email.');
    case 'weak-password':
      return AuthFailure(exception.message ?? 'La contraseña es demasiado débil.');
    default:
      return AuthFailure(exception.message ?? 'Error de autenticación.');
  }
}

Failure mapFirebaseExceptionToFailure(FirebaseException exception) {
  if (exception.code == 'unavailable' || exception.code == 'network-request-failed') {
    return NetworkFailure(exception.message ?? 'Error de red.');
  }
  if (exception.plugin == 'firebase_storage') {
    return StorageFailure(exception.message ?? 'Error de almacenamiento.');
  }
  return ServerFailure(exception.message ?? 'Error del servidor.');
}
