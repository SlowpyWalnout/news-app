import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/article_composer/domain/entities/article_category.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';

abstract class AuthoredArticleRepository {
  Future<DataState<PaginatedResult<AuthoredArticleEntity>>> getFeed({
    String? cursor,
    ArticleCategory? category,
  });

  Future<DataState<PaginatedResult<AuthoredArticleEntity>>> getMyArticles(
    String authorId, {
    String? cursor,
  });

  Future<DataState<AuthoredArticleEntity>> publishArticle(
    AuthoredArticleEntity article,
  );

  Future<DataState<AuthoredArticleEntity>> updateArticle(
    AuthoredArticleEntity article,
  );

  Future<DataState<void>> deleteArticle(String articleId);

  Future<DataState<String>> uploadThumbnail(String articleId, String filePath);
}
