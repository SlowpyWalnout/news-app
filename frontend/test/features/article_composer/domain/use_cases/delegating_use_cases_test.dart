import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/article_composer/domain/params/list_my_articles_params.dart';
import 'package:news_app/features/article_composer/domain/use_cases/delete_article_use_case.dart';
import 'package:news_app/features/article_composer/domain/use_cases/edit_article_use_case.dart';
import 'package:news_app/features/article_composer/domain/use_cases/get_article_by_id_use_case.dart';
import 'package:news_app/features/article_composer/domain/use_cases/list_my_articles_use_case.dart';
import 'package:news_app/features/article_composer/domain/use_cases/publish_article_use_case.dart';
import 'package:news_app/features/article_composer/domain/use_cases/save_draft_use_case.dart';

import '../../../../helpers/helpers.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  late MockAuthoredArticleRepository repo;

  setUp(() {
    repo = MockAuthoredArticleRepository();
  });

  group('ListMyArticlesUseCase', () {
    test('delegates authorId/cursor to the repository', () async {
      when(() => repo.getMyArticles(any(), cursor: any(named: 'cursor')))
          .thenAnswer((_) async => const DataSuccess(PaginatedResult(items: [])));

      await ListMyArticlesUseCase(repo)(const ListMyArticlesParams(authorId: 'u1', cursor: 'c1'));

      verify(() => repo.getMyArticles('u1', cursor: 'c1')).called(1);
    });
  });

  group('GetArticleByIdUseCase', () {
    test('delegates to the repository', () async {
      when(() => repo.getArticleById(any())).thenAnswer((_) async => DataSuccess(authoredArticle('a1')));

      final result = await GetArticleByIdUseCase(repo)('a1');

      expect(result, isA<DataSuccess>());
    });
  });

  group('DeleteArticleUseCase', () {
    test('delegates to the repository', () async {
      when(() => repo.deleteArticle(any())).thenAnswer((_) async => const DataSuccess(null));

      await DeleteArticleUseCase(repo)('a1');

      verify(() => repo.deleteArticle('a1')).called(1);
    });
  });

  group('EditArticleUseCase', () {
    test('delegates to the repository when content is valid', () async {
      when(() => repo.updateArticle(any())).thenAnswer((_) async => DataSuccess(authoredArticle('a1')));

      final result = await EditArticleUseCase(repo)(authoredArticle('a1', title: 'Título válido'));

      expect(result, isA<DataSuccess>());
    });

    test('short-circuits on an empty body, never touching the repository', () async {
      final result = await EditArticleUseCase(repo)(authoredArticle('a1', body: ''));

      expect(result, isA<DataFailed>());
      expect((result as DataFailed).error, isA<ValidationFailure>());
      verifyNever(() => repo.updateArticle(any()));
    });
  });

  group('PublishArticleUseCase', () {
    test('delegates to the repository when content is valid', () async {
      when(() => repo.publishArticle(any())).thenAnswer((_) async => DataSuccess(authoredArticle('a1')));

      final result = await PublishArticleUseCase(repo)(authoredArticle('a1'));

      expect(result, isA<DataSuccess>());
    });

    test('short-circuits on an empty title, never touching the repository', () async {
      final result = await PublishArticleUseCase(repo)(authoredArticle('a1', title: ''));

      expect(result, isA<DataFailed>());
      verifyNever(() => repo.publishArticle(any()));
    });
  });

  group('SaveDraftUseCase', () {
    test('delegates to the repository even with an empty body — a draft may be half-written', () async {
      when(() => repo.saveDraft(any())).thenAnswer((_) async => DataSuccess(authoredArticle('a1')));

      final result = await SaveDraftUseCase(repo)(authoredArticle('a1', body: ''));

      expect(result, isA<DataSuccess>());
      verify(() => repo.saveDraft(any())).called(1);
    });

    test('short-circuits on a too-long title, never touching the repository', () async {
      final result = await SaveDraftUseCase(repo)(authoredArticle('a1', title: 'x' * 200));

      expect(result, isA<DataFailed>());
      expect((result as DataFailed).error, isA<ValidationFailure>());
      verifyNever(() => repo.saveDraft(any()));
    });
  });
}
