import 'package:flutter/material.dart';

import '../../config/theme/app_dimensions.dart';
import '../../config/theme/app_palette.dart';

/// Back button + centered title bar shared by every secondary screen
/// (Settings, legal documents, article editor, article detail, review
/// queue) — a bordered strip with a `BackButton`, an optional title
/// centered in the app's Space Grotesk/w600/fMd style, and either a
/// trailing widget or a same-width `SizedBox` so the title stays centered
/// either way. A real `AppBar` isn't used here: this app's screens draw
/// their own header strip inside the body (see `feed_screen.dart`'s
/// `SliverAppBar`) rather than relying on Material's default app bar.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, this.title, this.trailing});

  final String? title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final dims = Theme.of(context).extension<AppDimensions>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: palette.line, width: 1.5))),
      child: Row(
        children: [
          BackButton(onPressed: () => Navigator.of(context).maybePop()),
          Expanded(
            child: title == null
                ? const SizedBox.shrink()
                : Text(
                    title!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w600, fontSize: dims.fMd),
                  ),
          ),
          trailing ?? const SizedBox(width: 48),
        ],
      ),
    );
  }
}
