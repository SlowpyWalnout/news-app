import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/article_composer/domain/entities/article_category.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/article_composer/domain/entities/upload_thumbnail_result.dart';
import 'package:news_app/features/article_composer/domain/params/get_feed_params.dart';
import 'package:news_app/features/article_composer/domain/repository/authored_article_repository.dart';
import 'package:news_app/features/article_composer/domain/use_cases/get_feed_use_case.dart';

/// Records the searchToken it was called with — the point of this test is
/// verifying GetFeedUseCase tokenizes the raw query before it ever reaches
/// the repository, since Firestore only allows a single array-contains.
class _RecordingRepository implements AuthoredArticleRepository {
  String? lastSearchToken;
  bool wasCalled = false;

  @override
  Future<DataState<PaginatedResult<AuthoredArticleEntity>>> getFeed({
    String? cursor,
    ArticleCategory? category,
    String? searchToken,
  }) async {
    wasCalled = true;
    lastSearchToken = searchToken;
    return DataSuccess(const PaginatedResult(items: []));
  }

  @override
  Future<DataState<PaginatedResult<AuthoredArticleEntity>>> getMyArticles(String authorId, {String? cursor}) async {
    throw UnimplementedError();
  }

  @override
  Future<DataState<AuthoredArticleEntity?>> getArticleById(String articleId) async {
    throw UnimplementedError();
  }

  @override
  Future<DataState<AuthoredArticleEntity>> publishArticle(AuthoredArticleEntity article) async {
    throw UnimplementedError();
  }

  @override
  Future<DataState<AuthoredArticleEntity>> saveDraft(AuthoredArticleEntity article) async {
    throw UnimplementedError();
  }

  @override
  Future<DataState<AuthoredArticleEntity>> updateArticle(AuthoredArticleEntity article) async {
    throw UnimplementedError();
  }

  @override
  Future<DataState<void>> deleteArticle(String articleId) async {
    throw UnimplementedError();
  }

  @override
  Future<DataState<UploadThumbnailResult>> uploadThumbnail(
    String articleId,
    String filePath, {
    void Function(double progress)? onProgress,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  group('GetFeedUseCase', () {
    test('a multi-word query reaches the repository as a single token', () async {
      final repo = _RecordingRepository();
      await GetFeedUseCase(repo)(const GetFeedParams(query: 'el nuevo Flutter'));

      expect(repo.wasCalled, isTrue);
      expect(repo.lastSearchToken, 'flutter');
    });

    test('a stopword-only query reaches the repository as null', () async {
      final repo = _RecordingRepository();
      await GetFeedUseCase(repo)(const GetFeedParams(query: 'de la'));

      expect(repo.lastSearchToken, isNull);
    });

    test('no query at all reaches the repository as null', () async {
      final repo = _RecordingRepository();
      await GetFeedUseCase(repo)(const GetFeedParams());

      expect(repo.lastSearchToken, isNull);
    });
  });
}
