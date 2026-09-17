import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/moderation/domain/repository/moderation_repository.dart';

class ListSuspendedArticlesUseCase implements UseCase<DataState<PaginatedResult<AuthoredArticleEntity>>, String?> {
  final ModerationRepository _repository;

  ListSuspendedArticlesUseCase(this._repository);

  @override
  Future<DataState<PaginatedResult<AuthoredArticleEntity>>> call(String? cursor) {
    return _repository.listSuspended(cursor: cursor);
  }
}
