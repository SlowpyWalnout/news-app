import 'package:flutter/material.dart';

import '../../config/theme/app_dimensions.dart';
import '../../config/theme/app_palette.dart';

enum ArticlePillVariant { published, draft, suspended, alreadyRead }

/// Publicado/borrador/suspendido/ya-lo-leí pill, shared by "Mis artículos"
/// and "Leer después" cards.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.variant, this.icon});

  final String label;
  final ArticlePillVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;
    final dims = Theme.of(context).extension<AppDimensions>()!;

    final Color bg;
    final Color border;
    final Color fg;
    switch (variant) {
      case ArticlePillVariant.published:
        bg = scheme.primary;
        border = scheme.primary;
        fg = scheme.onPrimary;
      case ArticlePillVariant.draft:
        bg = palette.warnSoft;
        border = palette.warn;
        fg = palette.warn;
      case ArticlePillVariant.suspended:
        bg = palette.dangerSoft;
        border = scheme.error;
        fg = scheme.error;
      case ArticlePillVariant.alreadyRead:
        bg = palette.line;
        border = palette.line;
        fg = palette.ink3;
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(horizontal: 11),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: dims.fXs,
                letterSpacing: 0.07 * dims.fXs,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
