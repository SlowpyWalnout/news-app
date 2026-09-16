import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:news_app/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app/features/daily_news/domain/use_cases/get_article.dart';
import 'package:news_app/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/use_cases/get_saved_article.dart';
import 'features/daily_news/domain/use_cases/remove_article.dart';
import 'features/daily_news/domain/use_cases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';

import 'features/auth/data/data_sources/remote/firebase_auth_data_source.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/use_cases/get_current_user_use_case.dart';
import 'features/auth/domain/use_cases/sign_in_use_case.dart';
import 'features/auth/domain/use_cases/sign_out_use_case.dart';
import 'features/auth/domain/use_cases/sign_up_use_case.dart';
import 'features/auth/presentation/bloc/auth/auth_bloc.dart';

import 'features/article_composer/data/data_sources/remote/authored_article_firestore_data_source.dart';
import 'features/article_composer/data/repository/authored_article_repository_impl.dart';
import 'features/article_composer/domain/repository/authored_article_repository.dart';
import 'features/article_composer/domain/use_cases/delete_article_use_case.dart';
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

import 'shared/settings/data/repository/settings_repository_impl.dart';
import 'shared/settings/domain/repository/settings_repository.dart';
import 'shared/settings/domain/use_cases/load_settings_use_case.dart';
import 'shared/settings/domain/use_cases/save_settings_use_case.dart';
import 'shared/settings/presentation/cubit/settings_cubit.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Firebase
  sl.registerSingleton<fb_auth.FirebaseAuth>(fb_auth.FirebaseAuth.instance);
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  // Dependencies
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  sl.registerSingleton<ArticleRepository>(ArticleRepositoryImpl(sl(), sl()));

  // NOTE: legacy NewsAPI plumbing above (NewsApiService/ArticleRepositoryImpl)
  // is no longer wired into any screen — Fase 5 moved the feed to
  // AuthoredArticleRepository. Kept registered because ArticleRepository
  // still backs the local favorites cache (GetSavedArticleUseCase et al.).
  // RemoteArticlesBloc itself has no remaining consumer; see ROADMAP.md.

  sl.registerSingleton<FirebaseAuthDataSource>(FirebaseAuthDataSource(sl(), sl()));
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl(sl()));
  sl.registerSingleton<AuthoredArticleFirestoreDataSource>(
    AuthoredArticleFirestoreDataSource(sl()),
  );
  sl.registerSingleton<AuthoredArticleRepository>(AuthoredArticleRepositoryImpl(sl()));
  sl.registerSingleton<SettingsRepository>(SettingsRepositoryImpl(sl()));

  //UseCases
  sl.registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()));

  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));

  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));

  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));

  sl.registerSingleton<GetCurrentUserUseCase>(GetCurrentUserUseCase(sl()));
  sl.registerSingleton<SignInUseCase>(SignInUseCase(sl()));
  sl.registerSingleton<SignUpUseCase>(SignUpUseCase(sl()));
  sl.registerSingleton<SignOutUseCase>(SignOutUseCase(sl()));

  sl.registerSingleton<GetFeedUseCase>(GetFeedUseCase(sl()));
  sl.registerSingleton<ListMyArticlesUseCase>(ListMyArticlesUseCase(sl()));
  sl.registerSingleton<PublishArticleUseCase>(PublishArticleUseCase(sl()));
  sl.registerSingleton<SaveDraftUseCase>(SaveDraftUseCase(sl()));
  sl.registerSingleton<EditArticleUseCase>(EditArticleUseCase(sl()));
  sl.registerSingleton<DeleteArticleUseCase>(DeleteArticleUseCase(sl()));
  sl.registerSingleton<UploadThumbnailUseCase>(UploadThumbnailUseCase(sl()));

  sl.registerSingleton<LoadSettingsUseCase>(LoadSettingsUseCase(sl()));
  sl.registerSingleton<SaveSettingsUseCase>(SaveSettingsUseCase(sl()));

  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl()));

  sl.registerFactory<LocalArticleBloc>(() => LocalArticleBloc(sl(), sl(), sl()));

  sl.registerFactory<AuthBloc>(() => AuthBloc(sl(), sl(), sl(), sl()));

  sl.registerFactory<FeedBloc>(() => FeedBloc(sl()));

  sl.registerFactory<MyArticlesBloc>(() => MyArticlesBloc(sl(), sl()));

  sl.registerFactory<ArticleEditorBloc>(() => ArticleEditorBloc(sl(), sl(), sl(), sl()));

  sl.registerFactory<ArticleActionsCubit>(() => ArticleActionsCubit(sl()));

  sl.registerLazySingleton<SettingsCubit>(() => SettingsCubit(sl(), sl()));
}
