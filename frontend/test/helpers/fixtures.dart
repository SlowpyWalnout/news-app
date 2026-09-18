import 'package:news_app/features/article_composer/domain/entities/article_category.dart';
import 'package:news_app/features/article_composer/domain/entities/article_status.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/auth/domain/entities/user_entity.dart';
import 'package:news_app/features/daily_news/domain/entities/article.dart';
import 'package:news_app/features/moderation/domain/entities/moderation_state.dart';
import 'package:news_app/shared/settings/domain/entities/app_settings_entity.dart';
import 'package:news_app/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Shared entity fixture — defaults match the fixture that used to be
/// duplicated across `feed_bloc_test.dart`, `my_articles_bloc_test.dart`,
/// `read_later_bloc_test.dart`, `moderation_cubit_test.dart` and
/// `report_article_use_case_test.dart`. Do not change the defaults without
/// checking every caller that relies on them implicitly.
AuthoredArticleEntity authoredArticle(
  String id, {
  String authorId = 'author-1',
  String authorName = 'Autor',
  String? authorPhotoURL,
  String? title,
  String? body,
  ArticleStatus status = ArticleStatus.published,
  ArticleCategory category = ArticleCategory.general,
  String? thumbnailURL,
  String? thumbnailPath,
  List<String> searchKeywords = const [],
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? publishedAt,
  int reportCount = 0,
  ModerationState? moderationState,
  DateTime? suspendedAt,
  DateTime? approvedAt,
}) {
  final now = createdAt ?? DateTime(2026, 1, 1);
  return AuthoredArticleEntity(
    id: id,
    authorId: authorId,
    authorName: authorName,
    authorPhotoURL: authorPhotoURL,
    title: title ?? 'Título $id',
    body: body ?? 'Cuerpo $id',
    status: status,
    category: category,
    thumbnailURL: thumbnailURL,
    thumbnailPath: thumbnailPath,
    searchKeywords: searchKeywords,
    createdAt: now,
    updatedAt: updatedAt ?? now,
    publishedAt: publishedAt ?? now,
    reportCount: reportCount,
    moderationState: moderationState,
    suspendedAt: suspendedAt,
    approvedAt: approvedAt,
  );
}

const testUser = UserEntity(uid: 'u1', email: 'rosa@correo.com', displayName: 'Rosa');

ArticleEntity readLaterArticle({
  int? id = 1,
  String? sourceId,
  String title = 'Título',
  String? description,
  String publishedAt = '2026-01-01T00:00:00.000Z',
  bool isRead = false,
}) {
  return ArticleEntity(
    id: id,
    sourceId: sourceId,
    title: title,
    description: description ?? 'Descripción',
    publishedAt: publishedAt,
    isRead: isRead,
  );
}

/// Raw Firestore map matching `AuthoredArticleModel.fromFirestore`'s
/// expectations, with real [Timestamp] values — for model round-trip tests.
/// [minimal] drops every optional field to exercise the null-default paths.
Map<String, dynamic> firestoreArticleData({
  String authorId = 'author-1',
  String authorName = 'Autor',
  String? authorPhotoURL,
  String title = 'Título',
  String body = 'Cuerpo',
  String status = 'published',
  String category = 'general',
  String? thumbnailURL,
  String? thumbnailPath,
  List<String>? searchKeywords,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? publishedAt,
  int? reportCount,
  String? moderationState,
  DateTime? suspendedAt,
  DateTime? approvedAt,
  bool minimal = false,
}) {
  final now = createdAt ?? DateTime(2026, 1, 1);
  return {
    'authorId': authorId,
    'authorName': authorName,
    if (!minimal) 'authorPhotoURL': authorPhotoURL,
    'title': title,
    'body': body,
    'status': status,
    'category': category,
    if (!minimal) 'thumbnailURL': thumbnailURL,
    if (!minimal) 'thumbnailPath': thumbnailPath,
    if (!minimal && searchKeywords != null) 'searchKeywords': searchKeywords,
    'createdAt': Timestamp.fromDate(now),
    'updatedAt': Timestamp.fromDate(updatedAt ?? now),
    if (!minimal) 'publishedAt': publishedAt == null ? null : Timestamp.fromDate(publishedAt),
    if (!minimal && reportCount != null) 'reportCount': reportCount,
    if (!minimal) 'moderationState': moderationState,
    if (!minimal && suspendedAt != null) 'suspendedAt': Timestamp.fromDate(suspendedAt),
    if (!minimal && approvedAt != null) 'approvedAt': Timestamp.fromDate(approvedAt),
  };
}

AppSettingsEntity settings({
  ThemeMode themeMode = ThemeMode.system,
  Locale locale = const Locale('es'),
  AppAccent accent = AppAccent.lime,
  bool accessible = false,
}) {
  return AppSettingsEntity(
    themeMode: themeMode,
    locale: locale,
    accent: accent,
    accessible: accessible,
  );
}
