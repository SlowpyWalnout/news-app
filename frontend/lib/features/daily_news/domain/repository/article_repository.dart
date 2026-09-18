import 'package:news_app/features/daily_news/domain/entities/article.dart';

abstract class ArticleRepository {
  // Database methods
  Future < List < ArticleEntity >> getReadLaterArticles();

  Future < void > addToReadLater(ArticleEntity article);

  Future < void > removeFromReadLater(ArticleEntity article);

  Future < void > markReadLaterArticleAsRead(int id);
}