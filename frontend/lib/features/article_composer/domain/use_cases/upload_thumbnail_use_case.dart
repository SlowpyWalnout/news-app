import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/article_composer/domain/entities/upload_thumbnail_result.dart';
import 'package:news_app/features/article_composer/domain/params/upload_thumbnail_params.dart';
import 'package:news_app/features/article_composer/domain/repository/authored_article_repository.dart';

class UploadThumbnailUseCase
    implements UseCase<DataState<UploadThumbnailResult>, UploadThumbnailParams> {
  final AuthoredArticleRepository _repository;

  UploadThumbnailUseCase(this._repository);

  @override
  Future<DataState<UploadThumbnailResult>> call(
    UploadThumbnailParams params, {
    void Function(double progress)? onProgress,
  }) {
    return _repository.uploadThumbnail(
      params.articleId,
      params.filePath,
      onProgress: onProgress,
    );
  }
}
