import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/article_composer/data/models/authored_article_model.dart';
import 'package:news_app/features/article_composer/domain/entities/article_category.dart';
import 'package:news_app/features/article_composer/domain/entities/article_status.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';

const int kFeedPageSize = 15;

class AuthoredArticleFirestoreDataSource {
  final FirebaseFirestore _firestore;

  AuthoredArticleFirestoreDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _articles =>
      _firestore.collection('articles');

  Future<PaginatedResult<AuthoredArticleModel>> getFeed({
    String? cursor,
    ArticleCategory? category,
  }) async {
    Query<Map<String, dynamic>> query = _articles
        .where('status', isEqualTo: ArticleStatus.published.name)
        .orderBy('publishedAt', descending: true)
        .orderBy(FieldPath.documentId, descending: true);
    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }
    final snapshot = await _applyCursor(query, cursor).limit(kFeedPageSize).get();
    return _toPage(snapshot);
  }

  Future<PaginatedResult<AuthoredArticleModel>> getMyArticles(
    String authorId, {
    String? cursor,
  }) async {
    final query = _articles
        .where('authorId', isEqualTo: authorId)
        .orderBy('updatedAt', descending: true)
        .orderBy(FieldPath.documentId, descending: true);
    final snapshot = await _applyCursor(query, cursor).limit(kFeedPageSize).get();
    return _toPage(snapshot);
  }

  // Cursor is the opaque "{millis}|{docId}" pair the domain layer just passes
  // back (see ROADMAP.md, Fase 4): millis of the last page's sort field plus
  // its doc id, so startAfter can break ties between same-timestamp docs.
  Query<Map<String, dynamic>> _applyCursor(
    Query<Map<String, dynamic>> query,
    String? cursor,
  ) {
    if (cursor == null) return query;
    final separator = cursor.indexOf('|');
    final millis = int.parse(cursor.substring(0, separator));
    final docId = cursor.substring(separator + 1);
    return query.startAfter([Timestamp.fromMillisecondsSinceEpoch(millis), docId]);
  }

  PaginatedResult<AuthoredArticleModel> _toPage(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final items = snapshot.docs.map(AuthoredArticleModel.fromFirestore).toList();
    String? nextCursor;
    if (items.length == kFeedPageSize) {
      final last = items.last;
      final sortValue = last.publishedAt ?? last.updatedAt;
      nextCursor = '${sortValue.millisecondsSinceEpoch}|${last.id}';
    }
    return PaginatedResult(items: items, nextCursor: nextCursor);
  }

  Future<AuthoredArticleModel> publishArticle(AuthoredArticleEntity article) {
    return _upsert(article, ArticleStatus.published);
  }

  Future<AuthoredArticleModel> saveDraft(AuthoredArticleEntity article) {
    return _upsert(article, ArticleStatus.draft);
  }

  Future<AuthoredArticleModel> updateArticle(AuthoredArticleEntity article) {
    return _upsert(article, article.status);
  }

  // `createdAt` must round-trip unchanged and `publishedAt` must only be set
  // once (firestore.rules enforces both), so an existing doc is read first
  // instead of trusting the timestamps on the incoming entity.
  Future<AuthoredArticleModel> _upsert(
    AuthoredArticleEntity article,
    ArticleStatus status,
  ) async {
    final ref = article.id.isEmpty ? _articles.doc() : _articles.doc(article.id);
    final existing = article.id.isEmpty ? null : await ref.get();
    final data = AuthoredArticleModel.fromEntity(article).toFirestore();
    data['status'] = status.name;
    data['updatedAt'] = FieldValue.serverTimestamp();

    if (existing != null && existing.exists) {
      data['createdAt'] = existing.get('createdAt');
      final existingPublishedAt = existing.get('publishedAt');
      data['publishedAt'] = status == ArticleStatus.published
          ? (existingPublishedAt ?? FieldValue.serverTimestamp())
          : null;
    } else {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['publishedAt'] =
          status == ArticleStatus.published ? FieldValue.serverTimestamp() : null;
    }

    await ref.set(data);
    final snapshot = await ref.get();
    return AuthoredArticleModel.fromFirestore(snapshot);
  }

  Future<void> deleteArticle(String articleId) {
    return _articles.doc(articleId).delete();
  }

  Future<String?> getThumbnailPath(String articleId) async {
    final snapshot = await _articles.doc(articleId).get();
    if (!snapshot.exists) return null;
    return snapshot.data()?['thumbnailPath'] as String?;
  }
}
