import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/app_palette.dart';
import '../../../../../core/resources/data_state.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/widgets/skeleton_block.dart';
import '../../../../../shared/widgets/state_cards.dart';
import '../../../../article_composer/domain/entities/authored_article_entity.dart';
import '../../../../article_composer/domain/use_cases/get_article_by_id_use_case.dart';
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

  // Tries the fresh Firestore doc first (so the reader sees current
  // category/author and, if it's their own article, Edit/Delete); falls
  // back to the cached row — read-only — if there's no network or the
  // article was since deleted.
  Future<void> _openArticle(ArticleEntity cached) async {
    if (_opening) return;
    setState(() => _opening = true);

    AuthoredArticleEntity resolved = AuthoredArticleEntity.fromCachedArticle(cached);
    var openedFromCache = true;

    final sourceId = cached.sourceId;
    if (sourceId != null && sourceId.isNotEmpty) {
      final result = await sl<GetArticleByIdUseCase>().call(sourceId);
      if (result is DataSuccess<AuthoredArticleEntity?> && result.data != null) {
        resolved = result.data!;
        openedFromCache = false;
      }
    }

    if (!mounted) return;
    setState(() => _opening = false);

    final id = cached.id;
    if (id != null && !cached.isRead) {
      context.read<ReadLaterBloc>().add(ReadLaterMarkedRead(id));
    }

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
            onRefresh: () async {
              final bloc = context.read<ReadLaterBloc>();
              if (bloc.isClosed) return;
              bloc.add(const ReadLaterRefreshed());
              try {
                await bloc.stream.firstWhere((s) => s is! ReadLaterLoading);
              } on StateError {
                // Pantalla cerrada a mitad del refresh: el bloc se cerró
                // antes de un estado terminal. No hay nada que mostrar.
              }
            },
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
                            SkeletonBlock(
                                height: MediaQuery.sizeOf(context).width / 2.2,
                                borderRadius: 20),
                            const SizedBox(height: 12),
                            SkeletonBlock(
                                height: MediaQuery.sizeOf(context).width / 2.2,
                                borderRadius: 20,
                                delay: const Duration(milliseconds: 200)),
                            const SizedBox(height: 12),
                            SkeletonBlock(
                                height: MediaQuery.sizeOf(context).width / 2.2,
                                borderRadius: 20,
                                delay: const Duration(milliseconds: 400)),
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
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              l10n.readLaterEmpty,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: context.palette.ink2),
                            ),
                          ),
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
