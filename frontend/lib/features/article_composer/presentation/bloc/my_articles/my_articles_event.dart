import 'package:equatable/equatable.dart';

enum MyArticlesTab { all, drafts, published }

abstract class MyArticlesEvent extends Equatable {
  const MyArticlesEvent();

  @override
  List<Object?> get props => [];
}

class MyArticlesRequested extends MyArticlesEvent {
  const MyArticlesRequested(this.authorId);

  final String authorId;

  @override
  List<Object?> get props => [authorId];
}

class MyArticlesRefreshed extends MyArticlesEvent {
  const MyArticlesRefreshed(this.authorId);

  final String authorId;

  @override
  List<Object?> get props => [authorId];
}

class MyArticlesTabChanged extends MyArticlesEvent {
  const MyArticlesTabChanged(this.tab);

  final MyArticlesTab tab;

  @override
  List<Object?> get props => [tab];
}

/// The mock repository ignores the cursor and always returns
/// `nextCursor: null`, so this always resolves to "No hay más" — that is
/// the correct behaviour for Fase 5, not a bug to hide.
class MyArticlesMoreRequested extends MyArticlesEvent {
  const MyArticlesMoreRequested();
}

class MyArticleDeleted extends MyArticlesEvent {
  const MyArticleDeleted(this.articleId);

  final String articleId;

  @override
  List<Object?> get props => [articleId];
}
