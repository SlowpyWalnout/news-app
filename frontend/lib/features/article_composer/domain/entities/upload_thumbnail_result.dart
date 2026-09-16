import 'package:equatable/equatable.dart';

/// Both fields are kept, not just [url]: deriving the Storage object path
/// back from its download URL is fragile (see docs/DB_SCHEMA.md), so
/// [path] is threaded through to `AuthoredArticleEntity.thumbnailPath` for a
/// reliable delete later.
class UploadThumbnailResult extends Equatable {
  final String url;
  final String path;

  const UploadThumbnailResult({required this.url, required this.path});

  @override
  List<Object?> get props => [url, path];
}
