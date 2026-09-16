import 'package:news_app/core/resources/failure.dart';

const int kArticleTitleMaxLength = 120;
const int kArticleBodyMaxLength = 20000;

ValidationFailure? validateArticleContent(String title, String body) {
  if (title.trim().isEmpty) {
    return const ValidationFailure('El título no puede estar vacío.');
  }
  if (title.length > kArticleTitleMaxLength) {
    return ValidationFailure(
      'El título no puede superar los $kArticleTitleMaxLength caracteres.',
    );
  }
  if (body.trim().isEmpty) {
    return const ValidationFailure('El cuerpo del artículo no puede estar vacío.');
  }
  if (body.length > kArticleBodyMaxLength) {
    return ValidationFailure(
      'El cuerpo no puede superar los $kArticleBodyMaxLength caracteres.',
    );
  }
  return null;
}
