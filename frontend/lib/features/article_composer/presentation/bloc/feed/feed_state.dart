import 'package:equatable/equatable.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/shared/utils/search_keywords.dart';

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
    this.nextCursor,
    this.isLoadingMore = false,
  });

  final FeedStatus status;

  /// The page(s) fetched for the current category + search token. Only the
  /// tokens beyond the single one sent as array-contains still need
  /// client-side filtering — see [visibleArticles].
  final List<AuthoredArticleEntity> articles;
  final ArticleCategory? category;
  final String query;
  final Failure? error;
  final String? nextCursor;
  final bool isLoadingMore;

  bool get hasMore => nextCursor != null;

  /// The server already applies the single (most selective) token via
  /// array-contains. When the query has more than one token, the rest are
  /// matched here against each article's own `searchKeywords` — never
  /// against raw title substrings, so client and server agree on what
  /// "matches" means.
  List<AuthoredArticleEntity> get visibleArticles {
    final tokens = searchTokensFor(query);
    if (tokens.length <= 1) return articles;
    return articles
        .where((a) => tokens.every(a.searchKeywords.contains))
        .toList();
  }

  bool get isEmpty =>
      status == FeedStatus.success && visibleArticles.isEmpty && !hasMore;

  FeedState copyWith({
    FeedStatus? status,
    List<AuthoredArticleEntity>? articles,
    ArticleCategory? category,
    bool clearCategory = false,
    String? query,
    Failure? error,
    String? nextCursor,
    bool clearCursor = false,
    bool? isLoadingMore,
  }) {
    return FeedState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      category: clearCategory ? null : (category ?? this.category),
      query: query ?? this.query,
      error: error,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props =>
      [status, articles, category, query, error, nextCursor, isLoadingMore];
}
