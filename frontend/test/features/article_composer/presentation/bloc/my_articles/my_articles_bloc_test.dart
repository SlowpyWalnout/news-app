import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/article_composer/domain/entities/article_category.dart';
import 'package:news_app/features/article_composer/domain/entities/article_status.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/article_composer/domain/entities/upload_thumbnail_result.dart';
import 'package:news_app/features/article_composer/domain/repository/authored_article_repository.dart';
import 'package:news_app/features/article_composer/domain/use_cases/delete_article_use_case.dart';
import 'package:news_app/features/article_composer/domain/use_cases/list_my_articles_use_case.dart';
import 'package:news_app/features/article_composer/presentation/bloc/my_articles/my_articles_bloc.dart';
import 'package:news_app/features/article_composer/presentation/bloc/my_articles/my_articles_event.dart';

AuthoredArticleEntity _article(String id) {
  final now = DateTime(2026, 1, 1);
  return AuthoredArticleEntity(
    id: id,
    authorId: 'author-1',
    authorName: 'Autor',
    title: 'Título $id',
    body: 'Cuerpo $id',
    status: ArticleStatus.published,
    category: ArticleCategory.general,
    createdAt: now,
    updatedAt: now,
    publishedAt: now,
  );
}

/// Hand-written fake — mocktail isn't available (see pubspec.yaml note).
class _FakeAuthoredArticleRepository implements AuthoredArticleRepository {
  _FakeAuthoredArticleRepository({this.result});

  DataState<PaginatedResult<AuthoredArticleEntity>>? result;

  @override
  Future<DataState<PaginatedResult<AuthoredArticleEntity>>> getFeed({String? cursor, ArticleCategory? category}) async {
    throw UnimplementedError();
  }

  @override
  Future<DataState<PaginatedResult<AuthoredArticleEntity>>> getMyArticles(String authorId, {String? cursor}) async {
    return result ?? DataSuccess(const PaginatedResult(items: []));
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
    return const DataSuccess(null);
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

MyArticlesBloc _bloc(_FakeAuthoredArticleRepository repo) => MyArticlesBloc(
      ListMyArticlesUseCase(repo),
      DeleteArticleUseCase(repo),
    );

void main() {
  group('MyArticlesBloc', () {
    test('cerrar el bloc a mitad de un MyArticlesRefreshed no lanza error', () async {
      final repo = _FakeAuthoredArticleRepository(
        result: DataSuccess(PaginatedResult(items: [_article('1')])),
      );
      final bloc = _bloc(repo);

      Object? uncaught;
      runZonedGuarded(() {
        bloc.add(const MyArticlesRequested('author-1'));
        bloc.add(const MyArticlesRefreshed('author-1'));
      }, (error, stack) => uncaught = error);

      // El handler está en medio del Future.delayed(1s) del refresh cuando
      // el bloc se cierra, simulando el tab siendo descartado por el
      // PageView del AppShell.
      await Future.delayed(const Duration(milliseconds: 10));
      await bloc.close();
      await pumpEventQueue();

      expect(uncaught, isNull);
    });
  });
}
