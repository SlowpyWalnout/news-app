import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/features/article_composer/domain/use_cases/get_article_by_id_use_case.dart';
import 'package:news_app/features/daily_news/domain/entities/article.dart';
import 'package:news_app/features/daily_news/domain/use_cases/add_to_read_later_use_case.dart';
import 'package:news_app/features/daily_news/domain/use_cases/get_read_later_articles_use_case.dart';
import 'package:news_app/features/daily_news/domain/use_cases/mark_read_later_article_as_read_use_case.dart';
import 'package:news_app/features/daily_news/domain/use_cases/remove_from_read_later_use_case.dart';
import 'package:news_app/features/daily_news/presentation/bloc/article/local/read_later_bloc.dart';
import 'package:news_app/features/daily_news/presentation/bloc/article/local/read_later_event.dart';
import 'package:news_app/features/daily_news/presentation/bloc/article/local/read_later_state.dart';

import '../../../../../../helpers/helpers.dart';

const _article = ArticleEntity(id: 1, title: 'Título');

ReadLaterBloc _bloc(MockArticleRepository repo) => ReadLaterBloc(
      GetReadLaterArticlesUseCase(repo),
      AddToReadLaterUseCase(repo),
      RemoveFromReadLaterUseCase(repo),
      MarkReadLaterArticleAsReadUseCase(repo),
      GetArticleByIdUseCase(MockAuthoredArticleRepository()),
    );

void main() {
  setUpAll(registerCommonFallbacks);

  group('ReadLaterBloc', () {
    late MockArticleRepository repo;

    setUp(() {
      repo = MockArticleRepository();
      when(() => repo.getReadLaterArticles()).thenAnswer((_) async => const [_article]);
    });

    blocTest<ReadLaterBloc, ReadLaterState>(
      'ReadLaterRefreshed emite loading y luego loaded con los artículos',
      build: () => _bloc(repo),
      act: (bloc) => bloc.add(const ReadLaterRefreshed()),
      wait: const Duration(milliseconds: 1100),
      // ReadLaterLoading.props == [null, null], igual al estado inicial del
      // bloc — esta emisión pasa el filtro de dedupe de Equatable solo
      // porque es la primera tras el constructor. Nunca asumir un segundo
      // Loading en una lista expect: de otro test sobre este bloc.
      expect: () => [isA<ReadLaterLoading>(), isA<ReadLaterLoaded>()],
      verify: (bloc) => expect(bloc.state.articles, [_article]),
    );

    // Se queda en test() crudo (mismo motivo que feed_bloc_test.dart): el
    // bloc se cierra a mitad del Future.delayed(1s) del refresh.
    test('cerrar el bloc a mitad de un ReadLaterRefreshed no lanza error', () async {
      final bloc = _bloc(repo);

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
