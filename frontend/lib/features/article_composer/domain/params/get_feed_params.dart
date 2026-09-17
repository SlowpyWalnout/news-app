import 'package:equatable/equatable.dart';
import 'package:news_app/features/article_composer/domain/entities/article_category.dart';

class GetFeedParams extends Equatable {
  final String? cursor;
  final ArticleCategory? category;

  /// The raw text the user typed — tokenized into a single array-contains
  /// token by [GetFeedUseCase], never passed to Firestore as-is.
  final String? query;

  const GetFeedParams({this.cursor, this.category, this.query});

  @override
  List<Object?> get props => [cursor, category, query];
}
