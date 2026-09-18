import 'package:sqflite/sqflite.dart';

import 'package:news_app/features/daily_news/data/models/article.dart';

class ArticleDao {
  ArticleDao(this._database);

  final Database _database;

  Future<void> insertArticle(ArticleModel article) async {
    await _database.insert('article', _toRow(article));
  }

  Future<void> deleteArticle(ArticleModel article) async {
    await _database.delete('article', where: 'id = ?', whereArgs: [article.id]);
  }

  Future<List<ArticleModel>> getArticles() async {
    final rows = await _database.query('article');
    return rows.map(_fromRow).toList();
  }

  Future<ArticleModel?> findBySourceId(String sourceId) async {
    final rows = await _database.query(
      'article',
      where: 'sourceId = ?',
      whereArgs: [sourceId],
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  Future<void> markAsRead(int id) async {
    await _database.update(
      'article',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, Object?> _toRow(ArticleModel article) => {
        'id': article.id,
        'sourceId': article.sourceId,
        'author': article.author,
        'title': article.title,
        'description': article.description,
        'url': article.url,
        'urlToImage': article.urlToImage,
        'publishedAt': article.publishedAt,
        'content': article.content,
        'isRead': article.isRead ? 1 : 0,
      };

  ArticleModel _fromRow(Map<String, Object?> row) => ArticleModel(
        id: row['id'] as int?,
        sourceId: row['sourceId'] as String?,
        author: row['author'] as String?,
        title: row['title'] as String?,
        description: row['description'] as String?,
        url: row['url'] as String?,
        urlToImage: row['urlToImage'] as String?,
        publishedAt: row['publishedAt'] as String?,
        content: row['content'] as String?,
        isRead: (row['isRead'] as int?) == 1,
      );
}
