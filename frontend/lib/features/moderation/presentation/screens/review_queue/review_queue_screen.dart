import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/presentation/failure_localizer.dart';
import '../../../../../shared/widgets/screen_header.dart';
import '../../../../../shared/widgets/skeleton_block.dart';
import '../../../../../shared/widgets/state_cards.dart';
import '../../../../article_composer/presentation/screens/article_detail/article_detail_screen.dart';
import '../../../../article_composer/presentation/widgets/compact_article_card.dart';
import '../../bloc/review_queue_cubit.dart';

class ReviewQueueScreen extends StatelessWidget {
  const ReviewQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReviewQueueCubit>()..load(),
      child: const _ReviewQueueView(),
    );
  }
}

class _ReviewQueueView extends StatefulWidget {
  const _ReviewQueueView();

  @override
  State<_ReviewQueueView> createState() => _ReviewQueueViewState();
}

class _ReviewQueueViewState extends State<_ReviewQueueView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels < _scrollController.position.maxScrollExtent - 200) return;
    context.read<ReviewQueueCubit>().loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: l10n.staffReviewQueueTitle),
            Expanded(
              child: BlocBuilder<ReviewQueueCubit, ReviewQueueState>(
                builder: (context, state) {
                  if (state.status == ReviewQueueStatus.loading || state.status == ReviewQueueStatus.initial) {
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: List.generate(4, (_) => const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: SkeletonBlock(height: 96, borderRadius: 20),
                          )),
                    );
                  }
                  if (state.status == ReviewQueueStatus.failure) {
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        ErrorStateCard(
                          title: l10n.readLaterErrorTitle,
                          body: state.errorCode != null
                              ? describeFailureCode(l10n, state.errorCode!)
                              : l10n.readLaterErrorBody,
                          retryLabel: l10n.retry,
                          onRetryPressed: () => context.read<ReviewQueueCubit>().load(),
                        ),
                      ],
                    );
                  }
                  if (state.articles.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        EmptyStateCard(
                          title: l10n.staffReviewQueueTitle,
                          body: l10n.staffReviewQueueEmpty,
                          ctaLabel: l10n.retry,
                          onCtaPressed: () => context.read<ReviewQueueCubit>().load(),
                          icon: Icons.shield_outlined,
                        ),
                      ],
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => context.read<ReviewQueueCubit>().load(),
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.articles.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index >= state.articles.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final article = state.articles[index];
                        return CompactArticleCard(
                          article: article,
                          onTap: () async {
                            final changed = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)),
                            );
                            if (changed == true && context.mounted) {
                              context.read<ReviewQueueCubit>().removeLocally(article.id);
                            }
                          },
                        );
                      },
                    ),
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
