import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/article_composer/domain/repository/authored_article_repository.dart';
import 'package:news_app/features/article_composer/domain/use_cases/article_content_validator.dart';

class SaveDraftUseCase
    implements UseCase<DataState<AuthoredArticleEntity>, AuthoredArticleEntity> {
  final AuthoredArticleRepository _repository;

  SaveDraftUseCase(this._repository);

  @override
  Future<DataState<AuthoredArticleEntity>> call(AuthoredArticleEntity params) async {
    // A half-written draft is legitimate — only the hard length caps apply,
    // never the "must not be empty" rule from validateArticleContent.
    if (params.title.length > kArticleTitleMaxLength) {
      return DataFailed(
        ValidationFailure('El título no puede superar los $kArticleTitleMaxLength caracteres.'),
      );
    }
    if (params.body.length > kArticleBodyMaxLength) {
      return DataFailed(
        ValidationFailure('El cuerpo no puede superar los $kArticleBodyMaxLength caracteres.'),
      );
    }
    return _repository.saveDraft(params);
  }
}
