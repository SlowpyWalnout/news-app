import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/moderation/domain/params/report_article_params.dart';
import 'package:news_app/features/moderation/domain/repository/moderation_repository.dart';

class ReportArticleUseCase implements UseCase<DataState<void>, ReportArticleParams> {
  final ModerationRepository _repository;

  ReportArticleUseCase(this._repository);

  @override
  Future<DataState<void>> call(ReportArticleParams params) {
    return _repository.reportArticle(params);
  }
}
