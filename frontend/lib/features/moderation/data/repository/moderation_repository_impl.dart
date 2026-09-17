import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/moderation/data/data_sources/remote/moderation_firestore_data_source.dart';
import 'package:news_app/features/moderation/domain/params/decide_params.dart';
import 'package:news_app/features/moderation/domain/params/report_article_params.dart';
import 'package:news_app/features/moderation/domain/repository/moderation_repository.dart';
import 'package:news_app/shared/data/mappers/firebase_failure_mapper.dart';

class ModerationRepositoryImpl implements ModerationRepository {
  final ModerationFirestoreDataSource _dataSource;

  ModerationRepositoryImpl(this._dataSource);

  @override
  Future<DataState<void>> reportArticle(ReportArticleParams params) async {
    try {
      await _dataSource.reportArticle(params);
      return const DataSuccess(null);
    } on FirebaseException catch (e) {
      return DataFailed(mapFirebaseExceptionToFailure(e));
    }
  }

  @override
  Future<DataState<bool>> hasReported(String articleId) async {
    try {
      return DataSuccess(await _dataSource.hasReported(articleId));
    } on FirebaseException catch (e) {
      return DataFailed(mapFirebaseExceptionToFailure(e));
    }
  }

  @override
  Future<DataState<bool>> isStaff() async {
    try {
      return DataSuccess(await _dataSource.isStaff());
    } on FirebaseException catch (e) {
      return DataFailed(mapFirebaseExceptionToFailure(e));
    }
  }

  @override
  Future<DataState<void>> decideOnArticle(DecideParams params) async {
    try {
      await _dataSource.decideOnArticle(params);
      return const DataSuccess(null);
    } on FirebaseException catch (e) {
      return DataFailed(mapFirebaseExceptionToFailure(e));
    }
  }

  @override
  Future<DataState<PaginatedResult<AuthoredArticleEntity>>> listSuspended({String? cursor}) async {
    try {
      final page = await _dataSource.listSuspended(cursor: cursor);
      return DataSuccess(PaginatedResult(items: page.items, nextCursor: page.nextCursor));
    } on FirebaseException catch (e) {
      return DataFailed(mapFirebaseExceptionToFailure(e));
    }
  }
}
