import 'package:flutter/material.dart';

import '../../config/theme/app_palette.dart';

/// The bordered, rounded card container shared by every article row/tile:
/// `CompactArticleCard`, `MyArticleCard` and the "Leer después" tile. Below
/// this shell each one lays out its content differently (pills, actions,
/// thumbnail widget), so only the container itself is shared.
class ArticleCardShell extends StatelessWidget {
  const ArticleCardShell({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: context.palette.line),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
