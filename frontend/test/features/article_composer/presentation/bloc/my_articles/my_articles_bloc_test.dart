import 'dart:async';
import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/article_composer/domain/use_cases/delete_article_use_case.dart';
import 'package:news_app/features/article_composer/domain/use_cases/list_my_articles_use_case.dart';
import 'package:news_app/features/article_composer/presentation/bloc/my_articles/my_articles_bloc.dart';
import 'package:news_app/features/article_composer/presentation/bloc/my_articles/my_articles_event.dart';

import '../../../../../helpers/helpers.dart';

typedef _MyArticlesResult = DataState<PaginatedResult<AuthoredArticleEntity>>;

MyArticlesBloc _bloc(MockAuthoredArticleRepository repo) => MyArticlesBloc(
      ListMyArticlesUseCase(repo),
      DeleteArticleUseCase(repo),
    );

void main() {
  setUpAll(registerCommonFallbacks);

  group('MyArticlesBloc', () {
    late MockAuthoredArticleRepository repo;

    setUp(() {
      repo = MockAuthoredArticleRepository();
      when(() => repo.deleteArticle(any())).thenAnswer((_) async => const DataSuccess(null));
    });

    // Se queda en test() crudo (mismo motivo que feed_bloc_test.dart): el
    // bloc se cierra a mitad del Future.delayed(1s) del refresh.
    test('cerrar el bloc a mitad de un MyArticlesRefreshed no lanza error', () async {
      when(() => repo.getMyArticles(any(), cursor: any(named: 'cursor')))
          .thenAnswer((_) async => DataSuccess(PaginatedResult(items: [authoredArticle('1')])));
      final bloc = _bloc(repo);

      Object? uncaught;
      runZonedGuarded(() {
        bloc.add(const MyArticlesRequested('author-1'));
        bloc.add(const MyArticlesRefreshed('author-1'));
      }, (error, stack) => uncaught = error);

      // El handler está en medio del Future.delayed(1s) del refresh cuando
      // el bloc se cierra, simulando el tab siendo descartado por el
      // PageView del AppShell.
      await Future.delayed(const Duration(milliseconds: 10));
      await bloc.close();
      await pumpEventQueue();

      expect(uncaught, isNull);
    });

    test('MyArticlesMoreRequested concatena y arrastra el cursor', () async {
      final pages = Queue<_MyArticlesResult>()
        ..add(DataSuccess(PaginatedResult(items: [authoredArticle('1')], nextCursor: 'c1')))
        ..add(DataSuccess(PaginatedResult(items: [authoredArticle('2')])));
      when(() => repo.getMyArticles(any(), cursor: any(named: 'cursor')))
          .thenAnswer((_) async => pages.removeFirst());
      final bloc = _bloc(repo);

      bloc.add(const MyArticlesRequested('author-1'));
      await Future.delayed(Duration.zero);
      expect(bloc.state.hasMore, isTrue);

      bloc.add(const MyArticlesMoreRequested());
      await Future.delayed(Duration.zero);

      expect(bloc.state.articles.map((a) => a.id), ['1', '2']);
      expect(bloc.state.hasMore, isFalse);
      expect(bloc.state.isLoadingMore, isFalse);

      final captured = verify(() => repo.getMyArticles(any(), cursor: captureAny(named: 'cursor'))).captured;
      expect(captured, [null, 'c1']);

      await bloc.close();
    });

    test('MyArticlesMoreRequested es no-op sin hasMore', () async {
      when(() => repo.getMyArticles(any(), cursor: any(named: 'cursor')))
          .thenAnswer((_) async => DataSuccess(PaginatedResult(items: [authoredArticle('1')])));
      final bloc = _bloc(repo);

      bloc.add(const MyArticlesRequested('author-1'));
      await Future.delayed(Duration.zero);
      expect(bloc.state.hasMore, isFalse);

      bloc.add(const MyArticlesMoreRequested());
      await Future.delayed(Duration.zero);

      expect(bloc.state.articles.map((a) => a.id), ['1']);

      await bloc.close();
    });
  });
}
