import 'dart:io';

import 'package:dio/dio.dart';
import 'package:news_app/core/config/app_config.dart';
import 'package:news_app/core/constants/constants.dart';
import 'package:news_app/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app/features/daily_news/data/models/article.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/features/daily_news/domain/entities/article.dart';
import 'package:news_app/features/daily_news/domain/repository/article_repository.dart';

import '../data_sources/remote/news_api_service.dart';
import '../mappers/dio_failure_mapper.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;
  ArticleRepositoryImpl(this._newsApiService,this._appDatabase);
  
  @override
  Future<DataState<List<ArticleModel>>> getNewsArticles() async {
   try {
    final httpResponse = await _newsApiService.getNewsArticles(
      apiKey:AppConfig.newsApiKey,
      country:countryQuery,
      category:categoryQuery,
    );

    if (httpResponse.response.statusCode == HttpStatus.ok) {
      return DataSuccess(httpResponse.data);
    } else {
      return DataFailed(
        ServerFailure(
          httpResponse.response.statusMessage ?? 'Server error',
        ),
      );
    }
   } on DioException catch(e){
    return DataFailed(mapDioExceptionToFailure(e));
   }
  }

  @override
  Future<List<ArticleModel>> getReadLaterArticles() async {
    return _appDatabase.articleDAO.getArticles();
  }

  @override
  Future<void> removeFromReadLater(ArticleEntity article) {
    return _appDatabase.articleDAO.deleteArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> addToReadLater(ArticleEntity article) async {
    final sourceId = article.sourceId;
    if (sourceId != null) {
      final existing = await _appDatabase.articleDAO.findBySourceId(sourceId);
      if (existing != null) return;
    }
    return _appDatabase.articleDAO.insertArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> markReadLaterArticleAsRead(int id) {
    return _appDatabase.articleDAO.markAsRead(id);
  }

}