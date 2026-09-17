import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app/features/article_composer/domain/entities/article_category.dart';
import 'package:news_app/features/article_composer/domain/entities/article_status.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/moderation/domain/entities/moderation_state.dart';

class AuthoredArticleModel extends AuthoredArticleEntity {
  const AuthoredArticleModel({
    required super.id,
    required super.authorId,
    required super.authorName,
    super.authorPhotoURL,
    required super.title,
    required super.body,
    required super.status,
    required super.category,
    super.thumbnailURL,
    super.thumbnailPath,
    super.searchKeywords,
    required super.createdAt,
    required super.updatedAt,
    super.publishedAt,
    super.reportCount,
    super.moderationState,
    super.suspendedAt,
    super.approvedAt,
  });

  factory AuthoredArticleModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return AuthoredArticleModel(
      id: doc.id,
      authorId: data['authorId'] as String,
      authorName: data['authorName'] as String,
      authorPhotoURL: data['authorPhotoURL'] as String?,
      title: data['title'] as String,
      body: data['body'] as String,
      status: ArticleStatus.values.byName(data['status'] as String),
      category: ArticleCategory.values.byName(data['category'] as String),
      thumbnailURL: data['thumbnailURL'] as String?,
      thumbnailPath: data['thumbnailPath'] as String?,
      searchKeywords: List<String>.from(data['searchKeywords'] as List? ?? const []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate(),
      reportCount: (data['reportCount'] as int?) ?? 0,
      moderationState: ModerationState.fromValue(data['moderationState'] as String?),
      suspendedAt: (data['suspendedAt'] as Timestamp?)?.toDate(),
      approvedAt: (data['approvedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory AuthoredArticleModel.fromEntity(AuthoredArticleEntity entity) {
    return AuthoredArticleModel(
      id: entity.id,
      authorId: entity.authorId,
      authorName: entity.authorName,
      authorPhotoURL: entity.authorPhotoURL,
      title: entity.title,
      body: entity.body,
      status: entity.status,
      category: entity.category,
      thumbnailURL: entity.thumbnailURL,
      thumbnailPath: entity.thumbnailPath,
      searchKeywords: entity.searchKeywords,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      publishedAt: entity.publishedAt,
    );
  }

  // Content fields only — createdAt/updatedAt/publishedAt are server-fixed
  // (docs/DB_SCHEMA.md) and handled by the data source per operation, not here.
  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoURL': authorPhotoURL,
      'title': title,
      'body': body,
      'status': status.name,
      'category': category.name,
      'thumbnailURL': thumbnailURL,
      'thumbnailPath': thumbnailPath,
      'searchKeywords': searchKeywords,
    };
  }
}
