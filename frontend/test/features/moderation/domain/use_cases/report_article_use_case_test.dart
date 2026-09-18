import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/moderation/domain/entities/report_reason.dart';
import 'package:news_app/features/moderation/domain/params/decide_params.dart';
import 'package:news_app/features/moderation/domain/params/report_article_params.dart';
import 'package:news_app/features/moderation/domain/use_cases/decide_on_article_use_case.dart';
import 'package:news_app/features/moderation/domain/use_cases/has_reported_use_case.dart';
import 'package:news_app/features/moderation/domain/use_cases/list_suspended_articles_use_case.dart';
import 'package:news_app/features/moderation/domain/use_cases/report_article_use_case.dart';

import '../../../../helpers/helpers.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  late MockModerationRepository repo;

  setUp(() {
    repo = MockModerationRepository();
  });

  group('ReportArticleUseCase', () {
    test('reporta un artículo y pasa el motivo y la nota tal cual', () async {
      when(() => repo.reportArticle(any())).thenAnswer((_) async => const DataSuccess(null));
      final useCase = ReportArticleUseCase(repo);

      final result = await useCase(
        const ReportArticleParams(articleId: 'a1', reason: ReportReason.spam, note: 'Publicidad encubierta'),
      );

      expect(result, isA<DataSuccess<void>>());
      final captured = verify(() => repo.reportArticle(captureAny())).captured.single as ReportArticleParams;
      expect(captured.articleId, 'a1');
      expect(captured.reason, ReportReason.spam);
      expect(captured.note, 'Publicidad encubierta');
    });

    test('propaga el error si el repositorio falla', () async {
      when(() => repo.reportArticle(any())).thenAnswer((_) async => const DataFailed(ServerFailure('boom')));
      final useCase = ReportArticleUseCase(repo);

      final result = await useCase(const ReportArticleParams(articleId: 'a1', reason: ReportReason.other));

      expect(result, isA<DataFailed<void>>());
    });
  });

  group('HasReportedUseCase', () {
    test('delega en el repositorio', () async {
      when(() => repo.hasReported('a1')).thenAnswer((_) async => const DataSuccess(true));

      final result = await HasReportedUseCase(repo)('a1');

      expect(result, isA<DataSuccess<bool>>());
      expect((result as DataSuccess<bool>).data, isTrue);
    });
  });

  group('DecideOnArticleUseCase', () {
    test('delega en el repositorio', () async {
      when(() => repo.decideOnArticle(any())).thenAnswer((_) async => const DataSuccess(null));
      const params = DecideParams(articleId: 'a1', decision: ModerationDecision.remove);

      final result = await DecideOnArticleUseCase(repo)(params);

      expect(result, isA<DataSuccess<void>>());
      verify(() => repo.decideOnArticle(params)).called(1);
    });
  });

  group('ListSuspendedArticlesUseCase', () {
    test('delega el cursor en el repositorio', () async {
      when(() => repo.listSuspended(cursor: any(named: 'cursor')))
          .thenAnswer((_) async => const DataSuccess(PaginatedResult(items: [])));

      await ListSuspendedArticlesUseCase(repo)('c1');

      verify(() => repo.listSuspended(cursor: 'c1')).called(1);
    });
  });
}
