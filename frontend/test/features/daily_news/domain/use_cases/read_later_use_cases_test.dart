import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/daily_news/domain/use_cases/add_to_read_later_use_case.dart';
import 'package:news_app/features/daily_news/domain/use_cases/get_read_later_articles_use_case.dart';
import 'package:news_app/features/daily_news/domain/use_cases/mark_read_later_article_as_read_use_case.dart';
import 'package:news_app/features/daily_news/domain/use_cases/remove_from_read_later_use_case.dart';

import '../../../../helpers/helpers.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  late MockArticleRepository repo;

  setUp(() {
    repo = MockArticleRepository();
  });

  group('AddToReadLaterUseCase', () {
    test('delegates to the repository', () async {
      when(() => repo.addToReadLater(any())).thenAnswer((_) async {});
      final article = readLaterArticle();

      await AddToReadLaterUseCase(repo)(article);

      verify(() => repo.addToReadLater(article)).called(1);
    });
  });

  group('GetReadLaterArticlesUseCase', () {
    test('delegates to the repository', () async {
      when(() => repo.getReadLaterArticles()).thenAnswer((_) async => [readLaterArticle()]);

      final result = await GetReadLaterArticlesUseCase(repo)(const NoParams());

      expect(result, hasLength(1));
    });
  });

  group('RemoveFromReadLaterUseCase', () {
    test('delegates to the repository', () async {
      when(() => repo.removeFromReadLater(any())).thenAnswer((_) async {});
      final article = readLaterArticle();

      await RemoveFromReadLaterUseCase(repo)(article);

      verify(() => repo.removeFromReadLater(article)).called(1);
    });
  });

  group('MarkReadLaterArticleAsReadUseCase', () {
    test('delegates the id to the repository', () async {
      when(() => repo.markReadLaterArticleAsRead(any())).thenAnswer((_) async {});

      await MarkReadLaterArticleAsReadUseCase(repo)(7);

      verify(() => repo.markReadLaterArticleAsRead(7)).called(1);
    });
  });
}
