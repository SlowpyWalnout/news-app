import 'package:equatable/equatable.dart';
import 'package:news_app/core/resources/failure.dart';

import '../../../domain/entities/article_category.dart';
import '../../../domain/entities/authored_article_entity.dart';

enum FeedStatus { initial, loading, success, failure }

class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.initial,
    this.articles = const [],
    this.category,
    this.query = '',
    this.error,
  });

  final FeedStatus status;

  /// Full set fetched for the current category — text search filters this
  /// client-side, it never triggers a new fetch.
  final List<AuthoredArticleEntity> articles;
  final ArticleCategory? category;
  final String query;
  final Failure? error;

  List<AuthoredArticleEntity> get visibleArticles {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return articles;
    return articles
        .where((a) => a.title.toLowerCase().contains(q) || a.authorName.toLowerCase().contains(q))
        .toList();
  }

  bool get isEmpty => status == FeedStatus.success && visibleArticles.isEmpty;

  FeedState copyWith({
    FeedStatus? status,
    List<AuthoredArticleEntity>? articles,
    ArticleCategory? category,
    bool clearCategory = false,
    String? query,
    Failure? error,
  }) {
    return FeedState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      category: clearCategory ? null : (category ?? this.category),
      query: query ?? this.query,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, articles, category, query, error];
}
