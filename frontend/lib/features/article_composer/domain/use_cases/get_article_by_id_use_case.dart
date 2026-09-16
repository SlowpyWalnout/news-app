import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/article_composer/domain/repository/authored_article_repository.dart';

class GetArticleByIdUseCase implements UseCase<DataState<AuthoredArticleEntity?>, String> {
  final AuthoredArticleRepository _repository;

  GetArticleByIdUseCase(this._repository);

  @override
  Future<DataState<AuthoredArticleEntity?>> call(String articleId) {
    return _repository.getArticleById(articleId);
  }
}
