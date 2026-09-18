import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/features/moderation/domain/params/decide_params.dart';
import 'package:news_app/features/moderation/domain/params/report_article_params.dart';
import 'package:news_app/features/moderation/domain/use_cases/decide_on_article_use_case.dart';
import 'package:news_app/features/moderation/domain/use_cases/has_reported_use_case.dart';
import 'package:news_app/features/moderation/domain/use_cases/report_article_use_case.dart';

/// Igual que ArticleActionsCubit: envoltura fina sobre los use cases para que
/// el detalle/la cola de revisión disparen acciones sin bloc dedicado.
///
/// El estado (`bool?`) es "¿el usuario actual ya reportó este artículo?":
/// `null` mientras no se ha consultado, `true`/`false` una vez resuelto.
/// Vive en el cubit, no en un `setState` de la pantalla, para que
/// `report()` pueda actualizarlo sin que el widget tenga que re-preguntar.
class ModerationCubit extends Cubit<bool?> {
  ModerationCubit(
    this._reportArticleUseCase,
    this._decideOnArticleUseCase,
    this._hasReportedUseCase,
  ) : super(null);

  final ReportArticleUseCase _reportArticleUseCase;
  final DecideOnArticleUseCase _decideOnArticleUseCase;
  final HasReportedUseCase _hasReportedUseCase;

  Future<void> checkReported(String articleId) async {
    final result = await _hasReportedUseCase(articleId);
    emit(result is DataSuccess<bool> && result.data == true);
  }

  Future<bool> report(ReportArticleParams params) async {
    final result = await _reportArticleUseCase(params);
    final ok = result is DataSuccess;
    if (ok) emit(true);
    return ok;
  }

  Future<bool> decide(DecideParams params) async {
    final result = await _decideOnArticleUseCase(params);
    return result is DataSuccess;
  }
}
