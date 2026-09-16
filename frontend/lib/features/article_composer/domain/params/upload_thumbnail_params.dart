import 'package:equatable/equatable.dart';

class UploadThumbnailParams extends Equatable {
  final String articleId;
  final String filePath;

  const UploadThumbnailParams({required this.articleId, required this.filePath});

  @override
  List<Object?> get props => [articleId, filePath];
}
