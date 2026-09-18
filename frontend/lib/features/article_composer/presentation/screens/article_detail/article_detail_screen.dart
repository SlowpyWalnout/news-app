import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../config/theme/app_dimensions.dart';
import '../../../../../config/theme/app_palette.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/utils/article_byline.dart';
import '../../../../../shared/utils/initials.dart';
import '../../../../../shared/widgets/app_buttons.dart';
import '../../../../../shared/widgets/app_toast.dart';
import '../../../../../shared/widgets/confirm_delete_sheet.dart';
import '../../../../../shared/widgets/inline_banner.dart';
import '../../../../../shared/widgets/initials_avatar.dart';
import '../../../../../shared/widgets/markdown_text.dart';
import '../../../../../shared/widgets/screen_header.dart';
import '../../../../../shared/widgets/scrim_overlay.dart';
import '../../../../../shared/widgets/status_pill.dart';
import '../../../../../shared/widgets/striped_image_placeholder.dart';
import '../../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../../daily_news/domain/entities/article.dart';
import '../../../../daily_news/presentation/bloc/article/local/read_later_bloc.dart';
import '../../../../daily_news/presentation/bloc/article/local/read_later_event.dart';
import '../../../../daily_news/presentation/bloc/article/local/read_later_state.dart';
import '../../../../moderation/domain/entities/moderation_state.dart'
    as moderation;
import '../../../../moderation/domain/params/decide_params.dart';
import '../../../../moderation/domain/params/report_article_params.dart';
import '../../../../moderation/presentation/bloc/moderation_cubit.dart';
import '../../../../moderation/presentation/bloc/staff_cubit.dart';
import '../../../../moderation/presentation/widgets/report_sheet.dart';
import '../../../domain/entities/authored_article_entity.dart';
import '../../bloc/article_actions/article_actions_cubit.dart';
import '../../widgets/category_label.dart';
import '../article_editor/article_editor_screen.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen(
      {super.key, required this.article, this.forcePermissionDenied = false});

  final AuthoredArticleEntity article;

  /// Test/debug hook mirroring the prototype's `notmine` simulated state.
  final bool forcePermissionDenied;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) =>
                sl<ReadLaterBloc>()..add(const ReadLaterRequested())),
        BlocProvider(create: (_) => sl<ArticleActionsCubit>()),
        BlocProvider(
            create: (_) => sl<ModerationCubit>()..checkReported(article.id)),
        BlocProvider(create: (_) => sl<StaffCubit>()..check()),
      ],
      child: _ArticleDetailView(
          article: article, forcePermissionDenied: forcePermissionDenied),
    );
  }
}

class _ArticleDetailView extends StatefulWidget {
  const _ArticleDetailView(
      {required this.article, required this.forcePermissionDenied});

  final AuthoredArticleEntity article;
  final bool forcePermissionDenied;

  @override
  State<_ArticleDetailView> createState() => _ArticleDetailViewState();
}

class _ArticleDetailViewState extends State<_ArticleDetailView> {
  AuthoredArticleEntity get article => widget.article;
  bool get forcePermissionDenied => widget.forcePermissionDenied;

  Future<void> _handleDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed =
        await showConfirmDeleteSheet(context, articleTitle: article.title);
    if (confirmed != true || !context.mounted) return;
    final ok = await context.read<ArticleActionsCubit>().delete(article.id);
    if (!context.mounted) return;
    if (ok) {
      showAppToast(context, l10n.articleDeletedToast);
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _openSource(BuildContext context) async {
    final url = article.sourceUrl;
    if (url == null) return;
    final l10n = AppLocalizations.of(context)!;
    final launched =
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!context.mounted || launched) return;
    showAppToast(context, l10n.externalOpenSourceError);
  }

  Future<void> _handleReport(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showReportSheet(context);
    if (result == null || !context.mounted) return;
    final (reason, note) = result;
    final ok = await context.read<ModerationCubit>().report(
          ReportArticleParams(
              articleId: article.id,
              reason: reason,
              note: note?.isEmpty == true ? null : note),
        );
    if (!context.mounted) return;
    showAppToast(context, ok ? l10n.reportSentToast : l10n.reportErrorToast);
  }

