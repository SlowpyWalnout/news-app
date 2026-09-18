import 'dart:async';
import 'dart:collection';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/article_composer/domain/use_cases/get_feed_use_case.dart';
import 'package:news_app/features/article_composer/presentation/bloc/feed/feed_bloc.dart';
import 'package:news_app/features/article_composer/presentation/bloc/feed/feed_event.dart';
import 'package:news_app/features/article_composer/presentation/bloc/feed/feed_state.dart';

import '../../../../../helpers/helpers.dart';

typedef _FeedResult = DataState<PaginatedResult<AuthoredArticleEntity>>;

void main() {
  setUpAll(registerCommonFallbacks);

  group('FeedBloc', () {
    late MockAuthoredArticleRepository repo;

    setUp(() {
      repo = MockAuthoredArticleRepository();
    });

    test('estado inicial es FeedStatus.initial', () {
      final bloc = FeedBloc(GetFeedUseCase(repo));
      expect(bloc.state.status, FeedStatus.initial);
      bloc.close();
    });

    blocTest<FeedBloc, FeedState>(
      'FeedRequested exitoso emite loading luego success con los artículos',
      setUp: () {
        when(() => repo.getFeed(
              cursor: any(named: 'cursor'),
              category: any(named: 'category'),
              searchToken: any(named: 'searchToken'),
            )).thenAnswer((_) async => DataSuccess(
              PaginatedResult(items: [authoredArticle('1'), authoredArticle('2')]),
            ));
      },
      build: () => FeedBloc(GetFeedUseCase(repo)),
      act: (bloc) => bloc.add(const FeedRequested()),
      expect: () => [
        isA<FeedState>().having((s) => s.status, 'status', FeedStatus.loading),
        isA<FeedState>()
            .having((s) => s.status, 'status', FeedStatus.success)
            .having((s) => s.articles.length, 'articles.length', 2),
      ],
    );

    blocTest<FeedBloc, FeedState>(
      'FeedRequested fallido emite failure con el error',
      setUp: () {
        when(() => repo.getFeed(
              cursor: any(named: 'cursor'),
              category: any(named: 'category'),
              searchToken: any(named: 'searchToken'),
            )).thenAnswer((_) async => const DataFailed(NetworkFailure('sin conexión')));
      },
      build: () => FeedBloc(GetFeedUseCase(repo)),
      act: (bloc) => bloc.add(const FeedRequested()),
      verify: (bloc) {
        expect(bloc.state.status, FeedStatus.failure);
        expect(bloc.state.error, isA<NetworkFailure>());
      },
    );

    blocTest<FeedBloc, FeedState>(
      'tres pulsaciones rápidas disparan un solo fetch, con el token más largo',
      setUp: () {
        when(() => repo.getFeed(
              cursor: any(named: 'cursor'),
              category: any(named: 'category'),
              searchToken: any(named: 'searchToken'),
            )).thenAnswer((_) async => DataSuccess(PaginatedResult(items: [authoredArticle('1')])));
      },
      build: () => FeedBloc(GetFeedUseCase(repo)),
      act: (bloc) {
        bloc.add(const FeedQueryChanged('f'));
        bloc.add(const FeedQueryChanged('fl'));
        bloc.add(const FeedQueryChanged('el nuevo Flutter'));
      },
      wait: const Duration(milliseconds: 400),
      verify: (_) {
        final captured = verify(() => repo.getFeed(
              cursor: any(named: 'cursor'),
              category: any(named: 'category'),
              searchToken: captureAny(named: 'searchToken'),
            )).captured;
        expect(captured, ['flutter']);
      },
    );

    // Se queda en test() crudo: el bloc se cierra a mitad de la ventana de
    // debounce/refresh en varias de estas pruebas, y blocTest es dueño del
    // ciclo de vida del bloc — no permite cerrarlo en un instante elegido a
    // mitad de un handler. Ver ROADMAP.md / plan de Fase 8.
    test('una respuesta lenta de una query anterior se descarta si llega tarde', () async {
      final flutterCompleter = Completer<_FeedResult>();
      final dartCompleter = Completer<_FeedResult>();

      when(() => repo.getFeed(
            cursor: any(named: 'cursor'),
            category: any(named: 'category'),
            searchToken: any(named: 'searchToken'),
          )).thenAnswer((_) async => const DataSuccess(PaginatedResult(items: [])));
      when(() => repo.getFeed(
            cursor: any(named: 'cursor'),
            category: any(named: 'category'),
            searchToken: 'flutter',
          )).thenAnswer((_) => flutterCompleter.future);
      when(() => repo.getFeed(
            cursor: any(named: 'cursor'),
            category: any(named: 'category'),
            searchToken: 'dart',
          )).thenAnswer((_) => dartCompleter.future);

      final bloc = FeedBloc(GetFeedUseCase(repo));

      bloc.add(const FeedQueryChanged('flutter'));
      await Future.delayed(const Duration(milliseconds: 400));

      bloc.add(const FeedQueryChanged('dart'));
      dartCompleter.complete(DataSuccess(PaginatedResult(items: [authoredArticle('dart-1')])));
      await Future.delayed(const Duration(milliseconds: 400));

      expect(bloc.state.articles.map((a) => a.id), ['dart-1']);

      flutterCompleter.complete(DataSuccess(PaginatedResult(items: [authoredArticle('flutter-1')])));
      await pumpEventQueue();

      expect(bloc.state.articles.map((a) => a.id), ['dart-1']);

      await bloc.close();
    });

    blocTest<FeedBloc, FeedState>(
      'visibleArticles filtra los tokens residuales contra searchKeywords',
      setUp: () {
        when(() => repo.getFeed(
              cursor: any(named: 'cursor'),
              category: any(named: 'category'),
              searchToken: any(named: 'searchToken'),
            )).thenAnswer((_) async => DataSuccess(PaginatedResult(items: [
              authoredArticle('1', searchKeywords: ['flutter', 'guia']),
              authoredArticle('2', searchKeywords: ['flutter']),
            ])));
      },
      build: () => FeedBloc(GetFeedUseCase(repo)),
      act: (bloc) => bloc.add(const FeedQueryChanged('guia de flutter')),
      wait: const Duration(milliseconds: 400),
      verify: (bloc) {
        // El token enviado a array-contains es 'flutter' (el más largo);
        // 'guia' queda como filtro residual en cliente sobre searchKeywords.
        expect(bloc.state.visibleArticles.map((a) => a.id), ['1']);
      },
    );

    test('FeedMoreRequested concatena y arrastra el cursor', () async {
      final pages = Queue<_FeedResult>()
        ..add(DataSuccess(PaginatedResult(items: [authoredArticle('1')], nextCursor: 'c1')))
        ..add(DataSuccess(PaginatedResult(items: [authoredArticle('2')])));
      when(() => repo.getFeed(
            cursor: any(named: 'cursor'),
            category: any(named: 'category'),
            searchToken: any(named: 'searchToken'),
          )).thenAnswer((_) async => pages.removeFirst());

      final bloc = FeedBloc(GetFeedUseCase(repo));

      bloc.add(const FeedRequested());
      await Future.delayed(Duration.zero);
      expect(bloc.state.hasMore, isTrue);

      bloc.add(const FeedMoreRequested());
      await Future.delayed(Duration.zero);

      expect(bloc.state.articles.map((a) => a.id), ['1', '2']);
      expect(bloc.state.hasMore, isFalse);
      expect(bloc.state.isLoadingMore, isFalse);

      final captured = verify(() => repo.getFeed(
            cursor: captureAny(named: 'cursor'),
            category: any(named: 'category'),
            searchToken: any(named: 'searchToken'),
          )).captured;
      expect(captured, [null, 'c1']);

      await bloc.close();
    });

    test('FeedMoreRequested es no-op sin hasMore', () async {
      when(() => repo.getFeed(
            cursor: any(named: 'cursor'),
            category: any(named: 'category'),
            searchToken: any(named: 'searchToken'),
          )).thenAnswer((_) async => DataSuccess(PaginatedResult(items: [authoredArticle('1')])));

      final bloc = FeedBloc(GetFeedUseCase(repo));

      bloc.add(const FeedRequested());
      await Future.delayed(Duration.zero);
      expect(bloc.state.hasMore, isFalse);

      bloc.add(const FeedMoreRequested());
      await Future.delayed(Duration.zero);

      expect(bloc.state.articles.map((a) => a.id), ['1']);
      verify(() => repo.getFeed(
            cursor: any(named: 'cursor'),
            category: any(named: 'category'),
            searchToken: any(named: 'searchToken'),
          )).called(1);

      await bloc.close();
    });

    test('cerrar el bloc a mitad de un FeedRefreshed no lanza error', () async {
      when(() => repo.getFeed(
            cursor: any(named: 'cursor'),
            category: any(named: 'category'),
            searchToken: any(named: 'searchToken'),
          )).thenAnswer((_) async => DataSuccess(PaginatedResult(items: [authoredArticle('1')])));

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
      when(() => repo.getFeed(
            cursor: any(named: 'cursor'),
            category: any(named: 'category'),
            searchToken: any(named: 'searchToken'),
          )).thenAnswer((_) async => DataSuccess(PaginatedResult(items: [authoredArticle('1')])));

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
