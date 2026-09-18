import 'package:equatable/equatable.dart';
import 'package:news_app/core/resources/failure.dart';

import '../../../domain/entities/article_category.dart';
import '../../../domain/use_cases/article_content_validator.dart';

enum EditorSubmitStatus { idle, savingDraft, publishing, success, failure, emptyDraftRejected }

class ArticleEditorState extends Equatable {
  const ArticleEditorState({
    this.articleId = '',
    this.authorId = '',
    this.authorName = '',
    this.title = '',
    this.body = '',
    this.category = ArticleCategory.general,
    this.thumbnailURL,
    this.coverLocalPath,
    this.coverFileName,
    this.coverFileSizeBytes,
    this.coverError,
    this.touched = false,
    this.submitStatus = EditorSubmitStatus.idle,
    this.error,
    this.uploadProgress,
  });

  final String articleId;
  final String authorId;
  final String authorName;
  final String title;
  final String body;
  final ArticleCategory category;
  final String? thumbnailURL;

  /// Locally picked cover, pending upload — not yet reflected in
  /// [thumbnailURL] until the article is saved.
  final String? coverLocalPath;
  final String? coverFileName;
  final int? coverFileSizeBytes;
  final String? coverError;

  /// True once a publish was attempted — gates showing validation errors,
  /// so they don't appear while the user is still filling the form.
  final bool touched;
  final EditorSubmitStatus submitStatus;
  final Failure? error;

  /// Progress in [0, 1] of the cover upload, or null when not uploading.
  final double? uploadProgress;

  bool get isEditing => articleId.isNotEmpty;
  bool get hasCover => coverLocalPath != null || (thumbnailURL != null && thumbnailURL!.isNotEmpty);

  String? get titleError =>
      touched && title.trim().isEmpty ? 'El título no puede quedar vacío.' : null;
  String? get bodyError =>
      touched && body.trim().isEmpty ? 'Falta el cuerpo de la nota.' : null;

  bool get isValid =>
      title.trim().isNotEmpty && body.trim().isNotEmpty && title.length <= kArticleTitleMaxLength;

  ArticleEditorState copyWith({
    String? articleId,
    String? authorId,
    String? authorName,
    String? title,
    String? body,
    ArticleCategory? category,
    String? thumbnailURL,
    String? coverLocalPath,
    String? coverFileName,
    int? coverFileSizeBytes,
    bool clearCover = false,
    String? coverError,
    bool clearCoverError = false,
    bool? touched,
    EditorSubmitStatus? submitStatus,
    Failure? error,
    bool clearError = false,
    double? uploadProgress,
    bool clearUploadProgress = false,
  }) {
    return ArticleEditorState(
      articleId: articleId ?? this.articleId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      thumbnailURL: thumbnailURL ?? this.thumbnailURL,
      coverLocalPath: clearCover ? null : (coverLocalPath ?? this.coverLocalPath),
      coverFileName: clearCover ? null : (coverFileName ?? this.coverFileName),
      coverFileSizeBytes: clearCover ? null : (coverFileSizeBytes ?? this.coverFileSizeBytes),
      coverError: clearCoverError ? null : (coverError ?? this.coverError),
      touched: touched ?? this.touched,
      submitStatus: submitStatus ?? this.submitStatus,
      error: clearError ? null : (error ?? this.error),
      uploadProgress: clearUploadProgress ? null : (uploadProgress ?? this.uploadProgress),
    );
  }

  @override
  List<Object?> get props => [
        articleId,
        authorId,
        authorName,
        title,
        body,
        category,
        thumbnailURL,
        coverLocalPath,
        coverFileName,
        coverFileSizeBytes,
        coverError,
        touched,
        submitStatus,
        error,
        uploadProgress,
      ];
}
