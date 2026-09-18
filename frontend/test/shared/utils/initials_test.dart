import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/shared/utils/initials.dart';

void main() {
  test('empty or whitespace-only name returns "?"', () {
    expect(initialsFrom(''), '?');
    expect(initialsFrom('   '), '?');
  });

  test('a single token returns its first letter, uppercased', () {
    expect(initialsFrom('rosa'), 'R');
  });

  test('multiple tokens return first+last letter, uppercased', () {
    expect(initialsFrom('rosa perez'), 'RP');
  });

  test('collapsed inner whitespace does not confuse the split', () {
    expect(initialsFrom('rosa    maria   perez'), 'RP');
  });

  test('accented input keeps its accents', () {
    expect(initialsFrom('África Núñez'), 'ÁN');
  });
}
