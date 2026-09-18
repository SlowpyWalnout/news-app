import 'package:flutter/material.dart';

import 'skeleton_block.dart';

/// A ladder of [count] `SkeletonBlock`s, each one 200ms further behind the
/// last, spaced by [gap]. Shared shape of the loading state across Feed,
/// "Mis artículos", "Leer después" and the review queue — they only differ
/// in block height/radius.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    required this.heights,
    this.borderRadius = 20,
    this.gap = 12,
  });

  final List<double> heights;
  final double borderRadius;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < heights.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          SkeletonBlock(
            height: heights[i],
            borderRadius: borderRadius,
            delay: Duration(milliseconds: 200 * i),
          ),
        ],
      ],
    );
  }
}
