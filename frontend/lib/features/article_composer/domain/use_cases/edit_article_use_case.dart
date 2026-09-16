import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/article_composer/domain/repository/authored_article_repository.dart';
import 'package:news_app/features/article_composer/domain/use_cases/article_content_validator.dart';

class EditArticleUseCase
    implements UseCase<DataState<AuthoredArticleEntity>, AuthoredArticleEntity> {
  final AuthoredArticleRepository _repository;

  EditArticleUseCase(this._repository);

  @override
  Future<DataState<AuthoredArticleEntity>> call(AuthoredArticleEntity params) async {
    final validationError = validateArticleContent(params.title, params.body);
    if (validationError != null) {
      return DataFailed(validationError);
    }
    return _repository.updateArticle(params);
  }
}
