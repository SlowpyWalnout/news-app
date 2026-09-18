import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/app_palette.dart';
import '../../../../../injection_container.dart';
import '../../../../../shared/app_shell_controller.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/utils/bloc_refresh.dart';
import '../../../../../shared/widgets/skeleton_list.dart';
import '../../../../../shared/widgets/state_cards.dart';
import '../../../../article_composer/presentation/screens/article_detail/article_detail_screen.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/read_later_bloc.dart';
import '../../bloc/article/local/read_later_event.dart';
import '../../bloc/article/local/read_later_state.dart';
import '../../widgets/article_tile.dart';

class ReadLaterScreen extends StatelessWidget {
  const ReadLaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReadLaterBloc>()..add(const ReadLaterRequested()),
      child: const _ReadLaterView(),
    );
  }
}

class _ReadLaterView extends StatefulWidget {
  const _ReadLaterView();

  @override
  State<_ReadLaterView> createState() => _ReadLaterViewState();
}

class _ReadLaterViewState extends State<_ReadLaterView> {
  bool _opening = false;

  Future<void> _openArticle(ArticleEntity cached) async {
    if (_opening) return;
    setState(() => _opening = true);

    final (resolved, openedFromCache) = await context.read<ReadLaterBloc>().resolveArticleToOpen(cached);

    if (!mounted) return;
    setState(() => _opening = false);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArticleDetailScreen(article: resolved, forcePermissionDenied: openedFromCache),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: Text(l10n.readLaterTitle),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            color: palette.accentInk,
            onRefresh: () => refreshAndSettle(
              bloc: context.read<ReadLaterBloc>(),
              event: const ReadLaterRefreshed(),
              isSettled: (s) => s is! ReadLaterLoading,
            ),
            child: BlocBuilder<ReadLaterBloc, ReadLaterState>(
              builder: (context, state) {
                if (state is ReadLaterLoading) {
                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                        sliver: SliverList.list(
                          children: [
                            SkeletonList(
                              heights: List.filled(3, MediaQuery.sizeOf(context).width / 2.2),
                              gap: 12,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                if (state is ReadLaterError) {
                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                        sliver: SliverList.list(
                          children: [
                            ErrorStateCard(
                              title: l10n.readLaterErrorTitle,
                              body: l10n.readLaterErrorBody,
                              retryLabel: l10n.retry,
                              onRetryPressed: () => context
                                  .read<ReadLaterBloc>()
                                  .add(const ReadLaterRequested()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                final articles = state.articles ?? const <ArticleEntity>[];
                if (articles.isEmpty) {
                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                        sliver: SliverList.list(
                          children: [
                            EmptyStateCard(
                              title: l10n.readLaterEmptyTitle,
                              body: l10n.readLaterEmpty,
                              ctaLabel: l10n.readLaterEmptyCta,
                              icon: Icons.bookmark_outline,
                              onCtaPressed: () {
                                Navigator.of(context).popUntil((r) => r.isFirst);
                                sl<AppShellController>().goToTab(0);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final article = articles[index];
                            return ArticleWidget(
                              article: article,
                              isRemovable: true,
                              onArticlePressed: _openArticle,
                              onRemove: (a) =>
                                  context.read<ReadLaterBloc>().add(ReadLaterRemoved(a)),
                            );
                          },
                          childCount: articles.length,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (_opening) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
