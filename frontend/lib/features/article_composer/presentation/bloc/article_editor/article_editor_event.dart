import 'package:equatable/equatable.dart';

import '../../../domain/entities/article_category.dart';
import '../../../domain/entities/authored_article_entity.dart';

abstract class ArticleEditorEvent extends Equatable {
  const ArticleEditorEvent();

  @override
  List<Object?> get props => [];
}

/// `article == null` starts a brand-new draft for [authorId]/[authorName];
/// otherwise the editor is pre-filled to edit an existing article.
class EditorStarted extends ArticleEditorEvent {
  const EditorStarted({required this.authorId, required this.authorName, this.article});

  final String authorId;
  final String authorName;
  final AuthoredArticleEntity? article;

  @override
  List<Object?> get props => [authorId, authorName, article];
}

class EditorTitleChanged extends ArticleEditorEvent {
  const EditorTitleChanged(this.title);
  final String title;

  @override
  List<Object?> get props => [title];
}

class EditorBodyChanged extends ArticleEditorEvent {
  const EditorBodyChanged(this.body);
  final String body;

  @override
  List<Object?> get props => [body];
}

class EditorCategorySelected extends ArticleEditorEvent {
  const EditorCategorySelected(this.category);
  final ArticleCategory category;

  @override
  List<Object?> get props => [category];
}

class EditorCoverPicked extends ArticleEditorEvent {
  const EditorCoverPicked(this.filePath, this.fileSizeBytes);
  final String filePath;
  final int fileSizeBytes;

  @override
  List<Object?> get props => [filePath, fileSizeBytes];
}

class EditorCoverRemoved extends ArticleEditorEvent {
  const EditorCoverRemoved();
}

class EditorDraftSaved extends ArticleEditorEvent {
  const EditorDraftSaved();
}

class EditorPublishRequested extends ArticleEditorEvent {
  const EditorPublishRequested();
}
