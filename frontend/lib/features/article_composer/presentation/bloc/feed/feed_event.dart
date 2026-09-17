import 'package:equatable/equatable.dart';

import '../../../domain/entities/article_category.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class FeedRequested extends FeedEvent {
  const FeedRequested();
}

class FeedRefreshed extends FeedEvent {
  const FeedRefreshed();
}

/// `null` category means "Todas".
class FeedCategorySelected extends FeedEvent {
  const FeedCategorySelected(this.category);

  final ArticleCategory? category;

  @override
  List<Object?> get props => [category];
}

class FeedQueryChanged extends FeedEvent {
  const FeedQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class FeedMoreRequested extends FeedEvent {
  const FeedMoreRequested();
}
