import 'package:get_it/get_it.dart';
import 'package:floor/floor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:news_app/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app/features/daily_news/domain/use_cases/get_article.dart';
import 'package:news_app/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/use_cases/get_read_later_articles_use_case.dart';
import 'features/daily_news/domain/use_cases/mark_read_later_article_as_read_use_case.dart';
import 'features/daily_news/domain/use_cases/remove_from_read_later_use_case.dart';
import 'features/daily_news/domain/use_cases/add_to_read_later_use_case.dart';
import 'features/daily_news/presentation/bloc/article/local/read_later_bloc.dart';

import 'features/auth/data/data_sources/remote/firebase_auth_data_source.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/use_cases/get_current_user_use_case.dart';
import 'features/auth/domain/use_cases/sign_in_use_case.dart';
import 'features/auth/domain/use_cases/sign_in_with_google_use_case.dart';
import 'features/auth/domain/use_cases/sign_out_use_case.dart';
import 'features/auth/domain/use_cases/sign_up_use_case.dart';
import 'features/auth/presentation/bloc/auth/auth_bloc.dart';

import 'features/article_composer/data/data_sources/remote/authored_article_firestore_data_source.dart';
import 'features/article_composer/data/data_sources/remote/authored_article_storage_data_source.dart';
import 'features/article_composer/data/repository/authored_article_repository_impl.dart';
import 'features/article_composer/domain/repository/authored_article_repository.dart';
import 'features/article_composer/domain/use_cases/delete_article_use_case.dart';
import 'features/article_composer/domain/use_cases/get_article_by_id_use_case.dart';
import 'features/article_composer/domain/use_cases/edit_article_use_case.dart';
import 'features/article_composer/domain/use_cases/get_feed_use_case.dart';
import 'features/article_composer/domain/use_cases/list_my_articles_use_case.dart';
import 'features/article_composer/domain/use_cases/publish_article_use_case.dart';
import 'features/article_composer/domain/use_cases/save_draft_use_case.dart';
import 'features/article_composer/domain/use_cases/upload_thumbnail_use_case.dart';
import 'features/article_composer/presentation/bloc/article_actions/article_actions_cubit.dart';
import 'features/article_composer/presentation/bloc/article_editor/article_editor_bloc.dart';
import 'features/article_composer/presentation/bloc/feed/feed_bloc.dart';
import 'features/article_composer/presentation/bloc/my_articles/my_articles_bloc.dart';

import 'features/moderation/data/data_sources/remote/moderation_firestore_data_source.dart';
import 'features/moderation/data/repository/moderation_repository_impl.dart';
import 'features/moderation/domain/repository/moderation_repository.dart';
import 'features/moderation/domain/use_cases/decide_on_article_use_case.dart';
import 'features/moderation/domain/use_cases/list_suspended_articles_use_case.dart';
import 'features/moderation/domain/use_cases/report_article_use_case.dart';
import 'features/moderation/presentation/bloc/moderation_cubit.dart';
import 'features/moderation/presentation/bloc/review_queue_cubit.dart';
import 'features/moderation/presentation/staff_gate.dart';

