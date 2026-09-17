import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/daily_news/domain/entities/article.dart';
import 'package:news_app/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app/features/daily_news/domain/use_cases/add_to_read_later_use_case.dart';
import 'package:news_app/features/daily_news/domain/use_cases/get_read_later_articles_use_case.dart';
import 'package:news_app/features/daily_news/domain/use_cases/mark_read_later_article_as_read_use_case.dart';
import 'package:news_app/features/daily_news/domain/use_cases/remove_from_read_later_use_case.dart';
import 'package:news_app/features/daily_news/presentation/bloc/article/local/read_later_bloc.dart';
import 'package:news_app/features/daily_news/presentation/bloc/article/local/read_later_event.dart';
import 'package:news_app/features/daily_news/presentation/bloc/article/local/read_later_state.dart';
import 'package:news_app/core/resources/data_state.dart';

const _article = ArticleEntity(id: 1, title: 'Título');

/// Hand-written fake — mocktail isn't available (see pubspec.yaml note).
class _FakeArticleRepository implements ArticleRepository {
  _FakeArticleRepository({this.articles = const [_article]});

  List<ArticleEntity> articles;

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async =>
      const DataSuccess([]);

  @override
  Future<List<ArticleEntity>> getReadLaterArticles() async => articles;

  @override
  Future<void> addToReadLater(ArticleEntity article) async {}

  @override
  Future<void> removeFromReadLater(ArticleEntity article) async {}

  @override
  Future<void> markReadLaterArticleAsRead(int id) async {}
}

ReadLaterBloc _bloc(_FakeArticleRepository repo) => ReadLaterBloc(
      GetReadLaterArticlesUseCase(repo),
      AddToReadLaterUseCase(repo),
      RemoveFromReadLaterUseCase(repo),
      MarkReadLaterArticleAsReadUseCase(repo),
    );

void main() {
  group('ReadLaterBloc', () {
    test('ReadLaterRefreshed emite loading y luego loaded con los artículos', () async {
      final bloc = _bloc(_FakeArticleRepository());
      final states = <ReadLaterState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const ReadLaterRefreshed());
      await bloc.stream.firstWhere((s) => s is ReadLaterLoaded);
      await sub.cancel();

      expect(states.first, isA<ReadLaterLoading>());
      expect(states.last, isA<ReadLaterLoaded>());
      expect(states.last.articles, [_article]);
    });

    test('cerrar el bloc a mitad de un ReadLaterRefreshed no lanza error', () async {
      final bloc = _bloc(_FakeArticleRepository());

      Object? uncaught;
      runZonedGuarded(() {
        bloc.add(const ReadLaterRefreshed());
      }, (error, stack) => uncaught = error);

      // El handler está en medio del Future.delayed(1s) del refresh cuando
      // el bloc se cierra, simulando el back del sistema a mitad de un
      // pull-to-refresh en "Leer después".
      await Future.delayed(const Duration(milliseconds: 10));
      await bloc.close();
      await pumpEventQueue();

      expect(uncaught, isNull);
    });
  });
}
