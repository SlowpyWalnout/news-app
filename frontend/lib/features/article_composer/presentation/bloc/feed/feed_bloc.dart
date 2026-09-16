import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/resources/data_state.dart';

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
  }

  final GetFeedUseCase _getFeedUseCase;

  Future<void> onFeedRequested(FeedEvent event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.loading));
    final result = await _getFeedUseCase(GetFeedParams(category: state.category));
    if (result is DataSuccess && result.data != null) {
      emit(state.copyWith(status: FeedStatus.success, articles: result.data!.items));
    } else if (result is DataFailed) {
      emit(state.copyWith(status: FeedStatus.failure, error: result.error));
    }
  }

  Future<void> onCategorySelected(FeedCategorySelected event, Emitter<FeedState> emit) async {
    emit(state.copyWith(
      category: event.category,
      clearCategory: event.category == null,
      status: FeedStatus.loading,
    ));
    final result = await _getFeedUseCase(GetFeedParams(category: event.category));
    if (result is DataSuccess && result.data != null) {
      emit(state.copyWith(status: FeedStatus.success, articles: result.data!.items));
    } else if (result is DataFailed) {
      emit(state.copyWith(status: FeedStatus.failure, error: result.error));
    }
  }

  Future<void> onQueryChanged(FeedQueryChanged event, Emitter<FeedState> emit) async {
    emit(state.copyWith(query: event.query));
  }
}
