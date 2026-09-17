import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/moderation/domain/params/decide_params.dart';
import 'package:news_app/features/moderation/domain/params/report_article_params.dart';
import 'package:news_app/features/moderation/domain/entities/report_reason.dart';
import 'package:news_app/features/moderation/domain/repository/moderation_repository.dart';
import 'package:news_app/features/moderation/domain/use_cases/report_article_use_case.dart';

/// Hand-written fake — mocktail isn't available (see pubspec.yaml note).
class _FakeModerationRepository implements ModerationRepository {
  _FakeModerationRepository({this.reportResult});

  DataState<void>? reportResult;
  ReportArticleParams? lastReportParams;

  @override
  Future<DataState<void>> reportArticle(ReportArticleParams params) async {
    lastReportParams = params;
    return reportResult ?? const DataSuccess(null);
  }

  @override
  Future<DataState<bool>> hasReported(String articleId) async => const DataSuccess(false);

  @override
  Future<DataState<bool>> isStaff() async => const DataSuccess(false);

  @override
  Future<DataState<void>> decideOnArticle(DecideParams params) async => const DataSuccess(null);

  @override
  Future<DataState<PaginatedResult<AuthoredArticleEntity>>> listSuspended({String? cursor}) async {
    return const DataSuccess(PaginatedResult(items: []));
  }
}

void main() {
  test('reporta un artículo y pasa el motivo y la nota tal cual', () async {
    final repo = _FakeModerationRepository();
    final useCase = ReportArticleUseCase(repo);

    final result = await useCase(
      const ReportArticleParams(articleId: 'a1', reason: ReportReason.spam, note: 'Publicidad encubierta'),
    );

    expect(result, isA<DataSuccess<void>>());
    expect(repo.lastReportParams?.articleId, 'a1');
    expect(repo.lastReportParams?.reason, ReportReason.spam);
    expect(repo.lastReportParams?.note, 'Publicidad encubierta');
  });

  test('propaga el error si el repositorio falla', () async {
    final repo = _FakeModerationRepository(reportResult: const DataFailed(ServerFailure('boom')));
    final useCase = ReportArticleUseCase(repo);

    final result = await useCase(const ReportArticleParams(articleId: 'a1', reason: ReportReason.other));

    expect(result, isA<DataFailed<void>>());
  });
}
