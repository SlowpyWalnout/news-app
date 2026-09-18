import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/article_composer/data/models/authored_article_model.dart';
import 'package:news_app/features/article_composer/data/repository/authored_article_repository_impl.dart';
import 'package:news_app/features/article_composer/domain/entities/upload_thumbnail_result.dart';

import '../../../../helpers/helpers.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  late MockAuthoredArticleFirestoreDataSource dataSource;
  late MockAuthoredArticleStorageDataSource storageDataSource;
  late AuthoredArticleRepositoryImpl repo;

  setUp(() {
    dataSource = MockAuthoredArticleFirestoreDataSource();
    storageDataSource = MockAuthoredArticleStorageDataSource();
    repo = AuthoredArticleRepositoryImpl(dataSource, storageDataSource);
  });

  test('getFeed forwards cursor/category/searchToken and rewraps the page', () async {
    final model = AuthoredArticleModel.fromEntity(authoredArticle('1'));
    when(() => dataSource.getFeed(
          cursor: any(named: 'cursor'),
          category: any(named: 'category'),
          searchToken: any(named: 'searchToken'),
        )).thenAnswer((_) async => PaginatedResult(items: [model], nextCursor: 'c1'));

    final result = await repo.getFeed(cursor: 'c0', searchToken: 'flutter');

    expect(result, isA<DataSuccess>());
    final data = (result as DataSuccess).data as PaginatedResult;
    expect(data.items.single.id, '1');
    expect(data.nextCursor, 'c1');
    verify(() => dataSource.getFeed(cursor: 'c0', category: null, searchToken: 'flutter')).called(1);
  });

  group('FirebaseException mapping', () {
    test('unavailable maps to NetworkFailure', () async {
      when(() => dataSource.getArticleById(any()))
          .thenThrow(FirebaseException(plugin: 'firestore', code: 'unavailable', message: 'down'));

      final result = await repo.getArticleById('a1');

      expect(result, isA<DataFailed>());
      expect((result as DataFailed).error, isA<NetworkFailure>());
    });

    test('firebase_storage plugin maps to StorageFailure', () async {
      when(() => storageDataSource.uploadThumbnail(any(), any(), onProgress: any(named: 'onProgress')))
          .thenThrow(FirebaseException(plugin: 'firebase_storage', code: 'unknown', message: 'boom'));

      final result = await repo.uploadThumbnail('a1', '/tmp/x.jpg');

      expect(result, isA<DataFailed>());
      expect((result as DataFailed).error, isA<StorageFailure>());
    });

    test('anything else maps to ServerFailure', () async {
      when(() => dataSource.publishArticle(any()))
          .thenThrow(FirebaseException(plugin: 'firestore', code: 'permission-denied', message: 'nope'));

      final result = await repo.publishArticle(authoredArticle('1'));

      expect(result, isA<DataFailed>());
      expect((result as DataFailed).error, isA<ServerFailure>());
    });

    test('a non-FirebaseException propagates uncaught', () async {
      when(() => dataSource.getMyArticles(any(), cursor: any(named: 'cursor'))).thenThrow(ArgumentError('bad enum'));

      expect(() => repo.getMyArticles('author-1'), throwsA(isA<ArgumentError>()));
    });
  });

  group('deleteArticle ordering', () {
    test('deletes the thumbnail before the Firestore doc when one exists', () async {
      when(() => dataSource.getThumbnailPath(any())).thenAnswer((_) async => 'media/articles/u1/a1/x.jpg');
      when(() => storageDataSource.deleteThumbnail(any())).thenAnswer((_) async {});
      when(() => dataSource.deleteArticle(any())).thenAnswer((_) async {});

      final result = await repo.deleteArticle('a1');

      expect(result, isA<DataSuccess<void>>());
      verifyInOrder([
        () => dataSource.getThumbnailPath('a1'),
        () => storageDataSource.deleteThumbnail('media/articles/u1/a1/x.jpg'),
        () => dataSource.deleteArticle('a1'),
      ]);
    });

    test('skips the Storage delete when there is no thumbnail', () async {
      when(() => dataSource.getThumbnailPath(any())).thenAnswer((_) async => null);
      when(() => dataSource.deleteArticle(any())).thenAnswer((_) async {});

      final result = await repo.deleteArticle('a1');

      expect(result, isA<DataSuccess<void>>());
      verifyNever(() => storageDataSource.deleteThumbnail(any()));
      verify(() => dataSource.deleteArticle('a1')).called(1);
    });

    // Fija la decisión documentada en ROADMAP.md ("Borrado: Storage primero,
    // Firestore después"): mejor una imagen huérfana (recuperable) que un
    // documento con un thumbnailPath que ya no existe.
    test('never deletes the Firestore doc when the Storage delete fails', () async {
      when(() => dataSource.getThumbnailPath(any())).thenAnswer((_) async => 'media/articles/u1/a1/x.jpg');
      when(() => storageDataSource.deleteThumbnail(any()))
          .thenThrow(FirebaseException(plugin: 'firebase_storage', code: 'unknown', message: 'boom'));

      final result = await repo.deleteArticle('a1');

      expect(result, isA<DataFailed>());
      expect((result as DataFailed).error, isA<StorageFailure>());
      verifyNever(() => dataSource.deleteArticle(any()));
    });
  });

  test('uploadThumbnail forwards onProgress and wraps the result', () async {
    void Function(double)? capturedProgress;
    when(() => storageDataSource.uploadThumbnail(any(), any(), onProgress: any(named: 'onProgress')))
        .thenAnswer((invocation) async {
      capturedProgress = invocation.namedArguments[#onProgress] as void Function(double)?;
      capturedProgress?.call(0.5);
      return const UploadThumbnailResult(url: 'https://x/y.jpg', path: 'media/articles/u1/a1/y.jpg');
    });

    final progressValues = <double>[];
    final result = await repo.uploadThumbnail('a1', '/tmp/x.jpg', onProgress: progressValues.add);

    expect(result, isA<DataSuccess<UploadThumbnailResult>>());
    expect((result as DataSuccess).data.url, 'https://x/y.jpg');
    expect(progressValues, [0.5]);
  });
}
