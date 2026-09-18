import 'package:news_app/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app/features/daily_news/data/models/article.dart';
import 'package:news_app/features/daily_news/domain/entities/article.dart';
import 'package:news_app/features/daily_news/domain/repository/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final AppDatabase _appDatabase;
  ArticleRepositoryImpl(this._appDatabase);

  @override
  Future<List<ArticleModel>> getReadLaterArticles() async {
    return _appDatabase.articleDAO.getArticles();
  }

  @override
  Future<void> removeFromReadLater(ArticleEntity article) {
    return _appDatabase.articleDAO.deleteArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> addToReadLater(ArticleEntity article) async {
    final sourceId = article.sourceId;
    if (sourceId != null) {
      final existing = await _appDatabase.articleDAO.findBySourceId(sourceId);
      if (existing != null) return;
    }
    return _appDatabase.articleDAO.insertArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> markReadLaterArticleAsRead(int id) {
    return _appDatabase.articleDAO.markAsRead(id);
  }
}
