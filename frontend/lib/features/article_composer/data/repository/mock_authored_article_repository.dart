import 'package:uuid/uuid.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/article_composer/domain/entities/article_category.dart';
import 'package:news_app/features/article_composer/domain/entities/article_status.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/article_composer/domain/repository/authored_article_repository.dart';

// Temporary in-memory stand-in for the Firebase-backed implementation that
// Fase 6 will add. Lets Fase 5 build and exercise real blocs/screens against
// data that behaves like Firestore (pagination, ownership) without a backend
// dependency yet.
class MockAuthoredArticleRepository implements AuthoredArticleRepository {
  final List<AuthoredArticleEntity> _articles;
  final _uuid = const Uuid();

  MockAuthoredArticleRepository({List<AuthoredArticleEntity>? seed})
      : _articles = seed ?? _seedArticles();

  static List<AuthoredArticleEntity> _seedArticles() {
    final now = DateTime.now();
    return List.generate(5, (index) {
      final publishedAt = now.subtract(Duration(days: index));
      return AuthoredArticleEntity(
        id: 'mock-$index',
        authorId: 'mock-author',
        authorName: 'Mock Author',
        title: 'Mock article #$index',
        body: 'Body of mock article number $index.',
        status: ArticleStatus.published,
        category: ArticleCategory.values[index % ArticleCategory.values.length],
        searchKeywords: ['mock', 'article', '$index'],
        createdAt: publishedAt,
        updatedAt: publishedAt,
        publishedAt: publishedAt,
      );
    });
  }

  @override
  Future<DataState<PaginatedResult<AuthoredArticleEntity>>> getFeed({
    String? cursor,
    ArticleCategory? category,
  }) async {
    final published = _articles
        .where((article) => article.status == ArticleStatus.published)
        .where((article) => category == null || article.category == category)
        .toList()
      ..sort((a, b) => b.publishedAt!.compareTo(a.publishedAt!));
    return DataSuccess(PaginatedResult(items: published));
  }

  @override
  Future<DataState<PaginatedResult<AuthoredArticleEntity>>> getMyArticles(
    String authorId, {
    String? cursor,
  }) async {
    final mine = _articles.where((article) => article.authorId == authorId).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return DataSuccess(PaginatedResult(items: mine));
  }

  @override
  Future<DataState<AuthoredArticleEntity>> publishArticle(
    AuthoredArticleEntity article,
  ) async {
    final now = DateTime.now();
    final published = article.copyWith(
      status: ArticleStatus.published,
      updatedAt: now,
      publishedAt: now,
    );
    final withId = AuthoredArticleEntity(
      id: article.id.isEmpty ? _uuid.v4() : article.id,
      authorId: published.authorId,
      authorName: published.authorName,
      authorPhotoURL: published.authorPhotoURL,
      title: published.title,
      body: published.body,
      status: published.status,
      category: published.category,
      thumbnailURL: published.thumbnailURL,
      thumbnailPath: published.thumbnailPath,
      searchKeywords: published.searchKeywords,
      createdAt: published.createdAt,
      updatedAt: published.updatedAt,
      publishedAt: published.publishedAt,
    );
    _articles.add(withId);
    return DataSuccess(withId);
  }

  @override
  Future<DataState<AuthoredArticleEntity>> updateArticle(
    AuthoredArticleEntity article,
  ) async {
    final index = _articles.indexWhere((existing) => existing.id == article.id);
    if (index == -1) {
      return const DataFailed(ServerFailure('Artículo no encontrado.'));
    }
    final updated = article.copyWith(updatedAt: DateTime.now());
    _articles[index] = updated;
    return DataSuccess(updated);
  }

  @override
  Future<DataState<void>> deleteArticle(String articleId) async {
    _articles.removeWhere((article) => article.id == articleId);
    return const DataSuccess(null);
  }

  @override
  Future<DataState<String>> uploadThumbnail(String articleId, String filePath) async {
    return DataSuccess('https://placehold.co/600x400?text=$articleId');
  }
}
