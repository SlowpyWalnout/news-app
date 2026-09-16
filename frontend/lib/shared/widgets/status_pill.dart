import 'package:flutter/material.dart';

import '../../config/theme/app_dimensions.dart';
import '../../config/theme/app_palette.dart';

/// Draft/published pill for "Mis artículos" cards.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.published});

  final String label;
  final bool published;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;

    final Color bg = published ? scheme.primary : palette.warnSoft;
    final Color border = published ? scheme.primary : palette.warn;
    final Color fg = published ? scheme.onPrimary : palette.warn;

    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(horizontal: 11),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
          letterSpacing: 0.07 * 11.5,
          color: fg,
        ),
      ),
    );
  }
}
