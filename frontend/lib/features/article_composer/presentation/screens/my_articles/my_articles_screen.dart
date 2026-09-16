import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../config/theme/app_palette.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/app_shell_controller.dart';
import '../../../../../shared/widgets/app_buttons.dart';
import '../../../../../shared/widgets/app_toast.dart';
import '../../../../../shared/widgets/confirm_delete_sheet.dart';
import '../../../../../shared/widgets/segmented_tabs.dart';
import '../../../../../shared/widgets/skeleton_block.dart';
import '../../../../../shared/widgets/state_cards.dart';
import '../../../../../shared/widgets/status_pill.dart';
import '../../../../../shared/widgets/striped_image_placeholder.dart';
import '../../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../domain/entities/article_status.dart';
import '../../../domain/entities/authored_article_entity.dart';
import '../../bloc/my_articles/my_articles_bloc.dart';
import '../../bloc/my_articles/my_articles_event.dart';
import '../../bloc/my_articles/my_articles_state.dart';
import '../../widgets/category_label.dart';
import '../article_detail/article_detail_screen.dart';
import '../article_editor/article_editor_screen.dart';

class MyArticlesScreen extends StatelessWidget {
  const MyArticlesScreen({super.key, this.initialTab});

  /// One of 'all' / 'drafts' / 'published'. Used when arriving from a
  /// "Guardar borrador"/"Publicar" action so the right tab is pre-selected.
  final String? initialTab;

  @override
  Widget build(BuildContext context) {
    final authorId = context.read<AuthBloc>().state.user?.uid ?? '';
    return BlocProvider(
      create: (_) {
        final bloc = sl<MyArticlesBloc>()..add(MyArticlesRequested(authorId));
        final tab = switch (initialTab) {
          'drafts' => MyArticlesTab.drafts,
          'published' => MyArticlesTab.published,
          _ => null,
        };
        if (tab != null) bloc.add(MyArticlesTabChanged(tab));
        return bloc;
      },
      child: const _MyArticlesView(),
    );
  }
}

class _MyArticlesView extends StatefulWidget {
  const _MyArticlesView();

  @override
  State<_MyArticlesView> createState() => _MyArticlesViewState();
}

class _MyArticlesViewState extends State<_MyArticlesView> {
  String? _openMenuId;
  final _shellController = sl<AppShellController>();
  late int _lastSeenRefreshTick = _shellController.myArticlesRefreshTick;

  @override
  void initState() {
    super.initState();
    _shellController.addListener(_onShellControllerChanged);
  }

  @override
  void dispose() {
    _shellController.removeListener(_onShellControllerChanged);
    super.dispose();
  }

