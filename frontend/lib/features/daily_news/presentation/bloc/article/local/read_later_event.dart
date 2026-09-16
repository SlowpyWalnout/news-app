import 'package:equatable/equatable.dart';

import '../../../../domain/entities/article.dart';

abstract class ReadLaterEvent extends Equatable {
  final ArticleEntity ? article;

  const ReadLaterEvent({this.article});

  @override
  List<Object?> get props => [article];
}

class ReadLaterRequested extends ReadLaterEvent {
  const ReadLaterRequested();
}

class ReadLaterRemoved extends ReadLaterEvent {
  const ReadLaterRemoved(ArticleEntity article) : super(article: article);
}

class ReadLaterAdded extends ReadLaterEvent {
  const ReadLaterAdded(ArticleEntity article) : super(article: article);
}

// Fired when the user opens an article from the Read it later list — marks
// it read so the list can tell the user which rows are safe to unmark.
class ReadLaterMarkedRead extends ReadLaterEvent {
  const ReadLaterMarkedRead(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}
