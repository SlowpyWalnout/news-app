import 'package:news_app/core/resources/failure.dart';

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

const int kPasswordMinLength = 6;
const int kDisplayNameMaxLength = 60;

ValidationFailure? validateEmailAndPassword(String email, String password) {
  if (!_emailPattern.hasMatch(email)) {
    return const ValidationFailure('El email no es válido.');
  }
  if (password.length < kPasswordMinLength) {
    return ValidationFailure(
      'La contraseña debe tener al menos $kPasswordMinLength caracteres.',
    );
  }
  return null;
}

ValidationFailure? validateDisplayName(String displayName) {
  if (displayName.trim().isEmpty) {
    return const ValidationFailure('El nombre no puede estar vacío.');
  }
  if (displayName.length > kDisplayNameMaxLength) {
    return ValidationFailure(
      'El nombre no puede superar los $kDisplayNameMaxLength caracteres.',
    );
  }
  return null;
}
