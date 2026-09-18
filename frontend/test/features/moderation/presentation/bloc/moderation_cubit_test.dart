import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/features/moderation/domain/entities/report_reason.dart';
import 'package:news_app/features/moderation/domain/params/decide_params.dart';
import 'package:news_app/features/moderation/domain/params/report_article_params.dart';
import 'package:news_app/features/moderation/domain/use_cases/decide_on_article_use_case.dart';
import 'package:news_app/features/moderation/domain/use_cases/has_reported_use_case.dart';
import 'package:news_app/features/moderation/domain/use_cases/report_article_use_case.dart';
import 'package:news_app/features/moderation/presentation/bloc/moderation_cubit.dart';

import '../../../../helpers/helpers.dart';

// Se queda en test() crudo: los 4 casos afirman el bool devuelto por el
// método (o el estado tras esa llamada), no una secuencia de emisiones —
// blocTest solo lo taparía sin añadir nada.
void main() {
  setUpAll(registerCommonFallbacks);

  late MockModerationRepository repo;

  setUp(() {
    repo = MockModerationRepository();
  });

  ModerationCubit buildCubit() =>
      ModerationCubit(ReportArticleUseCase(repo), DecideOnArticleUseCase(repo), HasReportedUseCase(repo));

  test('report() devuelve true en éxito y marca el estado como reportado', () async {
    when(() => repo.reportArticle(any())).thenAnswer((_) async => const DataSuccess(null));
    final cubit = buildCubit();

    final ok = await cubit.report(const ReportArticleParams(articleId: 'a1', reason: ReportReason.spam));

    expect(ok, isTrue);
    expect(cubit.state, isTrue);
    await cubit.close();
  });

  test('report() devuelve false si el repositorio falla', () async {
    when(() => repo.reportArticle(any())).thenAnswer((_) async => const DataFailed(ServerFailure('boom')));
    final cubit = buildCubit();

    final ok = await cubit.report(const ReportArticleParams(articleId: 'a1', reason: ReportReason.spam));

    expect(ok, isFalse);
    await cubit.close();
  });

  test('checkReported() refleja el resultado del repositorio en el estado', () async {
    when(() => repo.hasReported(any())).thenAnswer((_) async => const DataSuccess(true));
    final cubit = buildCubit();

    await cubit.checkReported('a1');

    expect(cubit.state, isTrue);
    await cubit.close();
  });

  test('decide() pasa la decisión al repositorio', () async {
    when(() => repo.decideOnArticle(any())).thenAnswer((_) async => const DataSuccess(null));
    final cubit = buildCubit();

    final ok = await cubit.decide(const DecideParams(articleId: 'a1', decision: ModerationDecision.approve));

    expect(ok, isTrue);
    final captured = verify(() => repo.decideOnArticle(captureAny())).captured.single as DecideParams;
    expect(captured.decision, ModerationDecision.approve);
    await cubit.close();
  });
}
