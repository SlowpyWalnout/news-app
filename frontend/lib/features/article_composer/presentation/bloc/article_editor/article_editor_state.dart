import 'package:equatable/equatable.dart';
import 'package:news_app/core/resources/failure.dart';

import '../../../domain/entities/article_category.dart';
import '../../../domain/use_cases/article_content_validator.dart';

enum EditorSubmitStatus { idle, savingDraft, publishing, success, failure }

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
    this.coverError,
    this.touched = false,
    this.submitStatus = EditorSubmitStatus.idle,
    this.error,
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
  final String? coverError;

  final bool touched;
  final EditorSubmitStatus submitStatus;
  final Failure? error;

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
    bool clearCover = false,
    String? coverError,
    bool clearCoverError = false,
    bool? touched,
    EditorSubmitStatus? submitStatus,
    Failure? error,
    bool clearError = false,
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
      coverError: clearCoverError ? null : (coverError ?? this.coverError),
      touched: touched ?? this.touched,
      submitStatus: submitStatus ?? this.submitStatus,
      error: clearError ? null : (error ?? this.error),
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
        coverError,
        touched,
        submitStatus,
        error,
      ];
}
