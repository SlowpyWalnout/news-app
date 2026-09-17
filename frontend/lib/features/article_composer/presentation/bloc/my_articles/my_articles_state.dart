import 'package:equatable/equatable.dart';
import 'package:news_app/core/resources/failure.dart';

import '../../../domain/entities/article_status.dart';
import '../../../domain/entities/authored_article_entity.dart';
import 'my_articles_event.dart';

enum MyArticlesStatus { initial, loading, success, failure }

class MyArticlesState extends Equatable {
  const MyArticlesState({
    this.status = MyArticlesStatus.initial,
    this.articles = const [],
    this.tab = MyArticlesTab.all,
    this.nextCursor,
    this.isLoadingMore = false,
    this.error,
  });

  final MyArticlesStatus status;
  final List<AuthoredArticleEntity> articles;
  final MyArticlesTab tab;
  final String? nextCursor;
  final bool isLoadingMore;
  final Failure? error;

  bool get hasMore => nextCursor != null;

  List<AuthoredArticleEntity> get visibleArticles {
    switch (tab) {
      case MyArticlesTab.all:
        return articles;
      case MyArticlesTab.drafts:
        return articles.where((a) => a.status == ArticleStatus.draft).toList();
      case MyArticlesTab.published:
        return articles.where((a) => a.status == ArticleStatus.published).toList();
    }
  }

  bool get isEmpty => status == MyArticlesStatus.success && visibleArticles.isEmpty;

  int get publishedCount => articles.where((a) => a.status == ArticleStatus.published).length;
  int get draftsCount => articles.where((a) => a.status == ArticleStatus.draft).length;

  MyArticlesState copyWith({
    MyArticlesStatus? status,
    List<AuthoredArticleEntity>? articles,
    MyArticlesTab? tab,
    String? nextCursor,
    bool clearCursor = false,
    bool? isLoadingMore,
    Failure? error,
  }) {
    return MyArticlesState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      tab: tab ?? this.tab,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [status, articles, tab, nextCursor, isLoadingMore, error];
}
