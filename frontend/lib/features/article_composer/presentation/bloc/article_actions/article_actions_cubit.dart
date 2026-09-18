import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/resources/data_state.dart';

import '../../../../daily_news/domain/entities/article.dart';
import '../../../domain/entities/authored_article_entity.dart';
import '../../../domain/use_cases/delete_article_use_case.dart';

/// Small stateless-ish cubit so the detail screen's delete action goes
/// through a bloc (the only layer allowed to call use cases) without
/// forcing it to share `MyArticlesBloc`'s list-oriented state. Also carries
/// the detail screen's read-model rules (ownership, Read it later match) so
/// the widget stays presentation-only.
class ArticleActionsCubit extends Cubit<void> {
  ArticleActionsCubit(this._deleteArticleUseCase) : super(null);

  final DeleteArticleUseCase _deleteArticleUseCase;

  Future<bool> delete(String articleId) async {
    final result = await _deleteArticleUseCase(articleId);
    return result is DataSuccess;
  }

  bool isMine(AuthoredArticleEntity article, {required String? currentUserId, required bool forcePermissionDenied}) {
    return !forcePermissionDenied && currentUserId != null && currentUserId == article.authorId;
  }

  // Matches an article against a stored Read it later row so removal always
  // uses the row's real Floor `id`, never a freshly built ArticleEntity with
  // a null one (that used to crash the DELETE query — Floor drops null
  // primary-key args, leaving a bind-count mismatch). Falls back to a title
  // match for rows saved before `sourceId` existed.
  ArticleEntity? findStoredMatch(AuthoredArticleEntity article, List<ArticleEntity> stored) {
    for (final row in stored) {
      if (row.sourceId == article.id) return row;
    }
    for (final row in stored) {
      if (row.sourceId == null && row.title == article.title) return row;
    }
    return null;
  }
}
