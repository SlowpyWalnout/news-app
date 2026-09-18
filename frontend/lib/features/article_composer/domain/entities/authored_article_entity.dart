import 'package:equatable/equatable.dart';
import 'package:news_app/features/article_composer/domain/entities/article_category.dart';
import 'package:news_app/features/article_composer/domain/entities/article_source.dart';
import 'package:news_app/features/article_composer/domain/entities/article_status.dart';
import 'package:news_app/features/daily_news/domain/entities/article.dart';
import 'package:news_app/features/moderation/domain/entities/moderation_state.dart';
import 'package:news_app/shared/utils/markdown.dart';

class AuthoredArticleEntity extends Equatable {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoURL;
  final String title;
  final String body;
  final ArticleStatus status;
  final ArticleCategory category;
  final String? thumbnailURL;
  final String? thumbnailPath;
  // Derived server-write-side (see AuthoredArticleFirestoreDataSource._upsert)
  // from title/authorName/category — never trust a value set here by a caller.
  final List<String> searchKeywords;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  // Fase 6e — solo los escribe el servidor (Cloud Functions/staff), nunca el
  // cliente. Ausentes en Firestore == "nunca moderado". No van en copyWith:
  // igual que id/authorId/createdAt, el cliente no los muta directamente.
  final int reportCount;
  final ModerationState? moderationState;
  final DateTime? suspendedAt;
  final DateTime? approvedAt;
  // External news (Guardian/GNews). Written only by the backend crons — see
  // ArticleSource. Absent (source == null) means a community article. Not in
  // copyWith: same reasoning as reportCount/moderationState above, the
  // client never mutates these directly.
  final ArticleSource? source;
  final String? sourceName;
  final String? sourceUrl;
  final bool hasFullBody;
  final String? lang;

  bool get isExternal => source != null;

  const AuthoredArticleEntity({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoURL,
    required this.title,
    required this.body,
    required this.status,
    required this.category,
    this.thumbnailURL,
    this.thumbnailPath,
    this.searchKeywords = const [],
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    this.reportCount = 0,
    this.moderationState,
    this.suspendedAt,
    this.approvedAt,
    this.source,
    this.sourceName,
    this.sourceUrl,
    this.hasFullBody = false,
    this.lang,
  });

  // Adapts to the existing NewsAPI entity so favorites, the article tile and
  // the detail screen can be reused without touching them or Floor's schema.
  //
  // External news is never cached locally beyond title/summary/image: The
  // Guardian's terms forbid keeping their content past 24h, and sqflite rows
  // live on the device indefinitely, outside the reach of the backend's own
  // purge. `content: null` here is what enforces that — the reader always
  // re-fetches from Firestore (or shows "no longer available") instead of
  // reading a permanently-cached body. `url` carries the original source so
  // Read Later can still open it once the doc expires.
  ArticleEntity toFeedArticle() {
    final plainBody = stripMarkdown(body);
    return ArticleEntity(
      sourceId: id,
      author: authorName,
      title: title,
      description:
          plainBody.length > 200 ? plainBody.substring(0, 200) : plainBody,
      url: isExternal ? sourceUrl : null,
      urlToImage: thumbnailURL,
      publishedAt: publishedAt?.toIso8601String(),
      content: isExternal ? null : body,
    );
  }

  // Reverse of toFeedArticle(), for opening a Read it later row when the
  // fresh Firestore doc couldn't be fetched (offline, deleted...). Fields
  // Floor never stored (authorId, category, status, timestamps) are
  // synthesized; callers should treat the result as read-only — with a
  // synthesized empty authorId, `isMine` in ArticleDetailScreen is always
  // false, which is the desired "not owned" fallback presentation.
  factory AuthoredArticleEntity.fromCachedArticle(ArticleEntity cached) {
    final publishedAt = DateTime.tryParse(cached.publishedAt ?? '');
    return AuthoredArticleEntity(
      id: cached.sourceId ?? '',
      authorId: '',
      authorName: cached.author ?? '',
      title: cached.title ?? '',
      body: cached.content ?? cached.description ?? '',
      status: ArticleStatus.published,
      category: ArticleCategory.general,
      thumbnailURL: cached.urlToImage,
      createdAt: publishedAt ?? DateTime.now(),
      updatedAt: publishedAt ?? DateTime.now(),
      publishedAt: publishedAt,
    );
  }

  AuthoredArticleEntity copyWith({
    String? title,
    String? body,
    ArticleStatus? status,
    ArticleCategory? category,
    String? thumbnailURL,
    String? thumbnailPath,
    List<String>? searchKeywords,
    DateTime? updatedAt,
    DateTime? publishedAt,
  }) {
    return AuthoredArticleEntity(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorPhotoURL: authorPhotoURL,
      title: title ?? this.title,
      body: body ?? this.body,
      status: status ?? this.status,
      category: category ?? this.category,
      thumbnailURL: thumbnailURL ?? this.thumbnailURL,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  @override
  List<Object?> get props {
    return [
      id,
      authorId,
      authorName,
      authorPhotoURL,
      title,
      body,
      status,
      category,
      thumbnailURL,
      thumbnailPath,
      searchKeywords,
      createdAt,
      updatedAt,
      publishedAt,
      reportCount,
      moderationState,
      suspendedAt,
      approvedAt,
      source,
      sourceName,
      sourceUrl,
      hasFullBody,
      lang,
    ];
  }
}
