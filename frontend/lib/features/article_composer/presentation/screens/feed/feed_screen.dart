import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/app_dimensions.dart';
import '../../../../../config/theme/app_palette.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/app_shell_controller.dart';
import '../../../../../shared/article_changes_notifier.dart';
import '../../../../../shared/widgets/category_chip.dart';
import '../../../../../shared/widgets/edge_fade_scroll.dart';
import '../../../../../shared/widgets/initials_avatar.dart';
import '../../../../../shared/widgets/skeleton_block.dart';
import '../../../../../shared/widgets/staggered_fade_in.dart';
import '../../../../../shared/widgets/state_cards.dart';
import '../../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../domain/entities/article_category.dart';
import '../../../domain/entities/authored_article_entity.dart';
import '../../bloc/feed/feed_bloc.dart';
import '../../bloc/feed/feed_event.dart';
import '../../bloc/feed/feed_state.dart';
import '../../widgets/category_label.dart';
import '../../widgets/compact_article_card.dart';
import '../../widgets/featured_article_card.dart';
import '../article_detail/article_detail_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FeedBloc>()..add(const FeedRequested()),
      child: const _FeedView(),
    );
  }
}

class _FeedView extends StatefulWidget {
  const _FeedView();

  @override
  State<_FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<_FeedView>
    with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  final _articleChanges = sl<ArticleChangesNotifier>();
  late int _lastSeenRevision = _articleChanges.revision;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _articleChanges.addListener(_onArticlesChanged);
  }

  @override
  void dispose() {
    _articleChanges.removeListener(_onArticlesChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onArticlesChanged() {
    if (!mounted) return;
    final revision = _articleChanges.revision;
    if (revision == _lastSeenRevision) return;
    _lastSeenRevision = revision;
    final bloc = context.read<FeedBloc>();
    if (bloc.isClosed) return;
    bloc.add(const FeedRequested());
  }

  void _openDetail(AuthoredArticleEntity article) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final userInitials = context.select<AuthBloc, String>((bloc) {
      final name = bloc.state.user?.displayName ?? '';
      final parts =
          name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
      if (parts.isEmpty) return '?';
      if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
      return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
          .toUpperCase();
    });

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: palette.accentInk,
          onRefresh: () async {
            final bloc = context.read<FeedBloc>();
            if (bloc.isClosed) return;
            bloc.add(const FeedRefreshed());
            try {
              await bloc.stream
                  .firstWhere((s) => s.status != FeedStatus.loading);
            } on StateError {
              // Tab cerrada a mitad del refresh: el bloc se cerró antes de
              // un estado terminal. No hay nada que mostrar ni que fallar.
            }
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: false,
                floating: true,
                snap: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: Theme.of(context)
                    .scaffoldBackgroundColor
                    .withValues(alpha: 0.82),
                surfaceTintColor: Colors.transparent,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: const SizedBox.expand(),
                  ),
                ),
                automaticallyImplyLeading: false,
                toolbarHeight: 0,
                titleSpacing: 0,
                title: const SizedBox.shrink(),
                bottom: PreferredSize(
                  preferredSize:
                      Size.fromHeight(164 + math.max(46, dims.fH * 1.3)),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(color: palette.line, width: 1.5))),
                    child: Column(
                      children: [
                        SizedBox(
                          height: math.max(46, dims.fH * 1.3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Space Grotesk',
                                    fontWeight: FontWeight.w700,
                                    fontSize: dims.fH,
                                    letterSpacing: -0.8,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  children: [
                                    TextSpan(text: l10n.appWordmark),
                                    TextSpan(
                                        text: '.',
                                        style:
                                            TextStyle(color: palette.accentInk)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    sl<AppShellController>().goToTab(2),
                                child: InitialsAvatar(
                                    initials: userInitials, size: 46),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          constraints: const BoxConstraints(minHeight: 52),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            border: Border.all(color: palette.line),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: palette.ink3, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (v) => context
                                      .read<FeedBloc>()
                                      .add(FeedQueryChanged(v)),
                                  decoration: InputDecoration(
                                    hintText: l10n.searchPlaceholder,
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: dims.fMd),
                                ),
                              ),
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _searchController,
                                builder: (context, value, _) {
                                  if (value.text.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return IconButton(
                                    icon: Icon(Icons.close,
                                        color: palette.ink3, size: 18),
                                    tooltip: l10n.searchClear,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      _searchController.clear();
                                      context
                                          .read<FeedBloc>()
                                          .add(const FeedQueryChanged(''));
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        BlocBuilder<FeedBloc, FeedState>(
                          buildWhen: (a, b) => a.category != b.category,
                          builder: (context, state) {
                            return SizedBox(
                              height: 42,
                              child: EdgeFadeScroll(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: CategoryChip(
                                      label: l10n.categoryAll,
                                      icon: Icons.grid_view_outlined,
                                      active: state.category == null,
                                      onTap: () => context.read<FeedBloc>().add(
                                          const FeedCategorySelected(null)),
                                    ),
                                  ),
                                  for (final category in ArticleCategory.values)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: CategoryChip(
                                        label: categoryLabel(l10n, category),
                                        icon: categoryIcon(category),
                                        active: state.category == category,
                                        onTap: () => context
                                            .read<FeedBloc>()
                                            .add(
                                                FeedCategorySelected(category)),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              BlocBuilder<FeedBloc, FeedState>(
                builder: (context, state) {
                  if (state.status == FeedStatus.loading) {
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                      sliver: SliverList.list(
                        children: [
                          const SkeletonBlock(height: 250, borderRadius: 20),
                          const SizedBox(height: 16),
                          const SkeletonBlock(
                              height: 120,
                              borderRadius: 18,
                              delay: Duration(milliseconds: 200)),
                          const SizedBox(height: 16),
                          const SkeletonBlock(
                              height: 120,
                              borderRadius: 18,
                              delay: Duration(milliseconds: 400)),
                        ],
                      ),
                    );
                  }
                  if (state.status == FeedStatus.failure) {
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                      sliver: SliverList.list(
                        children: [
                          ErrorStateCard(
                            title: l10n.feedNetworkErrorTitle,
                            body: l10n.feedNetworkErrorBody,
                            retryLabel: l10n.retry,
                            onRetryPressed: () => context
                                .read<FeedBloc>()
                                .add(const FeedRefreshed()),
                          ),
                        ],
                      ),
                    );
                  }
                  final visible = state.visibleArticles;
                  if (state.isEmpty) {
                    final hasQuery = state.query.trim().isNotEmpty;
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                      sliver: SliverList.list(
                        children: [
                          EmptyStateCard(
                            title: hasQuery
                                ? l10n.feedEmptySearchTitle
                                : l10n.feedEmptyFilterTitle,
                            body: hasQuery
                                ? l10n.feedEmptySearchBody
                                : l10n.feedEmptyFilterBody,
                            ctaLabel: l10n.viewAllCategories,
                            onCtaPressed: () {
                              _searchController.clear();
                              context.read<FeedBloc>()
                                ..add(const FeedQueryChanged(''))
                                ..add(const FeedCategorySelected(null));
                            },
                          ),
                        ],
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                    sliver: SliverList.separated(
                      itemCount: visible.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        if (index == visible.length) {
                          if (!state.hasMore) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Center(
                              child: state.isLoadingMore
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 13),
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.5),
                                      ),
                                    )
                                  : OutlinedButton(
                                      onPressed: () => context
                                          .read<FeedBloc>()
                                          .add(const FeedMoreRequested()),
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(0, 50),
                                        side: BorderSide(color: palette.edge),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14)),
                                      ),
                                      child: Text(
                                        l10n.loadMore,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                            ),
                          );
                        }
                        final article = visible[index];
                        final card = index == 0
                            ? FeaturedArticleCard(
                                article: article,
                                onTap: () => _openDetail(article))
                            : CompactArticleCard(
                                article: article,
                                onTap: () => _openDetail(article));
                        return StaggeredFadeIn(
                          key: ValueKey('${state.category}_${article.id}'),
                          index: index,
                          child: card,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
