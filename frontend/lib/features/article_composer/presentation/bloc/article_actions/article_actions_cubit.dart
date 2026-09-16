import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/resources/data_state.dart';

import '../../../domain/use_cases/delete_article_use_case.dart';

/// Small stateless-ish cubit so the detail screen's delete action goes
/// through a bloc (the only layer allowed to call use cases) without
/// forcing it to share `MyArticlesBloc`'s list-oriented state.
class ArticleActionsCubit extends Cubit<void> {
  ArticleActionsCubit(this._deleteArticleUseCase) : super(null);

  final DeleteArticleUseCase _deleteArticleUseCase;

  Future<bool> delete(String articleId) async {
    final result = await _deleteArticleUseCase(articleId);
    return result is DataSuccess;
  }
}
