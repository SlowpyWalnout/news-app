import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/moderation/domain/entities/report_reason.dart';
import 'package:news_app/features/moderation/domain/params/decide_params.dart';
import 'package:news_app/features/moderation/domain/params/report_article_params.dart';
import 'package:news_app/features/moderation/domain/repository/moderation_repository.dart';
import 'package:news_app/features/moderation/domain/use_cases/decide_on_article_use_case.dart';
import 'package:news_app/features/moderation/domain/use_cases/report_article_use_case.dart';
import 'package:news_app/features/moderation/presentation/bloc/moderation_cubit.dart';

/// Hand-written fake — mocktail isn't available (see pubspec.yaml note).
class _FakeModerationRepository implements ModerationRepository {
  _FakeModerationRepository({this.reportResult, this.hasReportedResult, this.decideResult});

  DataState<void>? reportResult;
  DataState<bool>? hasReportedResult;
  DataState<void>? decideResult;
  DecideParams? lastDecideParams;

  @override
  Future<DataState<void>> reportArticle(ReportArticleParams params) async => reportResult ?? const DataSuccess(null);

  @override
  Future<DataState<bool>> hasReported(String articleId) async => hasReportedResult ?? const DataSuccess(false);

  @override
  Future<DataState<bool>> isStaff() async => const DataSuccess(false);

  @override
  Future<DataState<void>> decideOnArticle(DecideParams params) async {
    lastDecideParams = params;
    return decideResult ?? const DataSuccess(null);
  }

  @override
  Future<DataState<PaginatedResult<AuthoredArticleEntity>>> listSuspended({String? cursor}) async {
    return const DataSuccess(PaginatedResult(items: []));
  }
}

void main() {
  test('report() devuelve true en éxito', () async {
    final repo = _FakeModerationRepository();
    final cubit = ModerationCubit(ReportArticleUseCase(repo), DecideOnArticleUseCase(repo), repo);

    final ok = await cubit.report(const ReportArticleParams(articleId: 'a1', reason: ReportReason.spam));

    expect(ok, isTrue);
    await cubit.close();
  });

  test('report() devuelve false si el repositorio falla', () async {
    final repo = _FakeModerationRepository(reportResult: const DataFailed(ServerFailure('boom')));
    final cubit = ModerationCubit(ReportArticleUseCase(repo), DecideOnArticleUseCase(repo), repo);

    final ok = await cubit.report(const ReportArticleParams(articleId: 'a1', reason: ReportReason.spam));

    expect(ok, isFalse);
    await cubit.close();
  });

  test('hasReported() refleja el resultado del repositorio', () async {
    final repo = _FakeModerationRepository(hasReportedResult: const DataSuccess(true));
    final cubit = ModerationCubit(ReportArticleUseCase(repo), DecideOnArticleUseCase(repo), repo);

    expect(await cubit.hasReported('a1'), isTrue);
    await cubit.close();
  });

  test('decide() pasa la decisión al repositorio', () async {
    final repo = _FakeModerationRepository();
    final cubit = ModerationCubit(ReportArticleUseCase(repo), DecideOnArticleUseCase(repo), repo);

    final ok = await cubit.decide(const DecideParams(articleId: 'a1', decision: ModerationDecision.approve));

    expect(ok, isTrue);
    expect(repo.lastDecideParams?.decision, ModerationDecision.approve);
    await cubit.close();
  });
}
