import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/app_dimensions.dart';
import '../../../../../config/theme/app_palette.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/widgets/app_toast.dart';
import '../../../../../shared/widgets/confirm_delete_sheet.dart';
import '../../../../../shared/widgets/load_more_footer.dart';
import '../../../../../shared/widgets/skeleton_list.dart';
import '../../../../../shared/widgets/staggered_fade_in.dart';
import '../../../../../shared/widgets/state_cards.dart';
import '../../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../bloc/my_articles/my_articles_bloc.dart';
import '../../bloc/my_articles/my_articles_event.dart';
import '../../bloc/my_articles/my_articles_state.dart';
import '../../widgets/my_article_card.dart';
import '../article_detail/article_detail_screen.dart';
import '../article_editor/article_editor_screen.dart';

const _kListPadding = EdgeInsets.fromLTRB(20, 16, 20, 120);

/// The scrollable body of "Mis artículos": one sliver per `MyArticlesState`
/// branch (loading/failure/empty/list), plus the per-card expand-menu state.
class MyArticlesBody extends StatefulWidget {
  const MyArticlesBody({super.key});

  @override
  State<MyArticlesBody> createState() => _MyArticlesBodyState();
}

class _MyArticlesBodyState extends State<MyArticlesBody> {
  String? _openMenuId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final dims = Theme.of(context).extension<AppDimensions>()!;

    return BlocBuilder<MyArticlesBloc, MyArticlesState>(
      builder: (context, state) {
        if (state.status == MyArticlesStatus.loading) {
          return SliverPadding(
            padding: _kListPadding,
            sliver: SliverList.list(
              children: const [SkeletonList(heights: [110, 110, 110], gap: 13)],
            ),
          );
        }
        if (state.status == MyArticlesStatus.failure) {
          return SliverPadding(
            padding: _kListPadding,
            sliver: SliverList.list(children: [
              ErrorStateCard(
                title: l10n.myArticlesNetErrorTitle,
                body: l10n.myArticlesNetErrorBody,
                retryLabel: l10n.retry,
                onRetryPressed: () {
                  final authorId = context.read<AuthBloc>().state.user?.uid ?? '';
                  context.read<MyArticlesBloc>().add(MyArticlesRequested(authorId));
                },
              ),
            ]),
          );
        }
        if (state.isEmpty) {
          final isDrafts = state.tab == MyArticlesTab.drafts;
          return SliverPadding(
            padding: _kListPadding,
            sliver: SliverList.list(children: [
              EmptyStateCard(
                title: isDrafts ? l10n.myArticlesEmptyDraftTitle : l10n.myArticlesEmptyTitle,
                body: isDrafts ? l10n.myArticlesEmptyDraftBody : l10n.myArticlesEmptyBody,
                ctaLabel: l10n.writeFirstArticle,
                onCtaPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ArticleEditorScreen()),
                ),
              ),
            ]),
          );
        }

        final visible = state.visibleArticles;
        return SliverPadding(
          padding: _kListPadding,
          sliver: SliverList.separated(
            itemCount: visible.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 13),
            itemBuilder: (context, index) {
              if (index == visible.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l10n.tabAll} · ${visible.length}',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: dims.fSm, color: palette.ink3),
                      ),
                      LoadMoreFooter(
                        hasMore: state.hasMore,
                        isLoadingMore: state.isLoadingMore,
                        label: l10n.loadMore,
                        onPressed: () => context.read<MyArticlesBloc>().add(const MyArticlesMoreRequested()),
                      ),
                    ],
                  ),
                );
              }
              final article = visible[index];
              return StaggeredFadeIn(
                key: ValueKey('${state.tab}_${article.id}'),
                index: index,
                child: MyArticleCard(
                  article: article,
                  menuOpen: _openMenuId == article.id,
                  onToggleMenu: () => setState(() => _openMenuId = _openMenuId == article.id ? null : article.id),
                  onEdit: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ArticleEditorScreen(article: article)),
                  ),
                  onDelete: () async {
                    final confirmed = await showConfirmDeleteSheet(context, articleTitle: article.title);
                    if (confirmed != true || !context.mounted) return;
                    context.read<MyArticlesBloc>().add(MyArticleDeleted(article.id));
                    showAppToast(context, l10n.articleDeletedToast);
                  },
                  onOpen: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
