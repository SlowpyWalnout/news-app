import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/daily_news/domain/repository/article_repository.dart';

class MarkReadLaterArticleAsReadUseCase implements UseCase<void, int> {

  final ArticleRepository _articleRepository;

  MarkReadLaterArticleAsReadUseCase(this._articleRepository);

  @override
  Future<void> call(int params) {
    return _articleRepository.markReadLaterArticleAsRead(params);
  }

}
