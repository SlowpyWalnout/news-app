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
    on<MyArticlesRequested>(onRequested);
    on<MyArticlesTabChanged>(onTabChanged);
    on<MyArticlesMoreRequested>(onMoreRequested);
    on<MyArticleDeleted>(onDeleted);
  }

  final ListMyArticlesUseCase _listMyArticlesUseCase;
  final DeleteArticleUseCase _deleteArticleUseCase;

  String? _authorId;

  Future<void> onRequested(MyArticlesRequested event, Emitter<MyArticlesState> emit) async {
    _authorId = event.authorId;
    emit(state.copyWith(status: MyArticlesStatus.loading));
    final result = await _listMyArticlesUseCase(ListMyArticlesParams(authorId: event.authorId));
    if (result is DataSuccess && result.data != null) {
      emit(state.copyWith(
        status: MyArticlesStatus.success,
        articles: result.data!.items,
        hasMore: result.data!.hasMore,
      ));
    } else if (result is DataFailed) {
      emit(state.copyWith(status: MyArticlesStatus.failure, error: result.error));
    }
  }

  Future<void> onTabChanged(MyArticlesTabChanged event, Emitter<MyArticlesState> emit) async {
    emit(state.copyWith(tab: event.tab));
  }

  Future<void> onMoreRequested(MyArticlesMoreRequested event, Emitter<MyArticlesState> emit) async {
    final authorId = _authorId;
    if (authorId == null || !state.hasMore) return;
    final result = await _listMyArticlesUseCase(ListMyArticlesParams(authorId: authorId));
    if (result is DataSuccess && result.data != null) {
      emit(state.copyWith(articles: result.data!.items, hasMore: result.data!.hasMore));
    }
  }

  Future<void> onDeleted(MyArticleDeleted event, Emitter<MyArticlesState> emit) async {
    await _deleteArticleUseCase(event.articleId);
    final authorId = _authorId;
    if (authorId == null) return;
    final result = await _listMyArticlesUseCase(ListMyArticlesParams(authorId: authorId));
    if (result is DataSuccess && result.data != null) {
      emit(state.copyWith(status: MyArticlesStatus.success, articles: result.data!.items));
    }
  }
}
