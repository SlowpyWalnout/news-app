import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/article_composer/domain/repository/authored_article_repository.dart';

class DeleteArticleUseCase implements UseCase<DataState<void>, String> {
  final AuthoredArticleRepository _repository;

  DeleteArticleUseCase(this._repository);

  @override
  Future<DataState<void>> call(String articleId) {
    return _repository.deleteArticle(articleId);
  }
}
