import 'package:equatable/equatable.dart';
import 'package:news_app/features/moderation/domain/entities/report_reason.dart';

class ReportArticleParams extends Equatable {
  final String articleId;
  final ReportReason reason;
  final String? note;

  const ReportArticleParams({required this.articleId, required this.reason, this.note});

  @override
  List<Object?> get props => [articleId, reason, note];
}
