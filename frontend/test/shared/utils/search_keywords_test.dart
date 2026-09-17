import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/shared/utils/search_keywords.dart';

void main() {
  group('searchTokensFor', () {
    test('folds accents to plain ASCII', () {
      expect(searchTokensFor('Guía de Ñandú'), ['guia', 'nandu']);
    });

    test('drops es/en stopwords', () {
      expect(searchTokensFor('de la the of Flutter'), ['flutter']);
    });

    test('keeps 2-letter tokens that are not stopwords', () {
      expect(searchTokensFor('IA JS UX'), ['ia', 'js', 'ux']);
    });

    test('splits on punctuation and markdown syntax', () {
      expect(
        searchTokensFor('## *Título*: futuro-cercano'),
        ['titulo', 'futuro', 'cercano'],
      );
    });

    test('dedupes preserving first-seen order', () {
      expect(searchTokensFor('flutter Flutter FLUTTER dart'), ['flutter', 'dart']);
    });
  });

  group('primarySearchToken', () {
    test('returns the longest token', () {
      expect(primarySearchToken('el nuevo Flutter'), 'flutter');
    });

    test('returns null when only stopwords remain', () {
      expect(primarySearchToken('de la'), isNull);
    });

    test('returns null for an empty or blank query', () {
      expect(primarySearchToken(''), isNull);
      expect(primarySearchToken('   '), isNull);
    });
  });

  group('buildSearchKeywords', () {
    test('30-cap keeps category and author tokens ahead of a long title', () {
      final title = List.generate(40, (i) => 'word${(i + 1).toString().padLeft(2, '0')}')
          .join(' ');
      final result = buildSearchKeywords(
        title: title,
        authorName: 'Author Name',
        categoryName: 'science',
      );
      expect(result.length, 30);
      expect(result.take(3), ['science', 'author', 'name']);
      expect(result.last, 'word27');
    });

    test('shared golden vectors match the Node backfill tokenizer', () {
      final file = File('${Directory.current.path}/../backend/scripts/tokenizer-fixtures.json');
      final vectors = jsonDecode(file.readAsStringSync()) as List<dynamic>;
      expect(vectors, isNotEmpty);
      for (final vector in vectors) {
        final map = vector as Map<String, dynamic>;
        final result = buildSearchKeywords(
          title: map['title'] as String,
          authorName: map['authorName'] as String,
          categoryName: map['category'] as String,
        );
        expect(
          result,
          List<String>.from(map['expected'] as List),
          reason: map['name'] as String,
        );
      }
    });
  });
}
