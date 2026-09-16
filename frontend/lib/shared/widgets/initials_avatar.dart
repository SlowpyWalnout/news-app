import 'package:flutter/material.dart';

/// Circular avatar showing the author's initials on an accent background,
/// used everywhere the design has no real profile photo.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.initials,
    this.size = 46,
    this.fontSize,
    this.glass = false,
  });

  final String initials;
  final double size;
  final double? fontSize;
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: glass ? Colors.white.withValues(alpha: 0.16) : scheme.primary,
        border: glass ? Border.all(color: Colors.white.withValues(alpha: 0.35)) : null,
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: 'Figtree',
          fontWeight: FontWeight.w700,
          fontSize: fontSize ?? size * 0.32,
          color: glass ? Colors.white : scheme.onPrimary,
        ),
      ),
    );
  }
}
