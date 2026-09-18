import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/config/theme/app_colors.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/article_composer/data/data_sources/remote/authored_article_firestore_data_source.dart';
import 'package:news_app/features/article_composer/data/data_sources/remote/authored_article_storage_data_source.dart';
import 'package:news_app/features/article_composer/domain/entities/article_category.dart';
import 'package:news_app/features/article_composer/domain/entities/article_status.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/article_composer/domain/params/upload_thumbnail_params.dart';
import 'package:news_app/features/article_composer/domain/repository/authored_article_repository.dart';
import 'package:news_app/features/article_composer/domain/use_cases/delete_article_use_case.dart';
import 'package:news_app/features/article_composer/domain/use_cases/edit_article_use_case.dart';
import 'package:news_app/features/article_composer/domain/use_cases/publish_article_use_case.dart';
import 'package:news_app/features/article_composer/domain/use_cases/save_draft_use_case.dart';
import 'package:news_app/features/article_composer/domain/use_cases/upload_thumbnail_use_case.dart';
import 'package:news_app/features/auth/data/data_sources/remote/firebase_auth_data_source.dart';
import 'package:news_app/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app/features/auth/domain/params/sign_up_params.dart';
import 'package:news_app/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app/features/auth/domain/use_cases/get_current_user_use_case.dart';
import 'package:news_app/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:news_app/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app/features/daily_news/data/models/article.dart' as daily_news_model;
import 'package:news_app/features/daily_news/domain/entities/article.dart';
import 'package:news_app/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app/features/moderation/data/data_sources/remote/moderation_firestore_data_source.dart';
import 'package:news_app/features/moderation/domain/params/decide_params.dart';
import 'package:news_app/features/moderation/domain/params/report_article_params.dart';
import 'package:news_app/features/moderation/domain/entities/report_reason.dart';
import 'package:news_app/features/moderation/domain/repository/moderation_repository.dart';
import 'package:news_app/features/moderation/domain/services/staff_gate.dart';
import 'package:news_app/features/moderation/domain/use_cases/list_suspended_articles_use_case.dart';
import 'package:news_app/shared/settings/domain/entities/app_settings_entity.dart';
import 'package:news_app/shared/settings/domain/repository/settings_repository.dart';
import 'package:news_app/shared/settings/domain/use_cases/load_settings_use_case.dart';
import 'package:news_app/shared/settings/domain/use_cases/save_settings_use_case.dart';

// Policy: bloc tests mock the REPOSITORY and use the real use case whenever
// the use case does real work (tokenization, validation) that a test wants
// to keep proving. Use cases are mocked directly only where the bloc's
// dependency does non-trivial orchestration we don't want to re-exercise on
// every bloc test: ArticleEditorBloc, SettingsCubit, ReviewQueueCubit,
// StaffCubit.

// Repositories
class MockAuthoredArticleRepository extends Mock implements AuthoredArticleRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockArticleRepository extends Mock implements ArticleRepository {}

class MockModerationRepository extends Mock implements ModerationRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

// Data sources
class MockAuthoredArticleFirestoreDataSource extends Mock
    implements AuthoredArticleFirestoreDataSource {}

class MockAuthoredArticleStorageDataSource extends Mock
    implements AuthoredArticleStorageDataSource {}

class MockFirebaseAuthDataSource extends Mock implements FirebaseAuthDataSource {}

class MockModerationFirestoreDataSource extends Mock implements ModerationFirestoreDataSource {}

class MockAppDatabase extends Mock implements AppDatabase {}

class MockArticleDao extends Mock implements ArticleDao {}

// Firebase surfaces
// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockFirebaseUser extends Mock implements fb_auth.User {}

// Services / use cases mocked directly
class MockStaffGate extends Mock implements StaffGate {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockSaveDraftUseCase extends Mock implements SaveDraftUseCase {}

class MockPublishArticleUseCase extends Mock implements PublishArticleUseCase {}

class MockEditArticleUseCase extends Mock implements EditArticleUseCase {}

class MockUploadThumbnailUseCase extends Mock implements UploadThumbnailUseCase {}

class MockDeleteArticleUseCase extends Mock implements DeleteArticleUseCase {}

class MockListSuspendedArticlesUseCase extends Mock implements ListSuspendedArticlesUseCase {}

class MockLoadSettingsUseCase extends Mock implements LoadSettingsUseCase {}

class MockSaveSettingsUseCase extends Mock implements SaveSettingsUseCase {}

/// Registers a fallback value for every non-nullable custom type that ever
/// reaches an `any()`/`any(named: ...)` matcher in the suite. Call once from
/// each test file's `setUpAll`.
void registerCommonFallbacks() {
  registerFallbackValue(AuthoredArticleEntity(
    id: 'fallback',
    authorId: 'fallback',
    authorName: 'fallback',
    title: 'fallback',
    body: 'fallback',
    status: ArticleStatus.published,
    category: ArticleCategory.general,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  ));
  registerFallbackValue(const ArticleEntity());
  registerFallbackValue(const daily_news_model.ArticleModel());
  registerFallbackValue(const UploadThumbnailParams(articleId: 'fallback', filePath: 'fallback'));
  registerFallbackValue(const ReportArticleParams(articleId: 'fallback', reason: ReportReason.other));
  registerFallbackValue(const DecideParams(articleId: 'fallback', decision: ModerationDecision.approve));
  registerFallbackValue(const AppSettingsEntity(
    themeMode: ThemeMode.system,
    locale: Locale('es'),
    accent: AppAccent.lime,
    accessible: false,
  ));
  registerFallbackValue(const NoParams());
  registerFallbackValue(const SignInParams(email: 'fallback@example.com', password: 'fallback'));
  registerFallbackValue(const SignUpParams(email: 'fallback@example.com', password: 'fallback', displayName: 'fallback'));
  registerFallbackValue(ArticleCategory.general);
  registerFallbackValue(ArticleStatus.published);
  registerFallbackValue(ThemeMode.system);
  registerFallbackValue(const Locale('es'));
  registerFallbackValue(AppAccent.lime);
  registerFallbackValue((double _) {});
}
