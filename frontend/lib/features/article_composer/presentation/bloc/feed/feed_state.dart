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
    this.preferredLang,
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

  /// UI locale's language code (`'es'`/`'en'`), or `null` before the first
  /// [FeedPreferredLanguageChanged]. Only reorders external headlines within
  /// the page(s) already loaded — never filters, and community articles
  /// (whose `lang` is always `null`) never move relative to each other.
  final String? preferredLang;

  bool get hasMore => nextCursor != null;

  /// The server already applies the single (most selective) token via
  /// array-contains. When the query has more than one token, the rest are
  /// matched here against each article's own `searchKeywords` — never
  /// against raw title substrings, so client and server agree on what
  /// "matches" means.
  List<AuthoredArticleEntity> get visibleArticles {
    final tokens = searchTokensFor(query);
    final filtered = tokens.length <= 1
        ? articles
        : articles
            .where((a) => tokens.every(a.searchKeywords.contains))
            .toList();
    return _prioritizedByLanguage(filtered);
  }

  // Same shape as ReadLaterBloc._sortUnreadFirst: partition instead of sort
  // (List.sort isn't stable), each group keeps the order it arrived in.
  // Matching-language headlines float to the top; everything else — the
  // other language's headlines AND every community article — stays grouped
  // together in its existing relative order.
  List<AuthoredArticleEntity> _prioritizedByLanguage(
      List<AuthoredArticleEntity> source) {
    if (preferredLang == null) return source;
    final matching = source.where((a) => a.lang == preferredLang).toList();
    final rest = source.where((a) => a.lang != preferredLang).toList();
    return [...matching, ...rest];
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
    String? preferredLang,
  }) {
    return FeedState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      category: clearCategory ? null : (category ?? this.category),
      query: query ?? this.query,
      error: error,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      preferredLang: preferredLang ?? this.preferredLang,
    );
  }

  @override
  List<Object?> get props => [
        status,
        articles,
        category,
        query,
        error,
        nextCursor,
        isLoadingMore,
        preferredLang,
      ];
}
