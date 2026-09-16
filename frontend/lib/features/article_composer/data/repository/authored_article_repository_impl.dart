import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/article_composer/data/data_sources/remote/authored_article_firestore_data_source.dart';
import 'package:news_app/features/article_composer/domain/entities/article_category.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/article_composer/domain/repository/authored_article_repository.dart';
import 'package:news_app/shared/data/mappers/firebase_failure_mapper.dart';

class AuthoredArticleRepositoryImpl implements AuthoredArticleRepository {
  final AuthoredArticleFirestoreDataSource _dataSource;

  AuthoredArticleRepositoryImpl(this._dataSource);

  @override
  Future<DataState<PaginatedResult<AuthoredArticleEntity>>> getFeed({
    String? cursor,
    ArticleCategory? category,
  }) async {
    try {
      final page = await _dataSource.getFeed(cursor: cursor, category: category);
      return DataSuccess(PaginatedResult(items: page.items, nextCursor: page.nextCursor));
    } on FirebaseException catch (e) {
      return DataFailed(mapFirebaseExceptionToFailure(e));
    }
  }

  @override
  Future<DataState<PaginatedResult<AuthoredArticleEntity>>> getMyArticles(
    String authorId, {
    String? cursor,
  }) async {
    try {
      final page = await _dataSource.getMyArticles(authorId, cursor: cursor);
      return DataSuccess(PaginatedResult(items: page.items, nextCursor: page.nextCursor));
    } on FirebaseException catch (e) {
      return DataFailed(mapFirebaseExceptionToFailure(e));
    }
  }

  @override
  Future<DataState<AuthoredArticleEntity>> publishArticle(
    AuthoredArticleEntity article,
  ) async {
    try {
      return DataSuccess(await _dataSource.publishArticle(article));
    } on FirebaseException catch (e) {
      return DataFailed(mapFirebaseExceptionToFailure(e));
    }
  }

  @override
  Future<DataState<AuthoredArticleEntity>> saveDraft(
    AuthoredArticleEntity article,
  ) async {
    try {
      return DataSuccess(await _dataSource.saveDraft(article));
    } on FirebaseException catch (e) {
      return DataFailed(mapFirebaseExceptionToFailure(e));
    }
  }

  @override
  Future<DataState<AuthoredArticleEntity>> updateArticle(
    AuthoredArticleEntity article,
  ) async {
    try {
      return DataSuccess(await _dataSource.updateArticle(article));
    } on FirebaseException catch (e) {
      return DataFailed(mapFirebaseExceptionToFailure(e));
    }
  }

  @override
  Future<DataState<void>> deleteArticle(String articleId) async {
    try {
      await _dataSource.deleteArticle(articleId);
      return const DataSuccess(null);
    } on FirebaseException catch (e) {
      return DataFailed(mapFirebaseExceptionToFailure(e));
    }
  }

  @override
  Future<DataState<String>> uploadThumbnail(String articleId, String filePath) async {
    // Storage wiring (subida real + borrado en cascada) llega en el
    // siguiente paso de Fase 6 — ver ROADMAP.md.
    throw UnimplementedError(
      'uploadThumbnail: Storage data source pendiente (Fase 6, paso 5).',
    );
  }
}
