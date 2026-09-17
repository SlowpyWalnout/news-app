import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/features/moderation/domain/params/decide_params.dart';
import 'package:news_app/features/moderation/domain/params/report_article_params.dart';
import 'package:news_app/features/moderation/domain/repository/moderation_repository.dart';
import 'package:news_app/features/moderation/domain/use_cases/decide_on_article_use_case.dart';
import 'package:news_app/features/moderation/domain/use_cases/report_article_use_case.dart';

/// Igual que ArticleActionsCubit: envoltura fina sobre los use cases para que
/// el detalle/la cola de revisión disparen acciones sin bloc dedicado.
class ModerationCubit extends Cubit<void> {
  ModerationCubit(this._reportArticleUseCase, this._decideOnArticleUseCase, this._repository) : super(null);

  final ReportArticleUseCase _reportArticleUseCase;
  final DecideOnArticleUseCase _decideOnArticleUseCase;
  final ModerationRepository _repository;

  Future<bool> report(ReportArticleParams params) async {
    final result = await _reportArticleUseCase(params);
    return result is DataSuccess;
  }

  Future<bool> hasReported(String articleId) async {
    final result = await _repository.hasReported(articleId);
    return result is DataSuccess<bool> && result.data == true;
  }

  Future<bool> decide(DecideParams params) async {
    final result = await _decideOnArticleUseCase(params);
    return result is DataSuccess;
  }
}