  Future<void> _handleDecide(
      BuildContext context, ModerationDecision decision) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await context
        .read<ModerationCubit>()
        .decide(DecideParams(articleId: article.id, decision: decision));
    if (!context.mounted) return;
    showAppToast(
      context,
      ok
          ? (decision == ModerationDecision.approve
              ? l10n.staffDecisionApprovedToast
              : l10n.staffDecisionRemovedToast)
          : l10n.reportErrorToast,
    );
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final currentUserId =
        context.select<AuthBloc, String?>((b) => b.state.user?.uid);
    final actionsCubit = context.read<ArticleActionsCubit>();
    final isMine = actionsCubit.isMine(article,
        currentUserId: currentUserId,
        forcePermissionDenied: forcePermissionDenied);
    final alreadyReported = context.watch<ModerationCubit>().state == true;
    final isStaff = context.watch<StaffCubit>().state;
    final byline = articleByline(l10n,
        publishedAt: article.publishedAt, body: article.body);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              trailing: BlocBuilder<ReadLaterBloc, ReadLaterState>(
                builder: (context, state) {
                  final stored = state.articles ?? const <ArticleEntity>[];
                  final match = actionsCubit.findStoredMatch(article, stored);
                  final saved = match != null;
                  return Semantics(
                    toggled: saved,
                    child: OutlinedButton(
                      onPressed: () {
                        if (saved) {
                          context
                              .read<ReadLaterBloc>()
                              .add(ReadLaterRemoved(match));
                        } else {
                          context
                              .read<ReadLaterBloc>()
                              .add(ReadLaterAdded(article.toFeedArticle()));
                        }
                        showAppToast(
                            context,
                            saved
                                ? l10n.readLaterRemovedToast
                                : l10n.readLaterAddedToast);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: saved
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surface,
                        foregroundColor: saved
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        side: BorderSide(
                            color: saved
                                ? Theme.of(context).colorScheme.primary
                                : palette.edge),
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13)),
                      ),
                      child: Text(
                          saved ? l10n.readLaterAdded : l10n.readLaterAdd,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  );
                },
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
                            child: const ScrimOverlay(
                                opacityTop: 0.97, opacityBottom: 0.12),
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
                                    categoryLabel(l10n, article.category)
                                        .toUpperCase(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: dims.fXs,
                                        letterSpacing: 1.1,
                                        color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  article.title,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: 'Space Grotesk',
                                      fontWeight: FontWeight.w600,
                                      fontSize: dims.fHero,
                                      height: 1.05,
                                      color: Colors.white),
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
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: palette.line, width: 1.5))),
                            child: Row(
                              children: [
                                InitialsAvatar(
                                    initials: initialsFrom(article.authorName),
                                    size: 48),
                                const SizedBox(width: 13),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article.authorName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: dims.fMd),
                                      ),
                                      Text(
                                        byline,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: dims.fSm,
                                            color: palette.ink3),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isMine) ...[
                            if (article.moderationState ==
                                moderation.ModerationState.suspended) ...[
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
                                      MaterialPageRoute(
                                          builder: (_) => ArticleEditorScreen(
                                              article: article)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: DestructiveButton(
                                      label: l10n.deleteAction,
                                      onPressed: () => _handleDelete(context)),
                                ),
                              ],
                            ),
                          ] else if (article.isExternal) ...[
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                StatusPill(
                                  label: l10n.sourceBadgeLabel,
                                  variant: ArticlePillVariant.external,
                                  icon: Icons.public,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    l10n.externalAttribution(
                                        article.sourceName ??
                                            article.authorName),
                                    style: TextStyle(
                                        fontSize: dims.fXs,
                                        color: palette.ink3),
                                  ),
                                ),
                              ],
                            ),
                            if (!article.hasFullBody) ...[
                              const SizedBox(height: 11),
                              InlineBanner(
                                title: l10n.externalPartialContentTitle,
                                body: l10n.externalPartialContentNotice,
                                variant: BannerVariant.info,
                              ),
                            ],
                            const SizedBox(height: 11),
                            PrimaryButton(
                              label: l10n.externalReadAtSource,
                              onPressed: () => _openSource(context),
                            ),
                          ] else ...[
                            const SizedBox(height: 20),
                            InlineBanner(
                              title: l10n.notYoursTitle,
                              body: l10n.notYoursBody(article.authorName),
                              variant: BannerVariant.warn,
                            ),
                            const SizedBox(height: 11),
                            SecondaryButton(
                              label: alreadyReported
                                  ? l10n.reportAlreadyDone
                                  : l10n.reportAction,
                              icon: const Icon(Icons.flag_outlined, size: 16),
                              expand: true,
                              onPressed: alreadyReported
                                  ? null
                                  : () => _handleReport(context),
                            ),
                          ],
                          if (isStaff &&
                              article.moderationState ==
                                  moderation.ModerationState.suspended) ...[
                            const SizedBox(height: 11),
                            Row(
                              children: [
                                Expanded(
                                  child: SecondaryButton(
                                    label: l10n.staffApprove,
                                    onPressed: () => _handleDecide(
                                        context, ModerationDecision.approve),
                                  ),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: DestructiveButton(
                                    label: l10n.staffRemove,
                                    onPressed: () => _handleDecide(
                                        context, ModerationDecision.remove),
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
