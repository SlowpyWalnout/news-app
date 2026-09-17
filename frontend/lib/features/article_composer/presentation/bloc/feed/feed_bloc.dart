import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/shared/utils/search_keywords.dart';

import '../../../domain/params/get_feed_params.dart';
import '../../../domain/use_cases/get_feed_use_case.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc(this._getFeedUseCase) : super(const FeedState()) {
    on<FeedRequested>(onFeedRequested);
    on<FeedRefreshed>(onFeedRequested);
    on<FeedCategorySelected>(onCategorySelected);
    on<FeedQueryChanged>(onQueryChanged);
    on<FeedMoreRequested>(onMoreRequested);
  }

  final GetFeedUseCase _getFeedUseCase;

  // Bumped on every event that should restart pagination from page 1
  // (refresh, category change, a debounced query that actually changes the
  // active token). A handler checks its own epoch after every `await` and
  // silently drops its result if a newer one has since started — this is
  // what lets FeedQueryChanged fire on every keystroke without a Timer.
  int _epoch = 0;
  String? _activeToken;

  Future<void> onFeedRequested(FeedEvent event, Emitter<FeedState> emit) async {
    final epoch = ++_epoch;
    emit(state.copyWith(status: FeedStatus.loading, clearCursor: true));
    if (event is FeedRefreshed) {
      // Deliberate delay so the skeleton loader is visible on pull-to-refresh.
      await Future.delayed(const Duration(seconds: 1));
      if (isClosed || epoch != _epoch) return;
    }
    await _fetchFirstPage(emit, epoch);
  }

  Future<void> onCategorySelected(
      FeedCategorySelected event, Emitter<FeedState> emit) async {
    final epoch = ++_epoch;
    emit(state.copyWith(
      category: event.category,
      clearCategory: event.category == null,
      status: FeedStatus.loading,
      clearCursor: true,
    ));
    await _fetchFirstPage(emit, epoch);
  }

  Future<void> onQueryChanged(
      FeedQueryChanged event, Emitter<FeedState> emit) async {
    final epoch = ++_epoch;
    // Emitted immediately (not debounced): the clear button and the empty
    // state's "no results for ..." copy both read state.query right away.
    emit(state.copyWith(query: event.query));

    await Future.delayed(const Duration(milliseconds: 350));
    if (isClosed || epoch != _epoch) return;

    final token = primarySearchToken(event.query);
    if (token == _activeToken) return; // e.g. "flutter" -> "flutter ": no-op
    _activeToken = token;

    emit(state.copyWith(status: FeedStatus.loading, clearCursor: true));
    await _fetchFirstPage(emit, epoch);
  }

  Future<void> onMoreRequested(
      FeedMoreRequested event, Emitter<FeedState> emit) async {
    if (state.isLoadingMore || !state.hasMore) return;
    final epoch = _epoch; // continuation of the current page set, not a reset
    final cursor = state.nextCursor;
    emit(state.copyWith(isLoadingMore: true));
    final result = await _getFeedUseCase(GetFeedParams(
      cursor: cursor,
      category: state.category,
      query: state.query,
    ));
    if (isClosed || epoch != _epoch) return;
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

  Future<void> _fetchFirstPage(Emitter<FeedState> emit, int epoch) async {
    final result = await _getFeedUseCase(
        GetFeedParams(category: state.category, query: state.query));
    if (isClosed || epoch != _epoch) return;
    if (result is DataSuccess && result.data != null) {
      emit(state.copyWith(
        status: FeedStatus.success,
        articles: result.data!.items,
        nextCursor: result.data!.nextCursor,
        clearCursor: result.data!.nextCursor == null,
        // Always reset: a first-page fetch supersedes any in-flight
        // FeedMoreRequested (same epoch check), which would otherwise leave
        // isLoadingMore stuck true and the "Cargar más" button disabled.
        isLoadingMore: false,
      ));
    } else if (result is DataFailed) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        error: result.error,
        isLoadingMore: false,
      ));
    }
  }
}
