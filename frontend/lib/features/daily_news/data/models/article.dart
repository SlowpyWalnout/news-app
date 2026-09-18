import 'package:news_app/features/daily_news/domain/entities/article.dart';

class ArticleModel extends ArticleEntity {
  const ArticleModel({
    int ? id,
    String ? sourceId,
    String ? author,
    String ? title,
    String ? description,
    String ? url,
    String ? urlToImage,
    String ? publishedAt,
    String ? content,
    bool isRead = false,
  }): super(
    id: id,
    sourceId: sourceId,
    author: author,
    title: title,
    description: description,
    url: url,
    urlToImage: urlToImage,
    publishedAt: publishedAt,
    content: content,
    isRead: isRead,
  );

  factory ArticleModel.fromEntity(ArticleEntity entity) {
    return ArticleModel(
      id: entity.id,
      sourceId: entity.sourceId,
      author: entity.author,
      title: entity.title,
      description: entity.description,
      url: entity.url,
      urlToImage: entity.urlToImage,
      publishedAt: entity.publishedAt,
      content: entity.content,
      isRead: entity.isRead,
    );
  }
}