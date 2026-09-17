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
import '../../../../../shared/widgets/inline_banner.dart';
import '../../../../../shared/widgets/initials_avatar.dart';
import '../../../../../shared/widgets/markdown_text.dart';
import '../../../../../shared/widgets/scrim_overlay.dart';
import '../../../../../shared/widgets/striped_image_placeholder.dart';
import '../../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../../daily_news/domain/entities/article.dart';
import '../../../../daily_news/presentation/bloc/article/local/read_later_bloc.dart';
import '../../../../daily_news/presentation/bloc/article/local/read_later_event.dart';
import '../../../../daily_news/presentation/bloc/article/local/read_later_state.dart';
import '../../../../moderation/domain/entities/moderation_state.dart' as moderation;
import '../../../../moderation/domain/params/decide_params.dart';
import '../../../../moderation/domain/params/report_article_params.dart';
import '../../../../moderation/presentation/bloc/moderation_cubit.dart';
import '../../../../moderation/presentation/staff_gate.dart';
import '../../../../moderation/presentation/widgets/report_sheet.dart';
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
        BlocProvider(create: (_) => sl<ModerationCubit>()),
      ],
      child: _ArticleDetailView(article: article, forcePermissionDenied: forcePermissionDenied),
    );
  }
}

class _ArticleDetailView extends StatefulWidget {
  const _ArticleDetailView({required this.article, required this.forcePermissionDenied});

  final AuthoredArticleEntity article;
  final bool forcePermissionDenied;

  @override
  State<_ArticleDetailView> createState() => _ArticleDetailViewState();
}

class _ArticleDetailViewState extends State<_ArticleDetailView> {
  AuthoredArticleEntity get article => widget.article;
  bool get forcePermissionDenied => widget.forcePermissionDenied;

  bool _alreadyReported = false;
  bool _isStaff = false;

  @override
  void initState() {
    super.initState();
    context.read<ModerationCubit>().hasReported(article.id).then((value) {
      if (mounted) setState(() => _alreadyReported = value);
    });
    sl<StaffGate>().isStaff.then((value) {
      if (mounted) setState(() => _isStaff = value);
    });
  }

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

  Future<void> _handleReport(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showReportSheet(context);
    if (result == null || !context.mounted) return;
    final (reason, note) = result;
    final ok = await context.read<ModerationCubit>().report(
      ReportArticleParams(articleId: article.id, reason: reason, note: note?.isEmpty == true ? null : note),
    );
    if (!context.mounted) return;
    showAppToast(context, ok ? l10n.reportSentToast : l10n.reportErrorToast);
    if (ok) setState(() => _alreadyReported = true);
  }

  Future<void> _handleDecide(BuildContext context, ModerationDecision decision) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await context.read<ModerationCubit>().decide(DecideParams(articleId: article.id, decision: decision));
    if (!context.mounted) return;
    showAppToast(
      context,
      ok
          ? (decision == ModerationDecision.approve ? l10n.staffDecisionApprovedToast : l10n.staffDecisionRemovedToast)
          : l10n.reportErrorToast,
    );
    if (ok) Navigator.of(context).pop(true);
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
                            if (article.moderationState == moderation.ModerationState.suspended) ...[
                              const SizedBox(height: 20),
                              InlineBanner(
                                title: l10n.suspendedBannerTitle,
                                body: l10n.suspendedBannerBody,
                                variant: BannerVariant.warn,
                              ),
                            ],
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
                            const SizedBox(height: 11),
                            SecondaryButton(
                              label: _alreadyReported ? l10n.reportAlreadyDone : l10n.reportAction,
                              icon: const Icon(Icons.flag_outlined, size: 16),
                              expand: true,
                              onPressed: _alreadyReported ? null : () => _handleReport(context),
                            ),
                          ],
                          if (_isStaff && article.moderationState == moderation.ModerationState.suspended) ...[
                            const SizedBox(height: 11),
                            Row(
                              children: [
                                Expanded(
                                  child: SecondaryButton(
                                    label: l10n.staffApprove,
                                    onPressed: () => _handleDecide(context, ModerationDecision.approve),
                                  ),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: DestructiveButton(
                                    label: l10n.staffRemove,
                                    onPressed: () => _handleDecide(context, ModerationDecision.remove),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 22),
                          MarkdownText(article.body),
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
