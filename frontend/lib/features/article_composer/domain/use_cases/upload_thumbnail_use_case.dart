import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/article_composer/domain/params/upload_thumbnail_params.dart';
import 'package:news_app/features/article_composer/domain/repository/authored_article_repository.dart';

class UploadThumbnailUseCase
    implements UseCase<DataState<String>, UploadThumbnailParams> {
  final AuthoredArticleRepository _repository;

  UploadThumbnailUseCase(this._repository);

  @override
  Future<DataState<String>> call(UploadThumbnailParams params) {
    return _repository.uploadThumbnail(params.articleId, params.filePath);
  }
}
