import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/moderation/presentation/bloc/review_queue_cubit.dart';

import '../../../../helpers/helpers.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  late MockListSuspendedArticlesUseCase useCase;
  late ReviewQueueCubit cubit;

  setUp(() {
    useCase = MockListSuspendedArticlesUseCase();
    cubit = ReviewQueueCubit(useCase);
  });

  test('load() success populates articles and cursor', () async {
    when(() => useCase.call(null))
        .thenAnswer((_) async => DataSuccess(PaginatedResult(items: [authoredArticle('1')], nextCursor: 'c1')));

    await cubit.load();

    expect(cubit.state.status, ReviewQueueStatus.success);
    expect(cubit.state.articles.map((a) => a.id), ['1']);
    expect(cubit.state.hasMore, isTrue);
  });

  test('load() failure carries the error code', () async {
    when(() => useCase.call(null))
        .thenAnswer((_) async => const DataFailed(ServerFailure('boom')));

    await cubit.load();

    expect(cubit.state.status, ReviewQueueStatus.failure);
    expect(cubit.state.errorCode, FailureCode.server);
  });

  test('loadMore() appends and passes the current nextCursor', () async {
    when(() => useCase.call(null))
        .thenAnswer((_) async => DataSuccess(PaginatedResult(items: [authoredArticle('1')], nextCursor: 'c1')));
    await cubit.load();

    when(() => useCase.call('c1'))
        .thenAnswer((_) async => DataSuccess(PaginatedResult(items: [authoredArticle('2')])));
    await cubit.loadMore();

    expect(cubit.state.articles.map((a) => a.id), ['1', '2']);
    expect(cubit.state.hasMore, isFalse);
    verify(() => useCase.call('c1')).called(1);
  });

  test('loadMore() is a no-op without hasMore', () async {
    when(() => useCase.call(null))
        .thenAnswer((_) async => DataSuccess(PaginatedResult(items: [authoredArticle('1')])));
    await cubit.load();

    await cubit.loadMore();

    verifyNever(() => useCase.call('c1'));
    expect(cubit.state.articles.map((a) => a.id), ['1']);
  });

  test('loadMore() is a no-op while already loading more', () async {
    when(() => useCase.call(null))
        .thenAnswer((_) async => DataSuccess(PaginatedResult(items: [authoredArticle('1')], nextCursor: 'c1')));
    await cubit.load();

    when(() => useCase.call('c1')).thenAnswer((_) async {
      // A second loadMore() while this one is in flight must be a no-op.
      final again = cubit.loadMore();
      await again;
      return DataSuccess(PaginatedResult(items: [authoredArticle('2')]));
    });
    await cubit.loadMore();

    verify(() => useCase.call('c1')).called(1);
  });

  test('loadMore() failure clears isLoadingMore and keeps the existing list', () async {
    when(() => useCase.call(null))
        .thenAnswer((_) async => DataSuccess(PaginatedResult(items: [authoredArticle('1')], nextCursor: 'c1')));
    await cubit.load();

    when(() => useCase.call('c1')).thenAnswer((_) async => const DataFailed(ServerFailure('boom')));
    await cubit.loadMore();

    expect(cubit.state.isLoadingMore, isFalse);
    expect(cubit.state.articles.map((a) => a.id), ['1']);
  });

  test('removeLocally drops the article by id', () async {
    when(() => useCase.call(null)).thenAnswer(
        (_) async => DataSuccess(PaginatedResult(items: [authoredArticle('1'), authoredArticle('2')])));
    await cubit.load();

    cubit.removeLocally('1');

    expect(cubit.state.articles.map((a) => a.id), ['2']);
  });

  test('a page with no nextCursor clears it (clearNextCursor)', () async {
    when(() => useCase.call(null))
        .thenAnswer((_) async => DataSuccess(PaginatedResult(items: [authoredArticle('1')], nextCursor: 'c1')));
    await cubit.load();
    expect(cubit.state.hasMore, isTrue);

    when(() => useCase.call('c1'))
        .thenAnswer((_) async => DataSuccess(PaginatedResult(items: [authoredArticle('2')])));
    await cubit.loadMore();

    expect(cubit.state.hasMore, isFalse);
    expect(cubit.state.nextCursor, isNull);
  });
}
