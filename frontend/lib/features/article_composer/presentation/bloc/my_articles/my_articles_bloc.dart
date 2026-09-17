import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/resources/data_state.dart';

import '../../../domain/params/list_my_articles_params.dart';
import '../../../domain/use_cases/delete_article_use_case.dart';
import '../../../domain/use_cases/list_my_articles_use_case.dart';
import 'my_articles_event.dart';
import 'my_articles_state.dart';

class MyArticlesBloc extends Bloc<MyArticlesEvent, MyArticlesState> {
  MyArticlesBloc(this._listMyArticlesUseCase, this._deleteArticleUseCase)
      : super(const MyArticlesState()) {
    on<MyArticlesRequested>((event, emit) => _fetch(event.authorId, emit));
    on<MyArticlesRefreshed>(
        (event, emit) => _fetch(event.authorId, emit, isRefresh: true));
    on<MyArticlesTabChanged>(onTabChanged);
    on<MyArticlesMoreRequested>(onMoreRequested);
    on<MyArticleDeleted>(onDeleted);
  }

  final ListMyArticlesUseCase _listMyArticlesUseCase;
  final DeleteArticleUseCase _deleteArticleUseCase;

  String? _authorId;

  Future<void> _fetch(String authorId, Emitter<MyArticlesState> emit,
      {bool isRefresh = false}) async {
    _authorId = authorId;
    emit(state.copyWith(status: MyArticlesStatus.loading));
    if (isRefresh) {
      // Deliberate delay so the skeleton loader is visible on pull-to-refresh.
      await Future.delayed(const Duration(seconds: 1));
      if (isClosed) return;
    }
    final result =
        await _listMyArticlesUseCase(ListMyArticlesParams(authorId: authorId));
    if (isClosed) return;
    if (result is DataSuccess && result.data != null) {
      emit(state.copyWith(
        status: MyArticlesStatus.success,
        articles: result.data!.items,
        nextCursor: result.data!.nextCursor,
        clearCursor: result.data!.nextCursor == null,
      ));
    } else if (result is DataFailed) {
      emit(state.copyWith(
          status: MyArticlesStatus.failure, error: result.error));
    }
  }

  Future<void> onTabChanged(
      MyArticlesTabChanged event, Emitter<MyArticlesState> emit) async {
    emit(state.copyWith(tab: event.tab));
  }

  Future<void> onMoreRequested(
      MyArticlesMoreRequested event, Emitter<MyArticlesState> emit) async {
    final authorId = _authorId;
    if (authorId == null || state.isLoadingMore || !state.hasMore) return;
    final cursor = state.nextCursor;
    emit(state.copyWith(isLoadingMore: true));
    final result = await _listMyArticlesUseCase(
        ListMyArticlesParams(authorId: authorId, cursor: cursor));
    if (isClosed) return;
    if (result is DataSuccess && result.data != null) {
      emit(state.copyWith(
        articles: [...state.articles, ...result.data!.items],
        nextCursor: result.data!.nextCursor,
        clearCursor: result.data!.nextCursor == null,
        isLoadingMore: false,
      ));
    } else {
      // Don't strand the "Cargar más" spinner on a failed page — keep the
      // articles already shown and let the user retry.
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> onDeleted(
      MyArticleDeleted event, Emitter<MyArticlesState> emit) async {
    await _deleteArticleUseCase(event.articleId);
    if (isClosed) return;
    final authorId = _authorId;
    if (authorId == null) return;
    final result =
        await _listMyArticlesUseCase(ListMyArticlesParams(authorId: authorId));
    if (isClosed) return;
    if (result is DataSuccess && result.data != null) {
      emit(state.copyWith(
        status: MyArticlesStatus.success,
        articles: result.data!.items,
        nextCursor: result.data!.nextCursor,
        clearCursor: result.data!.nextCursor == null,
      ));
    }
  }
}
