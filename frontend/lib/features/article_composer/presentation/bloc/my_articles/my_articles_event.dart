import 'package:equatable/equatable.dart';

enum MyArticlesTab {
  all,
  drafts,
  published;

  /// Maps `ArticleChangesNotifier.lastSubTab`'s 'drafts'/'published'/null to
  /// a tab, or null to mean "don't change the current tab".
  static MyArticlesTab? fromSubTab(String? subTab) => switch (subTab) {
        'drafts' => MyArticlesTab.drafts,
        'published' => MyArticlesTab.published,
        _ => null,
      };
}

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

class MyArticlesMoreRequested extends MyArticlesEvent {
  const MyArticlesMoreRequested();
}

class MyArticleDeleted extends MyArticlesEvent {
  const MyArticleDeleted(this.articleId);

  final String articleId;

  @override
  List<Object?> get props => [articleId];
}
