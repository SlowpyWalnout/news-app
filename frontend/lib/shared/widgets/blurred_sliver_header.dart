import 'dart:ui';

import 'package:flutter/material.dart';

import '../../config/theme/app_palette.dart';

/// The frosted-glass `SliverAppBar` shared by Feed and "Mis artículos":
/// blurred background, no title of its own, and a bottom strip with a
/// hairline border that holds the screen's real header content.
class BlurredSliverHeader extends StatelessWidget {
  const BlurredSliverHeader({super.key, required this.preferredHeight, required this.child});

  final double preferredHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SliverAppBar(
      pinned: false,
      floating: true,
      snap: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.82),
      surfaceTintColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: const SizedBox.expand(),
        ),
      ),
      automaticallyImplyLeading: false,
      toolbarHeight: 0,
      titleSpacing: 0,
      title: const SizedBox.shrink(),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(preferredHeight),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: palette.line, width: 1.5))),
          child: child,
        ),
      ),
    );
  }
}
