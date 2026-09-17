import 'package:flutter/material.dart';

/// Horizontal scroller that fades an edge only while there's more content
/// to reveal past it — no fade at rest if everything already fits, no fade
/// on the side already fully scrolled to.
class EdgeFadeScroll extends StatefulWidget {
  const EdgeFadeScroll({super.key, required this.children, this.fadeWidth = 24});

  final List<Widget> children;
  final double fadeWidth;

  @override
  State<EdgeFadeScroll> createState() => _EdgeFadeScrollState();
}

class _EdgeFadeScrollState extends State<EdgeFadeScroll> {
  final _controller = ScrollController();
  bool _showLeftFade = false;
  bool _showRightFade = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateFades);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFades());
  }

  @override
  void dispose() {
    _controller.removeListener(_updateFades);
    _controller.dispose();
    super.dispose();
  }

  void _updateFades() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final showLeft = position.pixels > position.minScrollExtent + 1;
    final showRight = position.pixels < position.maxScrollExtent - 1;
    if (showLeft != _showLeftFade || showRight != _showRightFade) {
      setState(() {
        _showLeftFade = showLeft;
        _showRightFade = showRight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fadeFraction = constraints.maxWidth == 0
            ? 0.0
            : (widget.fadeWidth / constraints.maxWidth).clamp(0.0, 0.5);
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [
              Colors.transparent,
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: [
              0.0,
              _showLeftFade ? fadeFraction : 0.0,
              _showRightFade ? 1.0 - fadeFraction : 1.0,
              1.0,
            ],
          ).createShader(bounds),
          blendMode: BlendMode.dstIn,
          child: NotificationListener<ScrollMetricsNotification>(
            onNotification: (_) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _updateFades());
              return false;
            },
            child: ListView(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              children: widget.children,
            ),
          ),
        );
      },
    );
  }
}
