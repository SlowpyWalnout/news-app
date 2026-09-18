import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/features/article_composer/data/models/authored_article_model.dart';
import 'package:news_app/features/article_composer/domain/entities/article_source.dart';
import 'package:news_app/features/moderation/domain/entities/moderation_state.dart';

import '../../../../helpers/helpers.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  group('fromFirestore', () {
    test('maps every field of a full document, including Timestamp conversion', () {
      final createdAt = DateTime(2026, 1, 1);
      final publishedAt = DateTime(2026, 1, 2);
      final doc = MockDocumentSnapshot();
      when(() => doc.id).thenReturn('a1');
      when(() => doc.data()).thenReturn(firestoreArticleData(
        createdAt: createdAt,
        publishedAt: publishedAt,
        thumbnailURL: 'https://x/y.jpg',
        thumbnailPath: 'media/articles/u1/a1/y.jpg',
        searchKeywords: ['flutter'],
        reportCount: 2,
        moderationState: 'suspended',
        suspendedAt: createdAt,
      ));

      final model = AuthoredArticleModel.fromFirestore(doc);

      expect(model.id, 'a1');
      expect(model.createdAt, createdAt);
      expect(model.publishedAt, publishedAt);
      expect(model.status.name, 'published');
      expect(model.category.name, 'general');
      expect(model.thumbnailURL, 'https://x/y.jpg');
      expect(model.searchKeywords, ['flutter']);
      expect(model.reportCount, 2);
      expect(model.moderationState, ModerationState.suspended);
      expect(model.suspendedAt, createdAt);
    });

    test('a minimal document falls back to documented defaults for every optional field', () {
      final createdAt = DateTime(2026, 1, 1);
      final doc = MockDocumentSnapshot();
      when(() => doc.id).thenReturn('a1');
      when(() => doc.data()).thenReturn(firestoreArticleData(createdAt: createdAt, minimal: true));

      final model = AuthoredArticleModel.fromFirestore(doc);

      expect(model.publishedAt, isNull);
      expect(model.thumbnailURL, isNull);
      expect(model.thumbnailPath, isNull);
      expect(model.searchKeywords, isEmpty);
      expect(model.reportCount, 0);
      expect(model.moderationState, isNull);
      expect(model.suspendedAt, isNull);
      expect(model.approvedAt, isNull);
    });

    test('an unknown status name throws ArgumentError', () {
      final doc = MockDocumentSnapshot();
      when(() => doc.id).thenReturn('a1');
      when(() => doc.data()).thenReturn(firestoreArticleData(status: 'archived'));

      expect(() => AuthoredArticleModel.fromFirestore(doc), throwsArgumentError);
    });

    test('a community article (no source field) maps source-related fields to defaults', () {
      final doc = MockDocumentSnapshot();
      when(() => doc.id).thenReturn('a1');
      when(() => doc.data()).thenReturn(firestoreArticleData());

      final model = AuthoredArticleModel.fromFirestore(doc);

      expect(model.source, isNull);
      expect(model.isExternal, isFalse);
      expect(model.sourceName, isNull);
      expect(model.sourceUrl, isNull);
      expect(model.hasFullBody, isFalse);
      expect(model.lang, isNull);
    });

    test('an external headline maps every source field', () {
      final doc = MockDocumentSnapshot();
      when(() => doc.id).thenReturn('h1');
      when(() => doc.data()).thenReturn(firestoreArticleData(
        authorId: 'external:guardian',
        authorName: 'The Guardian',
        source: 'guardian',
        sourceName: 'The Guardian',
        sourceUrl: 'https://www.theguardian.com/some-article',
        hasFullBody: true,
        lang: 'en',
      ));

      final model = AuthoredArticleModel.fromFirestore(doc);

      expect(model.source, ArticleSource.guardian);
      expect(model.isExternal, isTrue);
      expect(model.sourceName, 'The Guardian');
      expect(model.sourceUrl, 'https://www.theguardian.com/some-article');
      expect(model.hasFullBody, isTrue);
      expect(model.lang, 'en');
    });
  });

  test('toFirestore emits exactly the 10 content keys — no server-fixed timestamps', () {
    final model = AuthoredArticleModel.fromEntity(authoredArticle('a1'));

    final map = model.toFirestore();

    expect(map.keys.toSet(), {
      'authorId',
      'authorName',
      'authorPhotoURL',
      'title',
      'body',
      'status',
      'category',
      'thumbnailURL',
      'thumbnailPath',
      'searchKeywords',
    });
  });

  test('toFirestore never writes source fields, even for an external entity — the client can never falsify the badge', () {
    final external = authoredArticle('h1', source: ArticleSource.guardian, sourceName: 'The Guardian', hasFullBody: true);
    final map = AuthoredArticleModel.fromEntity(external).toFirestore();

    expect(map.containsKey('source'), isFalse);
    expect(map.containsKey('sourceName'), isFalse);
    expect(map.containsKey('sourceUrl'), isFalse);
    expect(map.containsKey('hasFullBody'), isFalse);
    expect(map.containsKey('lang'), isFalse);
  });

  test('fromEntity then toFirestore round-trips the content fields', () {
    final entity = authoredArticle('a1', title: 'Hola', searchKeywords: ['hola']);
    final map = AuthoredArticleModel.fromEntity(entity).toFirestore();

    expect(map['title'], 'Hola');
    expect(map['searchKeywords'], ['hola']);
    expect(map['status'], 'published');
    expect(map['category'], 'general');
  });
}
