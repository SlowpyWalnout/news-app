import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/features/article_composer/data/models/authored_article_model.dart';
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

  test('fromEntity then toFirestore round-trips the content fields', () {
    final entity = authoredArticle('a1', title: 'Hola', searchKeywords: ['hola']);
    final map = AuthoredArticleModel.fromEntity(entity).toFirestore();

    expect(map['title'], 'Hola');
    expect(map['searchKeywords'], ['hola']);
    expect(map['status'], 'published');
    expect(map['category'], 'general');
  });
}
