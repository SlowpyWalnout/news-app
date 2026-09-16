import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/article_composer/domain/params/get_feed_params.dart';
import 'package:news_app/features/article_composer/domain/repository/authored_article_repository.dart';

class GetFeedUseCase
    implements
        UseCase<DataState<PaginatedResult<AuthoredArticleEntity>>,
            GetFeedParams> {
  final AuthoredArticleRepository _repository;

  GetFeedUseCase(this._repository);

  @override
  Future<DataState<PaginatedResult<AuthoredArticleEntity>>> call(
    GetFeedParams params,
  ) {
    return _repository.getFeed(
      cursor: params.cursor,
      category: params.category,
    );
  }
}
