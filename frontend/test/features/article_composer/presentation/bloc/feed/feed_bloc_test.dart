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

AuthoredArticleEntity _article(
  String id, {
  ArticleCategory category = ArticleCategory.general,
  List<String> searchKeywords = const [],
}) {
  final now = DateTime(2026, 1, 1);
  return AuthoredArticleEntity(
    id: id,
    authorId: 'author-1',
    authorName: 'Autor',
    title: 'Título $id',
    body: 'Cuerpo $id',
    status: ArticleStatus.published,
    category: category,
    searchKeywords: searchKeywords,
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
  final List<String?> calledSearchTokens = [];

  @override
  Future<DataState<PaginatedResult<AuthoredArticleEntity>>> getFeed({
    String? cursor,
    ArticleCategory? category,
    String? searchToken,
  }) async {
    calledSearchTokens.add(searchToken);
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

/// A fake whose response for a given searchToken is controlled by a
/// Completer the test resolves manually — used to reproduce a slow response
/// for an earlier query arriving after a faster response for a later one.
class _ControllableRepository implements AuthoredArticleRepository {
  final Map<String?, Completer<DataState<PaginatedResult<AuthoredArticleEntity>>>> _pending = {};
  final List<String?> calledSearchTokens = [];

  Completer<DataState<PaginatedResult<AuthoredArticleEntity>>> prepare(String? token) {
    final completer = Completer<DataState<PaginatedResult<AuthoredArticleEntity>>>();
    _pending[token] = completer;
    return completer;
  }

  @override
  Future<DataState<PaginatedResult<AuthoredArticleEntity>>> getFeed({
    String? cursor,
    ArticleCategory? category,
    String? searchToken,
  }) {
    calledSearchTokens.add(searchToken);
    final completer = _pending[searchToken];
    if (completer == null) {
      return Future.value(DataSuccess(const PaginatedResult(items: [])));
    }
    return completer.future;
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

    test('tres pulsaciones rápidas disparan un solo fetch, con el token más largo', () async {
      final repo = _FakeAuthoredArticleRepository(
        result: DataSuccess(PaginatedResult(items: [_article('1')])),
      );
      final bloc = FeedBloc(GetFeedUseCase(repo));

      bloc.add(const FeedQueryChanged('f'));
      bloc.add(const FeedQueryChanged('fl'));
      bloc.add(const FeedQueryChanged('el nuevo Flutter'));
      await Future.delayed(const Duration(milliseconds: 400));

      expect(repo.calledSearchTokens, ['flutter']);

      await bloc.close();
    });

    test('una respuesta lenta de una query anterior se descarta si llega tarde', () async {
      final repo = _ControllableRepository();
      final flutterCompleter = repo.prepare('flutter');
      final dartCompleter = repo.prepare('dart');
      final bloc = FeedBloc(GetFeedUseCase(repo));

      bloc.add(const FeedQueryChanged('flutter'));
      await Future.delayed(const Duration(milliseconds: 400));

      bloc.add(const FeedQueryChanged('dart'));
      dartCompleter.complete(DataSuccess(PaginatedResult(items: [_article('dart-1')])));
      await Future.delayed(const Duration(milliseconds: 400));

      expect(bloc.state.articles.map((a) => a.id), ['dart-1']);

      flutterCompleter.complete(DataSuccess(PaginatedResult(items: [_article('flutter-1')])));
      await pumpEventQueue();

      expect(bloc.state.articles.map((a) => a.id), ['dart-1']);

      await bloc.close();
    });

    test('visibleArticles filtra los tokens residuales contra searchKeywords', () async {
      final repo = _FakeAuthoredArticleRepository(
        result: DataSuccess(PaginatedResult(items: [
          _article('1', searchKeywords: ['flutter', 'guia']),
          _article('2', searchKeywords: ['flutter']),
        ])),
      );
      final bloc = FeedBloc(GetFeedUseCase(repo));

      bloc.add(const FeedQueryChanged('guia de flutter'));
      await Future.delayed(const Duration(milliseconds: 400));

      // El token enviado a array-contains es 'flutter' (el más largo); 'guia'
      // queda como filtro residual en cliente sobre searchKeywords.
      expect(bloc.state.visibleArticles.map((a) => a.id), ['1']);

      await bloc.close();
    });

    test('FeedMoreRequested concatena y arrastra el cursor', () async {
      final repo = _FakeAuthoredArticleRepository(
        result: DataSuccess(PaginatedResult(items: [_article('1')], nextCursor: 'c1')),
      );
      final bloc = FeedBloc(GetFeedUseCase(repo));

      bloc.add(const FeedRequested());
      await Future.delayed(Duration.zero);
      expect(bloc.state.hasMore, isTrue);

      repo.result = DataSuccess(PaginatedResult(items: [_article('2')]));
      bloc.add(const FeedMoreRequested());
      await Future.delayed(Duration.zero);

      expect(bloc.state.articles.map((a) => a.id), ['1', '2']);
      expect(bloc.state.hasMore, isFalse);
      expect(bloc.state.isLoadingMore, isFalse);

      await bloc.close();
    });

    test('FeedMoreRequested es no-op sin hasMore', () async {
      final repo = _FakeAuthoredArticleRepository(
        result: DataSuccess(PaginatedResult(items: [_article('1')])),
      );
      final bloc = FeedBloc(GetFeedUseCase(repo));

      bloc.add(const FeedRequested());
      await Future.delayed(Duration.zero);
      expect(bloc.state.hasMore, isFalse);

      bloc.add(const FeedMoreRequested());
      await Future.delayed(Duration.zero);

      expect(bloc.state.articles.map((a) => a.id), ['1']);

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

    test('cerrar el bloc a mitad de la ventana de debounce no lanza error', () async {
      final repo = _FakeAuthoredArticleRepository(
        result: DataSuccess(PaginatedResult(items: [_article('1')])),
      );
      final bloc = FeedBloc(GetFeedUseCase(repo));

      Object? uncaught;
      runZonedGuarded(() {
        bloc.add(const FeedQueryChanged('flutter'));
      }, (error, stack) => uncaught = error);

      // El bloc se cierra dentro de la ventana de debounce de 350ms, antes
      // de que el fetch siquiera arranque.
      await Future.delayed(const Duration(milliseconds: 100));
      await bloc.close();
      await pumpEventQueue();

      expect(uncaught, isNull);
    });
  });
}
