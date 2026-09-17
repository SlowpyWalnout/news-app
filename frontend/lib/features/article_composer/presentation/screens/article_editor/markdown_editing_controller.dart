import 'package:flutter/material.dart';

import '../../../../../config/theme/app_dimensions.dart';
import '../../../../../config/theme/app_palette.dart';
import '../../../../../shared/utils/markdown.dart';

/// Text controller for the article body field that paints Markdown syntax
/// as it's typed — headings large, bold/italic styled, and the `**`/`##`/`>`
/// markers themselves dimmed — instead of showing raw syntax the way a plain
/// `TextEditingController` would. Nothing is hidden: hiding characters would
/// desync the text field's cursor math from what's drawn on screen.
class MarkdownEditingController extends TextEditingController {
  MarkdownEditingController({super.text});

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    if (withComposing && value.isComposingRangeValid) {
      // Let the IME own composition styling (pinyin/kana underlines, etc.) —
      // overriding it here would fight the platform's own composing UI.
      return super.buildTextSpan(context: context, style: style, withComposing: withComposing);
    }

    final dims = Theme.of(context).extension<AppDimensions>()!;
    final palette = context.palette;
    final base = style ?? const TextStyle();

    return TextSpan(
      style: base,
      children: [
        for (final token in tokenizeForEditing(text))
          TextSpan(text: token.text, style: _styleFor(token, base, dims, palette)),
      ],
    );
  }

  TextStyle _styleFor(MarkdownEditToken token, TextStyle base, AppDimensions dims, AppPalette palette) {
    var style = switch (token.blockType) {
      MarkdownBlockType.heading2 => base.copyWith(
          fontFamily: 'Space Grotesk',
          fontWeight: FontWeight.w600,
          fontSize: dims.fLg,
        ),
      MarkdownBlockType.heading3 => base.copyWith(fontWeight: FontWeight.w700, fontSize: dims.fMd),
      MarkdownBlockType.quote => base.copyWith(fontStyle: FontStyle.italic, color: palette.ink2),
      MarkdownBlockType.bullet || MarkdownBlockType.paragraph => base,
    };

    if (token.isMarker) return style.copyWith(color: palette.ink3);
    if (token.bold) style = style.copyWith(fontWeight: FontWeight.w700);
    if (token.italic) style = style.copyWith(fontStyle: FontStyle.italic);
    return style;
  }
}
