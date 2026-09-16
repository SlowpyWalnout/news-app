import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/article_composer/domain/use_cases/article_content_validator.dart';

void main() {
  group('validateArticleContent', () {
    test('rechaza título vacío', () {
      final result = validateArticleContent('   ', 'cuerpo válido');
      expect(result, isNotNull);
    });

    test('rechaza título que excede el máximo', () {
      final longTitle = 'a' * (kArticleTitleMaxLength + 1);
      final result = validateArticleContent(longTitle, 'cuerpo válido');
      expect(result, isNotNull);
    });

    test('rechaza cuerpo vacío', () {
      final result = validateArticleContent('Título', '   ');
      expect(result, isNotNull);
    });

    test('rechaza cuerpo que excede el máximo', () {
      final longBody = 'a' * (kArticleBodyMaxLength + 1);
      final result = validateArticleContent('Título', longBody);
      expect(result, isNotNull);
    });

    test('acepta título y cuerpo válidos', () {
      final result = validateArticleContent('Título válido', 'Cuerpo con contenido suficiente.');
      expect(result, isNull);
    });
  });
}
