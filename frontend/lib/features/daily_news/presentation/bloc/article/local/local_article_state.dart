import 'package:equatable/equatable.dart';
import 'package:news_app/core/resources/failure.dart';

import '../../../../domain/entities/article.dart';

abstract class LocalArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final Failure? error;

  const LocalArticlesState({this.articles, this.error});

  @override
  List<Object?> get props => [articles, error];
}

class LocalArticlesLoading extends LocalArticlesState {
  const LocalArticlesLoading();
}

class LocalArticlesDone extends LocalArticlesState {
  const LocalArticlesDone(List<ArticleEntity> articles) : super(articles: articles);
}

class LocalArticlesError extends LocalArticlesState {
  const LocalArticlesError(Failure error) : super(error: error);
}
