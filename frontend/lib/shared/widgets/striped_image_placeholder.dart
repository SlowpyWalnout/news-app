import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Diagonal-stripe placeholder used behind article thumbnails/heroes when
/// there is no [imageUrl], reproducing the prototype's photo stand-in.
/// When [imageUrl] is set, it is rendered instead (still with [child]
/// composited on top, e.g. a category pill or scrim).
class StripedImagePlaceholder extends StatelessWidget {
  const StripedImagePlaceholder({
    super.key,
    this.imageUrl,
    this.child,
    this.borderRadius,
    this.stripeWidth = 14,
    this.semanticLabel,
  });

  final String? imageUrl;
  final Widget? child;
  final BorderRadius? borderRadius;
  final double stripeWidth;
  // Callers that already show the article title as visible text nearby
  // leave this null — the image is then purely decorative and excluded
  // from the accessibility tree instead of forcing a redundant label.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;
    final image = ClipRRect(
      borderRadius: radius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null && imageUrl!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _Stripes(stripeWidth: stripeWidth),
              placeholder: (_, __) => _Stripes(stripeWidth: stripeWidth),
            )
          else
            _Stripes(stripeWidth: stripeWidth),
          if (child != null) child!,
        ],
      ),
    );
    if (semanticLabel != null) {
      return Semantics(image: true, label: semanticLabel, child: image);
    }
    return ExcludeSemantics(child: image);
  }
}

class _Stripes extends StatelessWidget {
  const _Stripes({required this.stripeWidth});

  final double stripeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StripePainter(stripeWidth: stripeWidth),
      child: const SizedBox.expand(),
    );
  }
}

class _StripePainter extends CustomPainter {
  _StripePainter({required this.stripeWidth});

  final double stripeWidth;

  static const _colorA = Color(0xFF8E8B82);
  static const _colorB = Color(0xFF7B786F);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _colorA);
    final diag = size.width + size.height;
    final period = stripeWidth * 2;
    final count = (diag / period).ceil() + 2;
    canvas.save();
    canvas.translate(-size.height, 0);
    canvas.rotate(118 * math.pi / 180 - math.pi / 2);
    final paintB = Paint()..color = _colorB;
    for (var i = -count; i < count; i++) {
      final x = i * period;
      canvas.drawRect(Rect.fromLTWH(x, -diag, stripeWidth, diag * 2), paintB);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StripePainter oldDelegate) => oldDelegate.stripeWidth != stripeWidth;
}
