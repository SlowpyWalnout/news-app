import 'package:flutter/material.dart';

import '../../config/theme/app_dimensions.dart';
import '../../config/theme/app_palette.dart';
import '../utils/markdown.dart';

/// Renders the closed Markdown subset the article editor's toolbar can
/// produce (bold/italic, H2/H3, quote, bullet, paragraphs) using the app's
/// own dimension/palette tokens — so accessible mode and accent themes keep
/// working, the way a third-party renderer's own stylesheet wouldn't.
class MarkdownText extends StatelessWidget {
  const MarkdownText(this.data, {super.key});

  final String data;

  @override
  Widget build(BuildContext context) {
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final palette = context.palette;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final blocks = parseMarkdown(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in blocks)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: _buildBlock(block, dims, palette, onSurface),
          ),
      ],
    );
  }

  Widget _buildBlock(
    MarkdownBlock block,
    AppDimensions dims,
    AppPalette palette,
    Color onSurface,
  ) {
    switch (block.type) {
      case MarkdownBlockType.heading2:
        return _RichSpans(
          block.spans,
          base: TextStyle(
            fontFamily: 'Space Grotesk',
            fontWeight: FontWeight.w600,
            fontSize: dims.fLg,
            color: onSurface,
          ),
        );
      case MarkdownBlockType.heading3:
        return _RichSpans(
          block.spans,
          base: TextStyle(fontWeight: FontWeight.w700, fontSize: dims.fMd, color: onSurface),
        );
      case MarkdownBlockType.quote:
        return Container(
          padding: const EdgeInsets.only(left: 14),
          decoration: BoxDecoration(border: Border(left: BorderSide(color: palette.line, width: 3))),
          child: _RichSpans(
            block.spans,
            base: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: dims.fMd,
              height: 1.68,
              color: palette.ink2,
            ),
          ),
        );
      case MarkdownBlockType.bullet:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 10),
              child: Text('•', style: TextStyle(fontSize: dims.fMd, color: onSurface)),
            ),
            Expanded(
              child: _RichSpans(
                block.spans,
                base: TextStyle(fontSize: dims.fMd, height: 1.68, color: onSurface),
              ),
            ),
          ],
        );
      case MarkdownBlockType.paragraph:
        return _RichSpans(
          block.spans,
          base: TextStyle(fontSize: dims.fMd, height: 1.68, color: onSurface),
        );
    }
  }
}

class _RichSpans extends StatelessWidget {
  const _RichSpans(this.spans, {required this.base});

  final List<MarkdownSpan> spans;
  final TextStyle base;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          for (final span in spans)
            TextSpan(
              text: span.text,
              style: base.copyWith(
                fontWeight: span.bold ? FontWeight.w700 : base.fontWeight,
                fontStyle: span.italic ? FontStyle.italic : base.fontStyle,
              ),
            ),
        ],
      ),
    );
  }
}
