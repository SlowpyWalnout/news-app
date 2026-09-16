import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/core/usecase/usecase.dart';
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

  ReadLaterBloc(
    this._getReadLaterArticlesUseCase,
    this._addToReadLaterUseCase,
    this._removeFromReadLaterUseCase,
    this._markReadLaterArticleAsReadUseCase,
  ) : super(const ReadLaterLoading()) {
    on<ReadLaterRequested>(onRequested);
    on<ReadLaterRemoved>(onRemoved);
    on<ReadLaterAdded>(onAdded);
    on<ReadLaterMarkedRead>(onMarkedRead);
  }

  Future<void> onRequested(ReadLaterRequested event, Emitter<ReadLaterState> emit) async {
    await _refresh(emit);
  }

  Future<void> onRemoved(ReadLaterRemoved event, Emitter<ReadLaterState> emit) async {
    try {
      await _removeFromReadLaterUseCase(event.article!);
    } catch (e) {
      emit(ReadLaterError(StorageFailure(e.toString())));
      return;
    }
    await _refresh(emit);
  }

  Future<void> onAdded(ReadLaterAdded event, Emitter<ReadLaterState> emit) async {
    try {
      await _addToReadLaterUseCase(event.article!);
    } catch (e) {
      emit(ReadLaterError(StorageFailure(e.toString())));
      return;
    }
    await _refresh(emit);
  }

  Future<void> onMarkedRead(ReadLaterMarkedRead event, Emitter<ReadLaterState> emit) async {
    try {
      await _markReadLaterArticleAsReadUseCase(event.id);
    } catch (e) {
      emit(ReadLaterError(StorageFailure(e.toString())));
      return;
    }
    await _refresh(emit);
  }

  Future<void> _refresh(Emitter<ReadLaterState> emit) async {
    try {
      final articles = await _getReadLaterArticlesUseCase(const NoParams());
      emit(ReadLaterLoaded(_sortUnreadFirst(articles)));
    } catch (e) {
      emit(ReadLaterError(StorageFailure(e.toString())));
    }
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
