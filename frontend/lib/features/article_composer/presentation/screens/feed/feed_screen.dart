import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/app_dimensions.dart';
import '../../../../../config/theme/app_palette.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/app_shell_controller.dart';
import '../../../../../shared/article_changes_notifier.dart';
import '../../../../../shared/presentation/article_changes_listener.dart';
import '../../../../../shared/utils/bloc_refresh.dart';
import '../../../../../shared/utils/initials.dart';
import '../../../../../shared/widgets/app_wordmark.dart';
import '../../../../../shared/widgets/blurred_sliver_header.dart';
import '../../../../../shared/widgets/category_chip.dart';
import '../../../../../shared/widgets/edge_fade_scroll.dart';
import '../../../../../shared/widgets/initials_avatar.dart';
import '../../../../../shared/widgets/load_more_footer.dart';
import '../../../../../shared/widgets/skeleton_list.dart';
import '../../../../../shared/widgets/staggered_fade_in.dart';
import '../../../../../shared/widgets/state_cards.dart';
import '../../../../../shared/settings/domain/entities/app_settings_entity.dart';
import '../../../../../shared/settings/presentation/cubit/settings_cubit.dart';
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
      create: (context) => sl<FeedBloc>()
        ..add(const FeedRequested())
        ..add(FeedPreferredLanguageChanged(
            context.read<SettingsCubit>().state.locale.languageCode)),
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
    with AutomaticKeepAliveClientMixin, ArticleChangesListenerMixin<_FeedView> {
  final _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void onArticlesChanged(ArticleChangesNotifier notifier) {
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
    final userInitials = context.select<AuthBloc, String>(
        (bloc) => initialsFrom(bloc.state.user?.displayName ?? ''));

    return BlocListener<SettingsCubit, AppSettingsEntity>(
      listenWhen: (a, b) => a.locale.languageCode != b.locale.languageCode,
      listener: (context, settings) => context
          .read<FeedBloc>()
          .add(FeedPreferredLanguageChanged(settings.locale.languageCode)),
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            color: palette.accentInk,
            onRefresh: () => refreshAndSettle(
              bloc: context.read<FeedBloc>(),
              event: const FeedRefreshed(),
              isSettled: (s) => s.status != FeedStatus.loading,
            ),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                BlurredSliverHeader(
                  preferredHeight: 170 + math.max(46, dims.fH * 1.3),
                  child: Column(
                    children: [
                      SizedBox(
                        height: math.max(46, dims.fH * 1.3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppWordmark(text: l10n.appWordmark),
                            Semantics(
                              button: true,
                              label: l10n.openProfile,
                              excludeSemantics: true,
                              child: GestureDetector(
                                onTap: () =>
                                    sl<AppShellController>().goToTab(2),
                                child: InitialsAvatar(
                                    initials: userInitials, size: 46),
                              ),
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
                            height: 48,
                            child: EdgeFadeScroll(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: CategoryChip(
                                    label: l10n.categoryAll,
                                    icon: Icons.grid_view_outlined,
                                    active: state.category == null,
                                    onTap: () => context
                                        .read<FeedBloc>()
                                        .add(const FeedCategorySelected(null)),
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
                                          .add(FeedCategorySelected(category)),
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
                BlocBuilder<FeedBloc, FeedState>(
                  builder: (context, state) {
                    if (state.status == FeedStatus.loading) {
                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                        sliver: SliverList.list(
                          children: const [
                            SkeletonList(heights: [250, 120, 120], gap: 16),
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
                            return LoadMoreFooter(
                              hasMore: state.hasMore,
                              isLoadingMore: state.isLoadingMore,
                              label: l10n.loadMore,
                              onPressed: () => context
                                  .read<FeedBloc>()
                                  .add(const FeedMoreRequested()),
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
      ),
    );
  }
}
