import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/app_palette.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/app_shell_controller.dart';
import '../../../../../shared/widgets/category_chip.dart';
import '../../../../../shared/widgets/initials_avatar.dart';
import '../../../../../shared/widgets/skeleton_block.dart';
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

class _FeedViewState extends State<_FeedView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(AuthoredArticleEntity article) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final userInitials = context.select<AuthBloc, String>((bloc) {
      final name = bloc.state.user?.displayName ?? '';
      final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
      if (parts.isEmpty) return '?';
      if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
      return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: palette.line, width: 1.5))),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: 'Space Grotesk',
                              fontWeight: FontWeight.w700,
                              fontSize: 23,
                              letterSpacing: -0.8,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            children: [
                              TextSpan(text: l10n.appWordmark),
                              TextSpan(text: '.', style: TextStyle(color: palette.accentInk)),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => sl<AppShellController>().goToTab(2),
                        child: InitialsAvatar(initials: userInitials, size: 46),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    constraints: const BoxConstraints(minHeight: 52),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                            onChanged: (v) => context.read<FeedBloc>().add(FeedQueryChanged(v)),
                            decoration: InputDecoration(
                              hintText: l10n.searchPlaceholder,
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            BlocBuilder<FeedBloc, FeedState>(
              buildWhen: (a, b) => a.category != b.category,
              builder: (context, state) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CategoryChip(
                            label: l10n.categoryAll,
                            active: state.category == null,
                            onTap: () => context.read<FeedBloc>().add(const FeedCategorySelected(null)),
                          ),
                        ),
                        for (final category in ArticleCategory.values)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CategoryChip(
                              label: categoryLabel(l10n, category),
                              active: state.category == category,
                              onTap: () => context.read<FeedBloc>().add(FeedCategorySelected(category)),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: BlocBuilder<FeedBloc, FeedState>(
                builder: (context, state) {
                  if (state.status == FeedStatus.loading) {
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
                      children: [
                        const SkeletonBlock(height: 250, borderRadius: 20),
                        const SizedBox(height: 16),
                        const SkeletonBlock(height: 120, borderRadius: 18, delay: Duration(milliseconds: 200)),
                        const SizedBox(height: 16),
                        const SkeletonBlock(height: 120, borderRadius: 18, delay: Duration(milliseconds: 400)),
                      ],
                    );
                  }
                  if (state.status == FeedStatus.failure) {
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
                      children: [
                        ErrorStateCard(
                          title: l10n.feedNetworkErrorTitle,
                          body: l10n.feedNetworkErrorBody,
                          retryLabel: l10n.retry,
                          onRetryPressed: () => context.read<FeedBloc>().add(const FeedRefreshed()),
                        ),
                      ],
                    );
                  }
                  final visible = state.visibleArticles;
                  if (state.status == FeedStatus.success && visible.isEmpty) {
                    final hasQuery = state.query.trim().isNotEmpty;
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
                      children: [
                        EmptyStateCard(
                          title: hasQuery ? l10n.feedEmptySearchTitle : l10n.feedEmptyFilterTitle,
                          body: hasQuery ? l10n.feedEmptySearchBody : l10n.feedEmptyFilterBody,
                          ctaLabel: l10n.viewAllCategories,
                          onCtaPressed: () {
                            _searchController.clear();
                            context.read<FeedBloc>()
                              ..add(const FeedQueryChanged(''))
                              ..add(const FeedCategorySelected(null));
                          },
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final article = visible[index];
                      if (index == 0) {
                        return FeaturedArticleCard(article: article, onTap: () => _openDetail(article));
                      }
                      return CompactArticleCard(article: article, onTap: () => _openDetail(article));
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
