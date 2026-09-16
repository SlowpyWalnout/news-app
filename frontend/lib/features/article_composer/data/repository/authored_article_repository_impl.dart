import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/article_composer/data/data_sources/remote/authored_article_firestore_data_source.dart';
import 'package:news_app/features/article_composer/data/data_sources/remote/authored_article_storage_data_source.dart';
import 'package:news_app/features/article_composer/domain/entities/article_category.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/article_composer/domain/entities/upload_thumbnail_result.dart';
import 'package:news_app/features/article_composer/domain/repository/authored_article_repository.dart';
import 'package:news_app/shared/data/mappers/firebase_failure_mapper.dart';

class AuthoredArticleRepositoryImpl implements AuthoredArticleRepository {
  final AuthoredArticleFirestoreDataSource _dataSource;
  final AuthoredArticleStorageDataSource _storageDataSource;

  AuthoredArticleRepositoryImpl(this._dataSource, this._storageDataSource);

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
      // Storage primero, Firestore después (ROADMAP.md): si falla el borrado
      // de Firestore, queda una imagen huérfana (recuperable) en vez de un
      // documento con un thumbnailPath que ya no existe.
      final thumbnailPath = await _dataSource.getThumbnailPath(articleId);
      if (thumbnailPath != null) {
        await _storageDataSource.deleteThumbnail(thumbnailPath);
      }
      await _dataSource.deleteArticle(articleId);
      return const DataSuccess(null);
    } on FirebaseException catch (e) {
      return DataFailed(mapFirebaseExceptionToFailure(e));
    }
  }

  @override
  Future<DataState<UploadThumbnailResult>> uploadThumbnail(
    String articleId,
    String filePath, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      return DataSuccess(await _storageDataSource.uploadThumbnail(
        articleId,
        filePath,
        onProgress: onProgress,
      ));
    } on FirebaseException catch (e) {
      return DataFailed(mapFirebaseExceptionToFailure(e));
    }
  }
}
