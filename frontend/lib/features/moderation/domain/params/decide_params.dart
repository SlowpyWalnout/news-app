import 'package:equatable/equatable.dart';

enum ModerationDecision { approve, remove }

class DecideParams extends Equatable {
  final String articleId;
  final ModerationDecision decision;

  const DecideParams({required this.articleId, required this.decision});

  @override
  List<Object?> get props => [articleId, decision];
}
