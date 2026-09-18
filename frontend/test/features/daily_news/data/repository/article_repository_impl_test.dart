import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/features/daily_news/data/models/article.dart';
import 'package:news_app/features/daily_news/data/repository/article_repository_impl.dart';

import '../../../../helpers/helpers.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  late MockAppDatabase db;
  late MockArticleDao dao;
  late ArticleRepositoryImpl repo;

  setUp(() {
    db = MockAppDatabase();
    dao = MockArticleDao();
    when(() => db.articleDAO).thenReturn(dao);
    repo = ArticleRepositoryImpl(db);
  });

  test('getReadLaterArticles delegates to the DAO', () async {
    when(() => dao.getArticles()).thenAnswer((_) async => [ArticleModel.fromEntity(readLaterArticle())]);

    final result = await repo.getReadLaterArticles();

    expect(result, hasLength(1));
    verify(() => dao.getArticles()).called(1);
  });

  test('removeFromReadLater passes the model through to the DAO', () async {
    when(() => dao.deleteArticle(any())).thenAnswer((_) async {});

    await repo.removeFromReadLater(readLaterArticle(id: 7));

    final captured = verify(() => dao.deleteArticle(captureAny())).captured.single as ArticleModel;
    expect(captured.id, 7);
  });

  test('markReadLaterArticleAsRead delegates the id to the DAO', () async {
    when(() => dao.markAsRead(any())).thenAnswer((_) async {});

    await repo.markReadLaterArticleAsRead(7);

    verify(() => dao.markAsRead(7)).called(1);
  });

  group('addToReadLater', () {
    test('skips the insert when a row with the same sourceId already exists', () async {
      when(() => dao.findBySourceId('src-1')).thenAnswer((_) async => ArticleModel.fromEntity(readLaterArticle(id: 1, sourceId: 'src-1')));

      await repo.addToReadLater(readLaterArticle(sourceId: 'src-1'));

      verify(() => dao.findBySourceId('src-1')).called(1);
      verifyNever(() => dao.insertArticle(any()));
    });

    test('inserts when no row matches the sourceId', () async {
      when(() => dao.findBySourceId('src-1')).thenAnswer((_) async => null);
      when(() => dao.insertArticle(any())).thenAnswer((_) async {});

      await repo.addToReadLater(readLaterArticle(sourceId: 'src-1'));

      verify(() => dao.insertArticle(any())).called(1);
    });

    test('inserts directly without checking when sourceId is null', () async {
      when(() => dao.insertArticle(any())).thenAnswer((_) async {});

      await repo.addToReadLater(readLaterArticle(sourceId: null));

      verifyNever(() => dao.findBySourceId(any()));
      verify(() => dao.insertArticle(any())).called(1);
    });
  });
}
