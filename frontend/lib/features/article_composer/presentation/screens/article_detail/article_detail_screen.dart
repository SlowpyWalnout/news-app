import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../config/theme/app_dimensions.dart';
import '../../../../../config/theme/app_palette.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/utils/reading_time.dart';
import '../../../../../shared/widgets/app_buttons.dart';
import '../../../../../shared/widgets/app_toast.dart';
import '../../../../../shared/widgets/confirm_delete_sheet.dart';
import '../../../../../shared/widgets/initials_avatar.dart';
import '../../../../../shared/widgets/scrim_overlay.dart';
import '../../../../../shared/widgets/striped_image_placeholder.dart';
import '../../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../../daily_news/domain/entities/article.dart';
import '../../../../daily_news/presentation/bloc/article/local/read_later_bloc.dart';
import '../../../../daily_news/presentation/bloc/article/local/read_later_event.dart';
import '../../../../daily_news/presentation/bloc/article/local/read_later_state.dart';
import '../../../domain/entities/authored_article_entity.dart';
import '../../bloc/article_actions/article_actions_cubit.dart';
import '../../widgets/category_label.dart';
import '../article_editor/article_editor_screen.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key, required this.article, this.forcePermissionDenied = false});

  final AuthoredArticleEntity article;

  /// Test/debug hook mirroring the prototype's `notmine` simulated state.
  final bool forcePermissionDenied;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ReadLaterBloc>()..add(const ReadLaterRequested())),
        BlocProvider(create: (_) => sl<ArticleActionsCubit>()),
      ],
      child: _ArticleDetailView(article: article, forcePermissionDenied: forcePermissionDenied),
    );
  }
}

class _ArticleDetailView extends StatelessWidget {
  const _ArticleDetailView({required this.article, required this.forcePermissionDenied});

  final AuthoredArticleEntity article;
  final bool forcePermissionDenied;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  // Matches this screen's article against a stored Read it later row so
  // removal always uses the row's real Floor `id`, never a freshly built
  // ArticleEntity with a null one (that used to crash the DELETE query —
  // Floor drops null primary-key args, leaving a bind-count mismatch).
  // Falls back to a title match for rows saved before `sourceId` existed.
  ArticleEntity? _findStoredMatch(List<ArticleEntity> stored) {
    for (final row in stored) {
      if (row.sourceId == article.id) return row;
    }
    for (final row in stored) {
      if (row.sourceId == null && row.title == article.title) return row;
    }
    return null;
  }

  Future<void> _handleDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDeleteSheet(context, articleTitle: article.title);
    if (confirmed != true || !context.mounted) return;
    final ok = await context.read<ArticleActionsCubit>().delete(article.id);
    if (!context.mounted) return;
    if (ok) {
      showAppToast(context, l10n.articleDeletedToast);
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final currentUserId = context.select<AuthBloc, String?>((b) => b.state.user?.uid);
    final isMine = !forcePermissionDenied && currentUserId != null && currentUserId == article.authorId;
    final dateLabel = article.publishedAt != null ? DateFormat.MMMd(l10n.localeName).format(article.publishedAt!) : '';
    final readLabel = l10n.readTimeMinutes(estimateReadingMinutes(article.body));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: palette.line, width: 1.5))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackPillButton(label: l10n.backToFeed, onPressed: () => Navigator.of(context).maybePop()),
                  BlocBuilder<ReadLaterBloc, ReadLaterState>(
                    builder: (context, state) {
                      final stored = state.articles ?? const <ArticleEntity>[];
                      final match = _findStoredMatch(stored);
                      final saved = match != null;
                      return OutlinedButton(
                        onPressed: () {
                          if (saved) {
                            context.read<ReadLaterBloc>().add(ReadLaterRemoved(match));
                          } else {
                            context.read<ReadLaterBloc>().add(ReadLaterAdded(article.toFeedArticle()));
                          }
                          showAppToast(context, saved ? l10n.readLaterRemovedToast : l10n.readLaterAddedToast);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: saved ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                          foregroundColor: saved ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                          side: BorderSide(color: saved ? Theme.of(context).colorScheme.primary : palette.edge),
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                        ),
                        child: Text(saved ? l10n.readLaterAdded : l10n.readLaterAdd, style: const TextStyle(fontWeight: FontWeight.w700)),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      // Fixed height, not minHeight: StripedImagePlaceholder's
                      // internal Stack(fit: expand) needs a bounded box —
                      // this sits in a SingleChildScrollView, which gives
                      // unbounded height, so minHeight alone rendered blank.
                      height: 290,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(),
                      child: Stack(
                        children: [
                          StripedImagePlaceholder(
                            imageUrl: article.thumbnailURL,
                            stripeWidth: 15,
                            child: const ScrimOverlay(opacityTop: 0.97, opacityBottom: 0.12),
                          ),
                          Positioned(
                            left: 22,
                            right: 22,
                            bottom: 24,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GlassPill(
                                  child: Text(
                                    categoryLabel(l10n, article.category).toUpperCase(),
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: dims.fXs, letterSpacing: 1.1, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  article.title,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w600, fontSize: dims.fHero, height: 1.05, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 20, 22, 44),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: palette.line, width: 1.5))),
                            child: Row(
                              children: [
                                InitialsAvatar(initials: _initials(article.authorName), size: 48),
                                const SizedBox(width: 13),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article.authorName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: dims.fMd),
                                      ),
                                      Text(
                                        dateLabel.isEmpty ? readLabel : '$dateLabel · $readLabel',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: dims.fSm, color: palette.ink3),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isMine) ...[
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: SecondaryButton(
                                    label: l10n.editAction,
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => ArticleEditorScreen(article: article)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: DestructiveButton(label: l10n.deleteAction, onPressed: () => _handleDelete(context)),
                                ),
                              ],
                            ),
                          ] else ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
                              decoration: BoxDecoration(
                                color: palette.warnSoft,
                                border: Border.all(color: palette.warn),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.notYoursTitle, style: TextStyle(fontWeight: FontWeight.w700, fontSize: dims.fMd)),
                                  const SizedBox(height: 5),
                                  Text(l10n.notYoursBody(article.authorName), style: TextStyle(fontSize: dims.fSm, height: 1.5, color: palette.ink2)),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 22),
                          for (final paragraph in article.body.split(RegExp(r'\n{2,}')))
                            if (paragraph.trim().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 18),
                                child: Text(paragraph.trim(), style: TextStyle(fontSize: dims.fMd, height: 1.68)),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
