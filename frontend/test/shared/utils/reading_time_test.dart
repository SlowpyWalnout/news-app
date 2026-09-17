import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/shared/utils/reading_time.dart';

void main() {
  test('markdown syntax does not inflate the estimate vs its plain equivalent', () {
    final withSyntax = List.generate(50, (_) => '**word**').join(' ');
    final plain = List.generate(50, (_) => 'word').join(' ');
    expect(estimateReadingMinutes(withSyntax), estimateReadingMinutes(plain));
  });

  test('empty body is clamped to 1 minute', () {
    expect(estimateReadingMinutes(''), 1);
    expect(estimateReadingMinutes('## \n\n> '), 1);
  });
}
