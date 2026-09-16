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
    this.hasMore = false,
    this.error,
  });

  final MyArticlesStatus status;
  final List<AuthoredArticleEntity> articles;
  final MyArticlesTab tab;
  final bool hasMore;
  final Failure? error;

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
    bool? hasMore,
    Failure? error,
  }) {
    return MyArticlesState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      tab: tab ?? this.tab,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, articles, tab, hasMore, error];
}
