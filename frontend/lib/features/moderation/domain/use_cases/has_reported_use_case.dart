import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/moderation/domain/repository/moderation_repository.dart';

class HasReportedUseCase implements UseCase<DataState<bool>, String> {
  final ModerationRepository _repository;

  HasReportedUseCase(this._repository);

  @override
  Future<DataState<bool>> call(String articleId) {
    return _repository.hasReported(articleId);
  }
}
