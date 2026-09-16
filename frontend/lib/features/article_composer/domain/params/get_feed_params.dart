import 'package:equatable/equatable.dart';
import 'package:news_app/features/article_composer/domain/entities/article_category.dart';

class GetFeedParams extends Equatable {
  final String? cursor;
  final ArticleCategory? category;

  const GetFeedParams({this.cursor, this.category});

  @override
  List<Object?> get props => [cursor, category];
}