import 'shared/settings/data/repository/settings_repository_impl.dart';
import 'shared/settings/domain/repository/settings_repository.dart';
import 'shared/settings/domain/use_cases/load_settings_use_case.dart';
import 'shared/settings/domain/use_cases/save_settings_use_case.dart';
import 'shared/settings/presentation/cubit/settings_cubit.dart';
import 'shared/presentation/connectivity_cubit.dart';
import 'shared/app_shell_controller.dart';
import 'shared/article_changes_notifier.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerLazySingleton<AppShellController>(() => AppShellController());
  sl.registerLazySingleton<ArticleChangesNotifier>(() => ArticleChangesNotifier());

  final database = await $FloorAppDatabase
      .databaseBuilder('app_database.db')
      .addMigrations([
        Migration(1, 2, (db) => db.execute('ALTER TABLE article ADD COLUMN sourceId TEXT')),
        Migration(2, 3, (db) => db.execute('ALTER TABLE article ADD COLUMN isRead INTEGER NOT NULL DEFAULT 0')),
      ])
      .build();
  sl.registerSingleton<AppDatabase>(database);

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Firebase
  sl.registerSingleton<fb_auth.FirebaseAuth>(fb_auth.FirebaseAuth.instance);
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);

  // Dependencies
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  sl.registerSingleton<ArticleRepository>(ArticleRepositoryImpl(sl(), sl()));

  // NOTE: legacy NewsAPI plumbing above (NewsApiService/ArticleRepositoryImpl)
  // is no longer wired into any screen — Fase 5 moved the feed to
  // AuthoredArticleRepository. Kept registered because ArticleRepository
  // still backs the local "Read it later" cache (GetReadLaterArticlesUseCase
  // et al.). RemoteArticlesBloc itself has no remaining consumer; see
  // ROADMAP.md.

  final googleSignIn = GoogleSignIn.instance;
  await googleSignIn.initialize();
  sl.registerSingleton<GoogleSignIn>(googleSignIn);

  sl.registerSingleton<FirebaseAuthDataSource>(FirebaseAuthDataSource(sl(), sl(), sl()));
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl(sl()));
  sl.registerSingleton<AuthoredArticleFirestoreDataSource>(
    AuthoredArticleFirestoreDataSource(sl()),
  );
  sl.registerSingleton<AuthoredArticleStorageDataSource>(
    AuthoredArticleStorageDataSource(sl(), sl()),
  );
  sl.registerSingleton<AuthoredArticleRepository>(
    AuthoredArticleRepositoryImpl(sl(), sl()),
  );
  sl.registerSingleton<ModerationFirestoreDataSource>(
    ModerationFirestoreDataSource(sl(), sl()),
  );
  sl.registerSingleton<ModerationRepository>(ModerationRepositoryImpl(sl()));
  sl.registerLazySingleton<StaffGate>(() => StaffGate(sl(), sl()));
  sl.registerSingleton<SettingsRepository>(SettingsRepositoryImpl(sl()));

  //UseCases
  sl.registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()));

  sl.registerSingleton<GetReadLaterArticlesUseCase>(GetReadLaterArticlesUseCase(sl()));

  sl.registerSingleton<AddToReadLaterUseCase>(AddToReadLaterUseCase(sl()));

  sl.registerSingleton<RemoveFromReadLaterUseCase>(RemoveFromReadLaterUseCase(sl()));

  sl.registerSingleton<MarkReadLaterArticleAsReadUseCase>(MarkReadLaterArticleAsReadUseCase(sl()));

  sl.registerSingleton<GetCurrentUserUseCase>(GetCurrentUserUseCase(sl()));
  sl.registerSingleton<SignInUseCase>(SignInUseCase(sl()));
  sl.registerSingleton<SignInWithGoogleUseCase>(SignInWithGoogleUseCase(sl()));
  sl.registerSingleton<SignUpUseCase>(SignUpUseCase(sl()));
  sl.registerSingleton<SignOutUseCase>(SignOutUseCase(sl()));

  sl.registerSingleton<GetFeedUseCase>(GetFeedUseCase(sl()));
  sl.registerSingleton<ListMyArticlesUseCase>(ListMyArticlesUseCase(sl()));
  sl.registerSingleton<PublishArticleUseCase>(PublishArticleUseCase(sl()));
  sl.registerSingleton<SaveDraftUseCase>(SaveDraftUseCase(sl()));
  sl.registerSingleton<EditArticleUseCase>(EditArticleUseCase(sl()));
  sl.registerSingleton<DeleteArticleUseCase>(DeleteArticleUseCase(sl()));
  sl.registerSingleton<UploadThumbnailUseCase>(UploadThumbnailUseCase(sl()));
  sl.registerSingleton<GetArticleByIdUseCase>(GetArticleByIdUseCase(sl()));

  sl.registerSingleton<ReportArticleUseCase>(ReportArticleUseCase(sl()));
  sl.registerSingleton<DecideOnArticleUseCase>(DecideOnArticleUseCase(sl()));
  sl.registerSingleton<ListSuspendedArticlesUseCase>(ListSuspendedArticlesUseCase(sl()));

  sl.registerSingleton<LoadSettingsUseCase>(LoadSettingsUseCase(sl()));
  sl.registerSingleton<SaveSettingsUseCase>(SaveSettingsUseCase(sl()));

  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl()));

  sl.registerFactory<ReadLaterBloc>(() => ReadLaterBloc(sl(), sl(), sl(), sl()));

  sl.registerFactory<AuthBloc>(() => AuthBloc(sl(), sl(), sl(), sl(), sl()));

  sl.registerFactory<FeedBloc>(() => FeedBloc(sl()));

  sl.registerFactory<MyArticlesBloc>(() => MyArticlesBloc(sl(), sl()));

  sl.registerFactory<ArticleEditorBloc>(() => ArticleEditorBloc(sl(), sl(), sl(), sl()));

  sl.registerFactory<ArticleActionsCubit>(() => ArticleActionsCubit(sl()));

  sl.registerFactory<ModerationCubit>(() => ModerationCubit(sl(), sl(), sl()));
  sl.registerFactory<ReviewQueueCubit>(() => ReviewQueueCubit(sl()));

  sl.registerLazySingleton<SettingsCubit>(() => SettingsCubit(sl(), sl()));

  sl.registerSingleton<Connectivity>(Connectivity());
  sl.registerLazySingleton<ConnectivityCubit>(() => ConnectivityCubit(sl()));
}
