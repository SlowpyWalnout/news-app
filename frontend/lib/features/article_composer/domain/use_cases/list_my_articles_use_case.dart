import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/article_composer/domain/params/list_my_articles_params.dart';
import 'package:news_app/features/article_composer/domain/repository/authored_article_repository.dart';

class ListMyArticlesUseCase
    implements
        UseCase<DataState<PaginatedResult<AuthoredArticleEntity>>,
            ListMyArticlesParams> {
  final AuthoredArticleRepository _repository;

  ListMyArticlesUseCase(this._repository);

  @override
  Future<DataState<PaginatedResult<AuthoredArticleEntity>>> call(
    ListMyArticlesParams params,
  ) {
    return _repository.getMyArticles(params.authorId, cursor: params.cursor);
  }
}
