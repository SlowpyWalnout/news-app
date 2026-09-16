import 'package:news_app/core/resources/failure.dart';

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

const int kPasswordMinLength = 6;
const int kDisplayNameMaxLength = 60;

bool isValidEmail(String email) => _emailPattern.hasMatch(email);

bool isValidPassword(String password) => password.length >= kPasswordMinLength;

ValidationFailure? validateEmailAndPassword(String email, String password) {
  if (!isValidEmail(email)) {
    return const ValidationFailure('El email no es válido.');
  }
  if (!isValidPassword(password)) {
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
