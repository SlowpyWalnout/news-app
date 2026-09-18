import 'package:flutter/material.dart';

import '../../config/theme/app_dimensions.dart';
import '../../config/theme/app_palette.dart';

/// Launches a bottom sheet with the app's standard scrim (transparent,
/// isScrollControlled) — shared by the delete-confirm and report sheets.
Future<T?> showAppBottomSheet<T>(BuildContext context, {required WidgetBuilder builder}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: builder,
  );
}

/// The rounded card chrome anchored to the bottom of the screen: border,
/// safe-area padding, and an optional scrollable body for sheets with a
/// form (like the report sheet) that may not fit above the keyboard.
class AppBottomSheetCard extends StatelessWidget {
  const AppBottomSheetCard({super.key, required this.child, this.scrollable = false});

  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final palette = context.palette;
    final scheme = Theme.of(context).colorScheme;
    final body = SafeArea(top: false, child: scrollable ? SingleChildScrollView(child: child) : child);

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: palette.edge, width: dims.borderWidth),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24), bottom: Radius.circular(24)),
      ),
      child: body,
    );
  }
}

/// Title + body pair used at the top of every sheet.
class SheetHeader extends StatelessWidget {
  const SheetHeader({super.key, required this.title, required this.body, this.spacing = 11});

  final String title;
  final String body;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final dims = Theme.of(context).extension<AppDimensions>()!;
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w600, fontSize: dims.fLg)),
        SizedBox(height: spacing),
        Text(body, style: TextStyle(fontSize: dims.fSm, height: 1.5, color: palette.ink2)),
      ],
    );
  }
}
