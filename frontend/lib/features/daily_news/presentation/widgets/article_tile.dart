import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/app_dimensions.dart';
import '../../../../config/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/article.dart';

class ArticleWidget extends StatelessWidget {
  const ArticleWidget({
    super.key,
    required this.article,
    this.onArticlePressed,
    this.isRemovable = false,
    this.onRemove,
  });

  final ArticleEntity article;
  final bool isRemovable;
  final void Function(ArticleEntity article)? onRemove;
  final void Function(ArticleEntity article)? onArticlePressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onArticlePressed?.call(article),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsetsDirectional.only(start: 14, end: 14, bottom: 7, top: 7),
        height: MediaQuery.of(context).size.width / 2.2,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: palette.line),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            _buildImage(context),
            _buildTitleAndDescription(context),
            _buildRemovableArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final imageUrl = article.urlToImage;
    if (imageUrl == null || imageUrl.isEmpty) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(end: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            width: MediaQuery.of(context).size.width / 3,
            height: double.maxFinite,
            color: Colors.black.withValues(alpha: 0.08),
            child: const Icon(Icons.image_not_supported_outlined),
          ),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Padding(
        padding: const EdgeInsetsDirectional.only(end: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            width: MediaQuery.of(context).size.width / 3,
            height: double.maxFinite,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.08),
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
      progressIndicatorBuilder: (context, url, downloadProgress) => Padding(
        padding: const EdgeInsetsDirectional.only(end: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            width: MediaQuery.of(context).size.width / 3,
            height: double.maxFinite,
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.08)),
            child: const CupertinoActivityIndicator(),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Padding(
        padding: const EdgeInsetsDirectional.only(end: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            width: MediaQuery.of(context).size.width / 3,
            height: double.maxFinite,
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.08)),
            child: const Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndDescription(BuildContext context) {
    final palette = context.palette;
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRemovable && article.isRead) ...[
              _AlreadyReadPill(label: AppLocalizations.of(context)!.readLaterAlreadyRead),
              const SizedBox(height: 6),
            ],
            Text(
              article.title ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w700,
                fontSize: dims.fMd,
                color: onSurface,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(article.description ?? '', maxLines: 2, style: TextStyle(color: palette.ink2)),
              ),
            ),
            if (article.publishedAt != null)
              Row(
                children: [
                  Icon(Icons.timeline_outlined, size: 16, color: palette.ink3),
                  const SizedBox(width: 4),
                  Text(article.publishedAt!, style: TextStyle(fontSize: dims.fXs, color: palette.ink3)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemovableArea() {
    if (!isRemovable) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => onRemove?.call(article),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Icon(Icons.bookmark_remove_outlined, color: Colors.red),
      ),
    );
  }
}

// Tells the reader this row is safe to unmark — it's already been opened
// once from Read it later.
class _AlreadyReadPill extends StatelessWidget {
  const _AlreadyReadPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final dims = Theme.of(context).extension<AppDimensions>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: palette.line,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 12, color: palette.ink3),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: dims.fXs, fontWeight: FontWeight.w700, color: palette.ink3),
          ),
        ],
      ),
    );
  }
}
