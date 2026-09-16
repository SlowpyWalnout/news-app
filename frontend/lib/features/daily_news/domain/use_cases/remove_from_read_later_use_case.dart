import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/daily_news/domain/entities/article.dart';
import 'package:news_app/features/daily_news/domain/repository/article_repository.dart';

class RemoveFromReadLaterUseCase implements UseCase<void, ArticleEntity> {

  final ArticleRepository _articleRepository;

  RemoveFromReadLaterUseCase(this._articleRepository);

  @override
  Future<void> call(ArticleEntity params) {
    return _articleRepository.removeFromReadLater(params);
  }

}
