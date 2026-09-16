import 'package:flutter/material.dart';

/// Bottom-to-transparent gradient overlaid on photos so light text/pills
/// stay legible, matching the prototype's `to top` scrims.
class ScrimOverlay extends StatelessWidget {
  const ScrimOverlay({super.key, this.opacityTop = 0.97, this.opacityBottom = 0.0});

  final double opacityTop;
  final double opacityBottom;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: opacityTop),
            Colors.black.withValues(alpha: opacityBottom),
          ],
        ),
      ),
    );
  }
}

/// Frosted glass pill (category badges, image-label chips).
class GlassPill extends StatelessWidget {
  const GlassPill({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
    this.borderRadius = 999,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: child,
    );
  }
}
