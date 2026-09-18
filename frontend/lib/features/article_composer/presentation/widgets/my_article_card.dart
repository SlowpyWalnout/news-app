import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_dimensions.dart';
import '../../../../config/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/article_card_shell.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../../../shared/widgets/striped_image_placeholder.dart';
import '../../../moderation/domain/entities/moderation_state.dart';
import '../../domain/entities/article_status.dart';
import '../../domain/entities/authored_article_entity.dart';
import '../widgets/category_label.dart';

/// A row in "Mis artículos": thumbnail, status pill, title, category, and an
/// expandable edit/delete menu.
class MyArticleCard extends StatelessWidget {
  const MyArticleCard({
    super.key,
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
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final published = article.status == ArticleStatus.published;
    final suspended = article.moderationState == ModerationState.suspended;
    final dateLabel = DateFormat.MMMd(l10n.localeName).format(published
        ? article.publishedAt ?? article.updatedAt
        : article.updatedAt);
    final categoryText = categoryLabel(l10n, article.category);

    return ArticleCardShell(
      child: Column(
        children: [
          InkWell(
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: l10n.articleCardLabel(
                          article.title, dateLabel, categoryText),
                      excludeSemantics: true,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 78,
                            height: 78,
                            child: StripedImagePlaceholder(
                                imageUrl: article.thumbnailURL,
                                borderRadius: BorderRadius.circular(13)),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    StatusPill(
                                        label: suspended
                                            ? l10n.statusSuspended
                                            : (published
                                                ? l10n.publishedPill
                                                : l10n.draftPill),
                                        variant: suspended
                                            ? ArticlePillVariant.suspended
                                            : (published
                                                ? ArticlePillVariant.published
                                                : ArticlePillVariant.draft)),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(dateLabel,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: dims.fXs,
                                              color: palette.ink3)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  article.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: 'Space Grotesk',
                                      fontWeight: FontWeight.w600,
                                      fontSize: dims.fMd),
                                ),
                                const SizedBox(height: 6),
                                Text(categoryText,
                                    style: TextStyle(
                                        fontSize: dims.fXs,
                                        color: palette.ink3)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Semantics(
                    expanded: menuOpen,
                    child: IconButton(
                        tooltip: l10n.articleMenuTooltip,
                        onPressed: onToggleMenu,
                        icon: const Icon(Icons.more_horiz)),
                  ),
                ],
              ),
            ),
          ),
          if (menuOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                        label: l10n.editAction,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: onEdit),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: DestructiveButton(
                        label: l10n.deleteAction,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: onDelete),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
