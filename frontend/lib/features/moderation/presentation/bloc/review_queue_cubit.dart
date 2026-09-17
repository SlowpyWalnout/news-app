import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/paginated_result.dart';
import 'package:news_app/features/article_composer/domain/entities/authored_article_entity.dart';
import 'package:news_app/features/moderation/domain/use_cases/list_suspended_articles_use_case.dart';

enum ReviewQueueStatus { initial, loading, success, failure }

class ReviewQueueState extends Equatable {
  final ReviewQueueStatus status;
  final List<AuthoredArticleEntity> articles;
  final String? nextCursor;
  final bool isLoadingMore;
  final String? error;

  const ReviewQueueState({
    this.status = ReviewQueueStatus.initial,
    this.articles = const [],
    this.nextCursor,
    this.isLoadingMore = false,
    this.error,
  });

  bool get hasMore => nextCursor != null;

  ReviewQueueState copyWith({
    ReviewQueueStatus? status,
    List<AuthoredArticleEntity>? articles,
    String? nextCursor,
    bool clearNextCursor = false,
    bool? isLoadingMore,
    String? error,
  }) {
    return ReviewQueueState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, articles, nextCursor, isLoadingMore, error];
}

// Cola de revisión de staff: mismo patrón de paginación por cursor que
// FeedBloc/MyArticlesBloc, pero sin eventos — es una pantalla de baja
// frecuencia (solo staff, solo artículos suspendidos) que no justifica el
// trío event/state completo.
class ReviewQueueCubit extends Cubit<ReviewQueueState> {
  ReviewQueueCubit(this._listSuspendedArticlesUseCase) : super(const ReviewQueueState());

  final ListSuspendedArticlesUseCase _listSuspendedArticlesUseCase;

  Future<void> load() async {
    emit(state.copyWith(status: ReviewQueueStatus.loading));
    final DataState<PaginatedResult<AuthoredArticleEntity>> result = await _listSuspendedArticlesUseCase(null);
    if (isClosed) return;
    if (result is DataSuccess<PaginatedResult<AuthoredArticleEntity>>) {
      final page = result.data!;
      emit(state.copyWith(
        status: ReviewQueueStatus.success,
        articles: page.items,
        nextCursor: page.nextCursor,
        clearNextCursor: page.nextCursor == null,
      ));
    } else {
      emit(state.copyWith(status: ReviewQueueStatus.failure, error: result.error?.message));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true));
    final DataState<PaginatedResult<AuthoredArticleEntity>> result = await _listSuspendedArticlesUseCase(state.nextCursor);
    if (isClosed) return;
    if (result is DataSuccess<PaginatedResult<AuthoredArticleEntity>>) {
      final page = result.data!;
      emit(state.copyWith(
        articles: [...state.articles, ...page.items],
        nextCursor: page.nextCursor,
        clearNextCursor: page.nextCursor == null,
        isLoadingMore: false,
      ));
    } else {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  // Tras aprobar/retirar desde el Detalle, quita el artículo de la lista sin
  // volver a pedir la página completa.
  void removeLocally(String articleId) {
    emit(state.copyWith(articles: state.articles.where((a) => a.id != articleId).toList()));
  }
}
