import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_dimensions.dart';
import '../../../../config/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/reading_time.dart';
import '../../../../shared/widgets/scrim_overlay.dart';
import '../../../../shared/widgets/striped_image_placeholder.dart';
import '../../domain/entities/authored_article_entity.dart';
import 'category_label.dart';

/// Row card used for every feed item after the first (featured) one.
class CompactArticleCard extends StatelessWidget {
  const CompactArticleCard({super.key, required this.article, required this.onTap});

  final AuthoredArticleEntity article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final dateLabel = article.publishedAt != null ? DateFormat.MMMd(l10n.localeName).format(article.publishedAt!) : '';
    final readLabel = l10n.readTimeMinutes(estimateReadingMinutes(article.body));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: palette.line),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 104,
              // Explicit height, not just width: StripedImagePlaceholder's
              // internal Stack(fit: expand) needs a bounded box to fill —
              // CrossAxisAlignment.stretch alone left this sizing to zero
              // with no layout error (Row's own height is resolved from
              // this same child, a circular/ambiguous case).
              height: 100,
              child: StripedImagePlaceholder(
                imageUrl: article.thumbnailURL,
                borderRadius: BorderRadius.circular(14),
                stripeWidth: 11,
                child: Stack(
                  children: [
                    const Positioned.fill(child: ScrimOverlay(opacityTop: 0.82)),
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 8,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: GlassPill(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          borderRadius: 7,
                          child: Text(
                            categoryLabel(l10n, article.category).toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 9.5, letterSpacing: 0.7, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w600, fontSize: dims.fMd, height: 1.22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.authorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: dims.fXs, color: palette.ink2),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dateLabel.isEmpty ? readLabel : '$dateLabel · $readLabel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: dims.fXs, color: palette.ink3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
