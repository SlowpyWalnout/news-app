import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/features/article_composer/presentation/bloc/article_actions/article_actions_cubit.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  late MockDeleteArticleUseCase deleteUseCase;
  late ArticleActionsCubit cubit;

  setUp(() {
    deleteUseCase = MockDeleteArticleUseCase();
    cubit = ArticleActionsCubit(deleteUseCase);
  });

  test('delete returns true on success', () async {
    when(() => deleteUseCase.call(any())).thenAnswer((_) async => const DataSuccess(null));

    expect(await cubit.delete('a1'), isTrue);
  });

  test('delete returns false on failure', () async {
    when(() => deleteUseCase.call(any())).thenAnswer((_) async => const DataFailed(ServerFailure('boom')));

    expect(await cubit.delete('a1'), isFalse);
  });

  group('isMine', () {
    test('true when the current uid matches the author and not forced denied', () {
      final article = authoredArticle('a1', authorId: 'u1');
      expect(cubit.isMine(article, currentUserId: 'u1', forcePermissionDenied: false), isTrue);
    });

    test('false when forcePermissionDenied is true, even for the real author', () {
      final article = authoredArticle('a1', authorId: 'u1');
      expect(cubit.isMine(article, currentUserId: 'u1', forcePermissionDenied: true), isFalse);
    });

    test('false when currentUserId is null', () {
      final article = authoredArticle('a1', authorId: 'u1');
      expect(cubit.isMine(article, currentUserId: null, forcePermissionDenied: false), isFalse);
    });

    test('false when the uids do not match', () {
      final article = authoredArticle('a1', authorId: 'u1');
      expect(cubit.isMine(article, currentUserId: 'u2', forcePermissionDenied: false), isFalse);
    });
  });

  group('findStoredMatch', () {
    test('matches by sourceId first', () {
      final article = authoredArticle('a1');
      final stored = [readLaterArticle(id: 1, sourceId: 'other'), readLaterArticle(id: 2, sourceId: 'a1')];

      final match = cubit.findStoredMatch(article, stored);

      expect(match?.id, 2);
    });

    // Regresión: filas guardadas antes de que existiera sourceId no deben
    // resolver a null (eso era lo que hacía crashear el DELETE por PK nula).
    test('falls back to a title match when sourceId is null (legacy rows)', () {
      final article = authoredArticle('a1', title: 'Título único');
      final stored = [readLaterArticle(id: 3, sourceId: null, title: 'Título único')];

      final match = cubit.findStoredMatch(article, stored);

      expect(match?.id, 3);
    });

    test('returns null when nothing matches', () {
      final article = authoredArticle('a1', title: 'Título único');
      final stored = [readLaterArticle(id: 4, sourceId: 'other', title: 'Otro título')];

      expect(cubit.findStoredMatch(article, stored), isNull);
    });
  });
}