  void _onShellControllerChanged() {
    final tick = _shellController.myArticlesRefreshTick;
    final subTab = _shellController.consumeMyArticlesSubTab();
    if (tick == _lastSeenRefreshTick || !mounted) return;
    _lastSeenRefreshTick = tick;

    final bloc = context.read<MyArticlesBloc>();
    final tab = switch (subTab) {
      'drafts' => MyArticlesTab.drafts,
      'published' => MyArticlesTab.published,
      _ => null,
    };
    if (tab != null) bloc.add(MyArticlesTabChanged(tab));
    final authorId = context.read<AuthBloc>().state.user?.uid ?? '';
    bloc.add(MyArticlesRequested(authorId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: palette.line, width: 1.5))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.myArticlesTitle, style: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w600, fontSize: 28)),
                  const SizedBox(height: 14),
                  BlocBuilder<MyArticlesBloc, MyArticlesState>(
                    buildWhen: (a, b) => a.tab != b.tab,
                    builder: (context, state) => SegmentedTabs(
                      items: [
                        SegmentedTabItem(label: l10n.tabAll, value: MyArticlesTab.all.name),
                        SegmentedTabItem(label: l10n.tabDrafts, value: MyArticlesTab.drafts.name),
                        SegmentedTabItem(label: l10n.tabPublished, value: MyArticlesTab.published.name),
                      ],
                      selected: state.tab.name,
                      onSelected: (v) => context.read<MyArticlesBloc>().add(
                            MyArticlesTabChanged(MyArticlesTab.values.byName(v)),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<MyArticlesBloc, MyArticlesState>(
                builder: (context, state) {
                  if (state.status == MyArticlesStatus.loading) {
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                      children: const [
                        SkeletonBlock(height: 110),
                        SizedBox(height: 13),
                        SkeletonBlock(height: 110, delay: Duration(milliseconds: 200)),
                        SizedBox(height: 13),
                        SkeletonBlock(height: 110, delay: Duration(milliseconds: 400)),
                      ],
                    );
                  }
                  if (state.status == MyArticlesStatus.failure) {
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                      children: [
                        ErrorStateCard(
                          title: l10n.myArticlesNetErrorTitle,
                          body: l10n.myArticlesNetErrorBody,
                          retryLabel: l10n.retry,
                          onRetryPressed: () {
                            final authorId = context.read<AuthBloc>().state.user?.uid ?? '';
                            context.read<MyArticlesBloc>().add(MyArticlesRequested(authorId));
                          },
                        ),
                      ],
                    );
                  }
                  if (state.isEmpty) {
                    final isDrafts = state.tab == MyArticlesTab.drafts;
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                      children: [
                        EmptyStateCard(
                          title: isDrafts ? l10n.myArticlesEmptyDraftTitle : l10n.myArticlesEmptyTitle,
                          body: isDrafts ? l10n.myArticlesEmptyDraftBody : l10n.myArticlesEmptyBody,
                          ctaLabel: l10n.writeFirstArticle,
                          onCtaPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ArticleEditorScreen()),
                          ),
                        ),
                      ],
                    );
                  }
                  final visible = state.visibleArticles;
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
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
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: palette.ink3),
                              ),
                              OutlinedButton(
                                onPressed: state.hasMore
                                    ? () => context.read<MyArticlesBloc>().add(const MyArticlesMoreRequested())
                                    : null,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 50),
                                  side: BorderSide(color: palette.edge),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: Text(
                                  state.hasMore ? l10n.loadMore : l10n.noMore,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      final article = visible[index];
                      return _MyArticleCard(
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
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyArticleCard extends StatelessWidget {
  const _MyArticleCard({
    required this.article,
    required this.menuOpen,
    required this.onToggleMenu,
    required this.onEdit,
    required this.onDelete,
    required this.onOpen,
  });

  final AuthoredArticleEntity article;
  final bool menuOpen;
  final VoidCallback onToggleMenu;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final published = article.status == ArticleStatus.published;
    final dateLabel = DateFormat.MMMd(l10n.localeName).format(published ? article.publishedAt ?? article.updatedAt : article.updatedAt);
    final categoryText = categoryLabel(l10n, article.category);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: palette.line),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 78,
                    height: 78,
                    child: StripedImagePlaceholder(imageUrl: article.thumbnailURL, borderRadius: BorderRadius.circular(13)),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            StatusPill(label: published ? l10n.publishedPill : l10n.draftPill, published: published),
                            const SizedBox(width: 8),
                            Text(dateLabel, style: TextStyle(fontSize: 12.5, color: palette.ink3)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w600, fontSize: 17.5),
                        ),
                        const SizedBox(height: 6),
                        Text(categoryText, style: TextStyle(fontSize: 12.5, color: palette.ink3)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: onToggleMenu, icon: const Icon(Icons.more_horiz)),
                ],
              ),
            ),
          ),
          if (menuOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                children: [
                  Expanded(child: SecondaryButton(label: l10n.editAction, onPressed: onEdit)),
                  const SizedBox(width: 9),
                  Expanded(child: DestructiveButton(label: l10n.deleteAction, onPressed: onDelete)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
