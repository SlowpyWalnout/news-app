import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/article_composer/domain/entities/article_category.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/article_composer/domain/entities/upload_thumbnail_result.dart';

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

  /// Upserts [article] as a draft. Unlike [publishArticle], the body may be
  /// empty — a half-written draft is a legitimate state.
  Future<DataState<AuthoredArticleEntity>> saveDraft(
    AuthoredArticleEntity article,
  );

  Future<DataState<AuthoredArticleEntity>> updateArticle(
    AuthoredArticleEntity article,
  );

  Future<DataState<void>> deleteArticle(String articleId);

  Future<DataState<UploadThumbnailResult>> uploadThumbnail(
    String articleId,
    String filePath, {
    void Function(double progress)? onProgress,
  });
}
