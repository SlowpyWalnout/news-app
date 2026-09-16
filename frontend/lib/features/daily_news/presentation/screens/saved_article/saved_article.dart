import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/app_palette.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../bloc/article/local/local_article_state.dart';
import '../../widgets/article_tile.dart';

class SavedArticles extends StatelessWidget {
  const SavedArticles({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>()..add(const GetSavedArticles()),
      child: const _SavedArticlesView(),
    );
  }
}

class _SavedArticlesView extends StatelessWidget {
  const _SavedArticlesView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: Text(l10n.savedArticlesTitle),
      ),
      body: BlocBuilder<LocalArticleBloc, LocalArticlesState>(
        builder: (context, state) {
          if (state is LocalArticlesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LocalArticlesError) {
            return Center(child: Text(state.error?.message ?? ''));
          }
          final articles = state.articles ?? const <ArticleEntity>[];
          if (articles.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.savedArticlesEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.palette.ink2),
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return ArticleWidget(
                article: article,
                isRemovable: true,
                onRemove: (a) => context.read<LocalArticleBloc>().add(RemoveArticle(a)),
              );
            },
          );
        },
      ),
    );
  }
}
