import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/shared/utils/article_excerpt.dart';

void main() {
  test('returns the trimmed body as-is when under maxLength', () {
    expect(articleExcerpt('  Hola mundo  '), 'Hola mundo');
  });

  test('cuts on a word boundary and appends an ellipsis when over maxLength', () {
    final body = 'una palabra ' * 20;
    final result = articleExcerpt(body, maxLength: 20);

    expect(result.endsWith('…'), isTrue);
    expect(result.length, lessThanOrEqualTo(21));
    expect(result.contains(' '), isTrue);
  });

  test('a single long word with no space cuts hard at maxLength', () {
    final body = 'a' * 50;
    final result = articleExcerpt(body, maxLength: 20);

    expect(result, '${'a' * 20}…');
  });

  test('an empty body stays empty', () {
    expect(articleExcerpt('   '), '');
  });
}
