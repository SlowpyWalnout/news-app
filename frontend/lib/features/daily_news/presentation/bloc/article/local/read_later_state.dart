import 'package:equatable/equatable.dart';
import 'package:news_app/core/resources/failure.dart';

import '../../../../domain/entities/article.dart';

abstract class ReadLaterState extends Equatable {
  final List<ArticleEntity>? articles;
  final Failure? error;

  const ReadLaterState({this.articles, this.error});

  @override
  List<Object?> get props => [articles, error];
}

class ReadLaterLoading extends ReadLaterState {
  const ReadLaterLoading();
}

class ReadLaterLoaded extends ReadLaterState {
  const ReadLaterLoaded(List<ArticleEntity> articles) : super(articles: articles);
}

class ReadLaterError extends ReadLaterState {
  const ReadLaterError(Failure error) : super(error: error);
}
