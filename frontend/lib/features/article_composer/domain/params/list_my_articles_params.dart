import 'package:equatable/equatable.dart';

class ListMyArticlesParams extends Equatable {
  final String authorId;
  final String? cursor;

  const ListMyArticlesParams({required this.authorId, this.cursor});

  @override
  List<Object?> get props => [authorId, cursor];
}
