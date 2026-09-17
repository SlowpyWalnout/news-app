import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/moderation/domain/params/decide_params.dart';
import 'package:news_app/features/moderation/domain/params/report_article_params.dart';

abstract class ModerationRepository {
  Future<DataState<void>> reportArticle(ReportArticleParams params);

  Future<DataState<bool>> hasReported(String articleId);

  Future<DataState<bool>> isStaff();

  Future<DataState<void>> decideOnArticle(DecideParams params);

  Future<DataState<PaginatedResult<AuthoredArticleEntity>>> listSuspended({String? cursor});
}
