import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/article_composer/data/models/authored_article_model.dart';
import 'package:news_app/features/moderation/data/repository/moderation_repository_impl.dart';
import 'package:news_app/features/moderation/domain/entities/report_reason.dart';
import 'package:news_app/features/moderation/domain/params/decide_params.dart';
import 'package:news_app/features/moderation/domain/params/report_article_params.dart';

import '../../../../helpers/helpers.dart';

final _boom = FirebaseException(plugin: 'firestore', code: 'permission-denied', message: 'nope');

void main() {
  setUpAll(registerCommonFallbacks);

  late MockModerationFirestoreDataSource dataSource;
  late ModerationRepositoryImpl repo;

  setUp(() {
    dataSource = MockModerationFirestoreDataSource();
    repo = ModerationRepositoryImpl(dataSource);
  });

  test('reportArticle: success passthrough and FirebaseException mapped to DataFailed', () async {
    when(() => dataSource.reportArticle(any())).thenAnswer((_) async {});
    expect(await repo.reportArticle(const ReportArticleParams(articleId: 'a1', reason: ReportReason.spam)),
        isA<DataSuccess<void>>());

    when(() => dataSource.reportArticle(any())).thenThrow(_boom);
    final failed = await repo.reportArticle(const ReportArticleParams(articleId: 'a1', reason: ReportReason.spam));
    expect(failed, isA<DataFailed>());
    expect((failed as DataFailed).error, isA<ServerFailure>());
  });

  test('hasReported: success passthrough and FirebaseException mapped to DataFailed', () async {
    when(() => dataSource.hasReported(any())).thenAnswer((_) async => true);
    final ok = await repo.hasReported('a1');
    expect(ok, isA<DataSuccess<bool>>());
    expect((ok as DataSuccess).data, isTrue);

    when(() => dataSource.hasReported(any())).thenThrow(_boom);
    expect(await repo.hasReported('a1'), isA<DataFailed>());
  });

  test('isStaff: success passthrough and FirebaseException mapped to DataFailed', () async {
    when(() => dataSource.isStaff()).thenAnswer((_) async => true);
    expect(await repo.isStaff(), isA<DataSuccess<bool>>());

    when(() => dataSource.isStaff()).thenThrow(_boom);
    expect(await repo.isStaff(), isA<DataFailed>());
  });

  test('decideOnArticle: success passthrough and FirebaseException mapped to DataFailed', () async {
    when(() => dataSource.decideOnArticle(any())).thenAnswer((_) async {});
    expect(
      await repo.decideOnArticle(const DecideParams(articleId: 'a1', decision: ModerationDecision.approve)),
      isA<DataSuccess<void>>(),
    );

    when(() => dataSource.decideOnArticle(any())).thenThrow(_boom);
    expect(
      await repo.decideOnArticle(const DecideParams(articleId: 'a1', decision: ModerationDecision.approve)),
      isA<DataFailed>(),
    );
  });

  test('listSuspended: rewraps the page and maps FirebaseException to DataFailed', () async {
    when(() => dataSource.listSuspended(cursor: any(named: 'cursor')))
        .thenAnswer((_) async => PaginatedResult(items: [AuthoredArticleModel.fromEntity(authoredArticle('1'))], nextCursor: 'c1'));
    final ok = await repo.listSuspended(cursor: 'c0');
    expect(ok, isA<DataSuccess>());
    expect((ok as DataSuccess).data.nextCursor, 'c1');

    when(() => dataSource.listSuspended(cursor: any(named: 'cursor'))).thenThrow(_boom);
    expect(await repo.listSuspended(cursor: 'c0'), isA<DataFailed>());
  });
}
