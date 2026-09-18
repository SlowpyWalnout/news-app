import 'package:flutter/material.dart';

import '../../config/theme/app_dimensions.dart';
import '../../config/theme/app_palette.dart';

/// Full-width outlined row used for Profile/Settings entries: a leading
/// icon + label, and either a trailing widget (e.g. an arrow, for
/// navigation rows) or a trailing value string (for toggle rows).
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.label,
    required this.onTap,
    this.leading,
    this.trailing,
    this.trailingText,
    this.isDestructive = false,
    this.toggled,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? leading;
  final Widget? trailing;
  final String? trailingText;
  final bool isDestructive;
  // Non-null only for rows that are actually on/off toggles (theme,
  // accessible mode) — announced via Semantics.toggled so a screen reader
  // hears "on"/"off", not just the raw trailing text.
  final bool? toggled;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final color = isDestructive ? scheme.error : scheme.onSurface;

    return Semantics(
      toggled: toggled,
      child: SizedBox(
        width: double.infinity,
        height: dims.tap,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: scheme.surface,
            foregroundColor: color,
            side: BorderSide(color: isDestructive ? scheme.error : palette.line, width: isDestructive ? 2.5 : dims.borderWidth),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leading != null) ...[
                      ExcludeSemantics(child: Icon(leading, size: 18, color: color)),
                      const SizedBox(width: 12),
                    ],
                    Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w700, fontSize: dims.fMd))),
                  ],
                ),
              ),
              if (trailingText != null)
                Text(trailingText!, style: TextStyle(fontWeight: FontWeight.w500, color: palette.ink2))
              else if (trailing != null)
                ExcludeSemantics(child: trailing!),
            ],
          ),
        ),
      ),
    );
  }
}
