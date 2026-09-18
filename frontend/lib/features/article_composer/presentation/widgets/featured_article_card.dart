import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_dimensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/initials.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../../../../shared/widgets/scrim_overlay.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../../../shared/widgets/striped_image_placeholder.dart';
import '../../domain/entities/authored_article_entity.dart';
import 'category_label.dart';

/// Large hero card for the first item in the feed.
class FeaturedArticleCard extends StatelessWidget {
  const FeaturedArticleCard(
      {super.key, required this.article, required this.onTap});

  final AuthoredArticleEntity article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dims = Theme.of(context).extension<AppDimensions>()!;

    final semanticLabel = l10n.articleCardLabel(
      article.title,
      article.authorName,
      categoryLabel(l10n, article.category),
    );

    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          // A fixed height (not minHeight) is required: Stack's fit:expand
          // below needs a bounded box to fill, and ListView.separated gives
          // this item unbounded height, so minHeight alone left it sizing to
          // zero with no layout error.
          height: 330,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              StripedImagePlaceholder(
                imageUrl: article.thumbnailURL,
                borderRadius: BorderRadius.circular(22),
                child: const ScrimOverlay(),
              ),
              Positioned(
                top: 14,
                left: 14,
                right: 14,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: GlassPill(
                    child: Text(
                      categoryLabel(l10n, article.category).toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: dims.fXs,
                          letterSpacing: 1.1,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (article.isExternal) ...[
                        StatusPill(
                          label: l10n.sourceBadgeLabel,
                          variant: ArticlePillVariant.external,
                          icon: Icons.public,
                        ),
                        const SizedBox(height: 10),
                      ],
                      Text(
                        article.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontWeight: FontWeight.w600,
                          fontSize: dims.fH,
                          height: 1.1,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          InitialsAvatar(
                              initials: initialsFrom(article.authorName),
                              size: 36,
                              glass: true),
                          const SizedBox(width: 11),
                          Flexible(
                            child: Text(
                              article.authorName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: dims.fSm,
                                  color: Colors.white),
                            ),
                          ),
                          if (article.publishedAt != null)
                            Text(
                              ' · ${DateFormat.MMMd(l10n.localeName).format(article.publishedAt!)}',
                              style: TextStyle(
                                  fontSize: dims.fSm,
                                  color: Colors.white.withValues(alpha: 0.7)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
