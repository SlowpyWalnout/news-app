import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/daily_news/domain/entities/article.dart';
import 'package:news_app/features/daily_news/domain/repository/article_repository.dart';

class GetReadLaterArticlesUseCase implements UseCase<List<ArticleEntity>, NoParams> {

  final ArticleRepository _articleRepository;

  GetReadLaterArticlesUseCase(this._articleRepository);

  @override
  Future<List<ArticleEntity>> call(NoParams params) {
    return _articleRepository.getReadLaterArticles();
  }

}
