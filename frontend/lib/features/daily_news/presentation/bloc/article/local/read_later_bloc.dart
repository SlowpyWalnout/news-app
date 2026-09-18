import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/article_composer/domain/use_cases/get_article_by_id_use_case.dart';
import 'package:news_app/features/daily_news/presentation/bloc/article/local/read_later_event.dart';
import 'package:news_app/features/daily_news/presentation/bloc/article/local/read_later_state.dart';

import '../../../../domain/entities/article.dart';
import '../../../../domain/use_cases/add_to_read_later_use_case.dart';
import '../../../../domain/use_cases/get_read_later_articles_use_case.dart';
import '../../../../domain/use_cases/mark_read_later_article_as_read_use_case.dart';
import '../../../../domain/use_cases/remove_from_read_later_use_case.dart';

class ReadLaterBloc extends Bloc<ReadLaterEvent, ReadLaterState> {
  final GetReadLaterArticlesUseCase _getReadLaterArticlesUseCase;
  final AddToReadLaterUseCase _addToReadLaterUseCase;
  final RemoveFromReadLaterUseCase _removeFromReadLaterUseCase;
  final MarkReadLaterArticleAsReadUseCase _markReadLaterArticleAsReadUseCase;
  final GetArticleByIdUseCase _getArticleByIdUseCase;

  ReadLaterBloc(
    this._getReadLaterArticlesUseCase,
    this._addToReadLaterUseCase,
    this._removeFromReadLaterUseCase,
    this._markReadLaterArticleAsReadUseCase,
    this._getArticleByIdUseCase,
  ) : super(const ReadLaterLoading()) {
    on<ReadLaterRequested>(onRequested);
    on<ReadLaterRefreshed>(onRefreshed);
    on<ReadLaterRemoved>(onRemoved);
    on<ReadLaterAdded>(onAdded);
    on<ReadLaterMarkedRead>(onMarkedRead);
  }

  Future<void> onRequested(ReadLaterRequested event, Emitter<ReadLaterState> emit) async {
    await _refresh(emit);
  }

  Future<void> onRefreshed(ReadLaterRefreshed event, Emitter<ReadLaterState> emit) async {
    emit(const ReadLaterLoading());
    // Deliberate delay so the skeleton loader is visible on pull-to-refresh,
    // same pattern as FeedBloc/MyArticlesBloc.
    await Future.delayed(const Duration(seconds: 1));
    if (isClosed) return;
    await _refresh(emit);
  }

  Future<void> onRemoved(ReadLaterRemoved event, Emitter<ReadLaterState> emit) async {
    try {
      await _removeFromReadLaterUseCase(event.article!);
    } catch (e) {
      if (isClosed) return;
      emit(ReadLaterError(StorageFailure(e.toString())));
      return;
    }
    if (isClosed) return;
    await _refresh(emit);
  }

  Future<void> onAdded(ReadLaterAdded event, Emitter<ReadLaterState> emit) async {
    try {
      await _addToReadLaterUseCase(event.article!);
    } catch (e) {
      if (isClosed) return;
      emit(ReadLaterError(StorageFailure(e.toString())));
      return;
    }
    if (isClosed) return;
    await _refresh(emit);
  }

  Future<void> onMarkedRead(ReadLaterMarkedRead event, Emitter<ReadLaterState> emit) async {
    try {
      await _markReadLaterArticleAsReadUseCase(event.id);
    } catch (e) {
      if (isClosed) return;
      emit(ReadLaterError(StorageFailure(e.toString())));
      return;
    }
    if (isClosed) return;
    await _refresh(emit);
  }

  Future<void> _refresh(Emitter<ReadLaterState> emit) async {
    try {
      final articles = await _getReadLaterArticlesUseCase(const NoParams());
      if (isClosed) return;
      emit(ReadLaterLoaded(_sortUnreadFirst(articles)));
    } catch (e) {
      if (isClosed) return;
      emit(ReadLaterError(StorageFailure(e.toString())));
    }
  }

  // Tries the fresh Firestore doc first (so the reader sees current
  // category/author and, if it's their own article, Edit/Delete); falls
  // back to the cached row — read-only — if there's no network or the
  // article was since deleted. The only place allowed to call
  // GetArticleByIdUseCase for this screen (rule 3.2.2).
  Future<(AuthoredArticleEntity resolved, bool openedFromCache)> resolveArticleToOpen(ArticleEntity cached) async {
    AuthoredArticleEntity resolved = AuthoredArticleEntity.fromCachedArticle(cached);
    var openedFromCache = true;

    final sourceId = cached.sourceId;
    if (sourceId != null && sourceId.isNotEmpty) {
      final result = await _getArticleByIdUseCase.call(sourceId);
      if (result is DataSuccess<AuthoredArticleEntity?> && result.data != null) {
        resolved = result.data!;
        openedFromCache = false;
      }
    }

    final id = cached.id;
    if (id != null && !cached.isRead && !isClosed) {
      add(ReadLaterMarkedRead(id));
    }

    return (resolved, openedFromCache);
  }

  // Unread rows first, read rows at the bottom; each group keeps the order
  // getArticles() returned it in (List.sort isn't stable, so partition by
  // hand instead of sorting by isRead).
  List<ArticleEntity> _sortUnreadFirst(List<ArticleEntity> articles) {
    final unread = articles.where((a) => !a.isRead).toList();
    final read = articles.where((a) => a.isRead).toList();
    return [...unread, ...read];
  }
}
