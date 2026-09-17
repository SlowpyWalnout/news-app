import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/article_composer/domain/entities/article_category.dart';
import 'package:news_app/features/article_composer/domain/entities/article_status.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/article_composer/domain/entities/upload_thumbnail_result.dart';
import 'package:news_app/features/article_composer/domain/repository/authored_article_repository.dart';
import 'package:news_app/features/article_composer/domain/use_cases/get_feed_use_case.dart';
import 'package:news_app/features/article_composer/presentation/bloc/feed/feed_bloc.dart';
import 'package:news_app/features/article_composer/presentation/bloc/feed/feed_event.dart';
import 'package:news_app/features/article_composer/presentation/bloc/feed/feed_state.dart';

AuthoredArticleEntity _article(String id, {ArticleCategory category = ArticleCategory.general}) {
  final now = DateTime(2026, 1, 1);
  return AuthoredArticleEntity(
    id: id,
    authorId: 'author-1',
    authorName: 'Autor',
    title: 'Título $id',
    body: 'Cuerpo $id',
    status: ArticleStatus.published,
    category: category,
    createdAt: now,
    updatedAt: now,
    publishedAt: now,
  );
}

/// Hand-written fake — mocktail isn't available (see pubspec.yaml note).
class _FakeAuthoredArticleRepository implements AuthoredArticleRepository {
  _FakeAuthoredArticleRepository({this.result, this.shouldFail = false});

  DataState<PaginatedResult<AuthoredArticleEntity>>? result;
  bool shouldFail;

  @override
  Future<DataState<PaginatedResult<AuthoredArticleEntity>>> getFeed({String? cursor, ArticleCategory? category}) async {
    if (shouldFail) return const DataFailed(NetworkFailure('sin conexión'));
    return result ?? DataSuccess(const PaginatedResult(items: []));
  }

  @override
  Future<DataState<PaginatedResult<AuthoredArticleEntity>>> getMyArticles(String authorId, {String? cursor}) async {
    throw UnimplementedError();
  }

  @override
  Future<DataState<AuthoredArticleEntity?>> getArticleById(String articleId) async {
    throw UnimplementedError();
  }

  @override
  Future<DataState<AuthoredArticleEntity>> publishArticle(AuthoredArticleEntity article) async {
    throw UnimplementedError();
  }

  @override
  Future<DataState<AuthoredArticleEntity>> saveDraft(AuthoredArticleEntity article) async {
    throw UnimplementedError();
  }

  @override
  Future<DataState<AuthoredArticleEntity>> updateArticle(AuthoredArticleEntity article) async {
    throw UnimplementedError();
  }

  @override
  Future<DataState<void>> deleteArticle(String articleId) async {
    throw UnimplementedError();
  }

  @override
  Future<DataState<UploadThumbnailResult>> uploadThumbnail(
    String articleId,
    String filePath, {
    void Function(double progress)? onProgress,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  group('FeedBloc', () {
    test('estado inicial es FeedStatus.initial', () {
      final bloc = FeedBloc(GetFeedUseCase(_FakeAuthoredArticleRepository()));
      expect(bloc.state.status, FeedStatus.initial);
      bloc.close();
    });

    test('FeedRequested exitoso emite loading luego success con los artículos', () async {
      final repo = _FakeAuthoredArticleRepository(
        result: DataSuccess(PaginatedResult(items: [_article('1'), _article('2')])),
      );
      final bloc = FeedBloc(GetFeedUseCase(repo));

      final states = <FeedState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const FeedRequested());
      await Future.delayed(Duration.zero);

      expect(states.map((s) => s.status), [FeedStatus.loading, FeedStatus.success]);
      expect(states.last.articles.length, 2);

      await sub.cancel();
      await bloc.close();
    });

    test('FeedRequested fallido emite failure con el error', () async {
      final repo = _FakeAuthoredArticleRepository(shouldFail: true);
      final bloc = FeedBloc(GetFeedUseCase(repo));

      final states = <FeedState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const FeedRequested());
      await Future.delayed(Duration.zero);

      expect(states.last.status, FeedStatus.failure);
      expect(states.last.error, isA<NetworkFailure>());

      await sub.cancel();
      await bloc.close();
    });

    test('FeedQueryChanged filtra visibleArticles por título o autor', () async {
      final repo = _FakeAuthoredArticleRepository(
        result: DataSuccess(PaginatedResult(items: [_article('1'), _article('2')])),
      );
      final bloc = FeedBloc(GetFeedUseCase(repo));

      bloc.add(const FeedRequested());
      await Future.delayed(Duration.zero);

      bloc.add(const FeedQueryChanged('Título 1'));
      await Future.delayed(Duration.zero);

      expect(bloc.state.visibleArticles.length, 1);
      expect(bloc.state.visibleArticles.first.id, '1');

      await bloc.close();
    });

    test('cerrar el bloc a mitad de un FeedRefreshed no lanza error', () async {
      final repo = _FakeAuthoredArticleRepository(
        result: DataSuccess(PaginatedResult(items: [_article('1')])),
      );
      final bloc = FeedBloc(GetFeedUseCase(repo));

      Object? uncaught;
      runZonedGuarded(() {
        bloc.add(const FeedRefreshed());
      }, (error, stack) => uncaught = error);

      // El handler está en medio del Future.delayed(1s) del refresh cuando
      // el bloc se cierra, simulando el tab siendo descartado por el
      // PageView del AppShell.
      await Future.delayed(const Duration(milliseconds: 10));
      await bloc.close();
      await pumpEventQueue();

      expect(uncaught, isNull);
    });
  });
}
