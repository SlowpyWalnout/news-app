import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/article_composer/domain/params/get_feed_params.dart';
import 'package:news_app/features/article_composer/domain/use_cases/get_feed_use_case.dart';

import '../../../../helpers/helpers.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  group('GetFeedUseCase', () {
    late MockAuthoredArticleRepository repo;

    setUp(() {
      repo = MockAuthoredArticleRepository();
      when(() => repo.getFeed(
            cursor: any(named: 'cursor'),
            category: any(named: 'category'),
            searchToken: any(named: 'searchToken'),
          )).thenAnswer((_) async => const DataSuccess(PaginatedResult(items: [])));
    });

    test('a multi-word query reaches the repository as a single token', () async {
      await GetFeedUseCase(repo)(const GetFeedParams(query: 'el nuevo Flutter'));

      final captured = verify(() => repo.getFeed(
            cursor: any(named: 'cursor'),
            category: any(named: 'category'),
            searchToken: captureAny(named: 'searchToken'),
          )).captured;
      expect(captured.single, 'flutter');
    });

    test('a stopword-only query reaches the repository as null', () async {
      await GetFeedUseCase(repo)(const GetFeedParams(query: 'de la'));

      final captured = verify(() => repo.getFeed(
            cursor: any(named: 'cursor'),
            category: any(named: 'category'),
            searchToken: captureAny(named: 'searchToken'),
          )).captured;
      expect(captured.single, isNull);
    });

    test('no query at all reaches the repository as null', () async {
      await GetFeedUseCase(repo)(const GetFeedParams());

      final captured = verify(() => repo.getFeed(
            cursor: any(named: 'cursor'),
            category: any(named: 'category'),
            searchToken: captureAny(named: 'searchToken'),
          )).captured;
      expect(captured.single, isNull);
    });
  });
}
