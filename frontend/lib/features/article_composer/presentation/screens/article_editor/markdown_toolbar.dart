import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../config/theme/app_dimensions.dart';
import '../../../../../config/theme/app_palette.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/widgets/edge_fade_scroll.dart';
import 'markdown_editing.dart';

/// Formatting toolbar above the article body field: bold, italic, H2, H3,
/// quote and bullet. Applies the pure text transforms from
/// markdown_editing.dart directly to [controller], then reports the new
/// text via [onChanged] so the bloc stays the single source of truth.
class MarkdownToolbar extends StatelessWidget {
  const MarkdownToolbar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  void _apply(TextEditingValue Function(TextEditingValue) transform) {
    focusNode.requestFocus();
    final next = transform(controller.value);
    controller.value = next;
    onChanged(next.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final palette = context.palette;

    final buttonSize = math.max(kMinInteractiveDimension, dims.tap * 0.7);
    return SizedBox(
      height: buttonSize,
      child: EdgeFadeScroll(
        children: [
          _ToolbarButton(
            icon: Icons.format_bold,
            tooltip: l10n.markdownBold,
            onPressed: () => _apply((v) => applyInlineMarker(v, '**', placeholder: l10n.markdownPlaceholder)),
            dims: dims,
            palette: palette,
          ),
          _ToolbarButton(
            icon: Icons.format_italic,
            tooltip: l10n.markdownItalic,
            onPressed: () => _apply((v) => applyInlineMarker(v, '*', placeholder: l10n.markdownPlaceholder)),
            dims: dims,
            palette: palette,
          ),
          _ToolbarButton(
            label: 'H2',
            tooltip: l10n.markdownHeading2,
            onPressed: () => _apply((v) => applyLinePrefix(v, '## ')),
            dims: dims,
            palette: palette,
          ),
          _ToolbarButton(
            label: 'H3',
            tooltip: l10n.markdownHeading3,
            onPressed: () => _apply((v) => applyLinePrefix(v, '### ')),
            dims: dims,
            palette: palette,
          ),
          _ToolbarButton(
            icon: Icons.format_quote,
            tooltip: l10n.markdownQuote,
            onPressed: () => _apply((v) => applyLinePrefix(v, '> ')),
            dims: dims,
            palette: palette,
          ),
          _ToolbarButton(
            icon: Icons.format_list_bulleted,
            tooltip: l10n.markdownBullet,
            onPressed: () => _apply((v) => applyLinePrefix(v, '- ')),
            dims: dims,
            palette: palette,
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    this.icon,
    this.label,
    required this.tooltip,
    required this.onPressed,
    required this.dims,
    required this.palette,
  });

  final IconData? icon;
  final String? label;
  final String tooltip;
  final VoidCallback onPressed;
  final AppDimensions dims;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final buttonSize = math.max(kMinInteractiveDimension, dims.tap * 0.7);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.r11),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadii.r11),
            onTap: onPressed,
            child: Container(
              width: buttonSize,
              height: buttonSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.r11),
                border: Border.all(color: palette.edge, width: dims.borderWidth),
              ),
              child: icon != null
                  ? Icon(icon, size: dims.fMd, color: onSurface)
                  : Text(
                      label!,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: dims.fSm, color: onSurface),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
