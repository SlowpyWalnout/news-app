import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/moderation/domain/params/decide_params.dart';
import 'package:news_app/features/moderation/domain/repository/moderation_repository.dart';

class DecideOnArticleUseCase implements UseCase<DataState<void>, DecideParams> {
  final ModerationRepository _repository;

  DecideOnArticleUseCase(this._repository);

  @override
  Future<DataState<void>> call(DecideParams params) {
    return _repository.decideOnArticle(params);
  }
}
