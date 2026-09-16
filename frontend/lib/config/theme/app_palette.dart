import 'package:flutter/material.dart';

/// Design tokens that don't map cleanly onto [ColorScheme] — secondary/
/// tertiary text, hairline borders, glass surfaces and the semantic
/// ok/warn colors the prototype uses next to Material's error color.
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.ink2,
    required this.ink3,
    required this.line,
    required this.edge,
    required this.accentInk,
    required this.accentSoft,
    required this.ok,
    required this.warn,
    required this.warnSoft,
    required this.dangerSoft,
    required this.glass,
    required this.scrim,
    required this.shadow,
  });

  final Color ink2;
  final Color ink3;
  final Color line;
  final Color edge;
  final Color accentInk;
  final Color accentSoft;
  final Color ok;
  final Color warn;
  final Color warnSoft;
  final Color dangerSoft;
  final Color glass;
  final Color scrim;
  final Color shadow;

  @override
  AppPalette copyWith({
    Color? ink2,
    Color? ink3,
    Color? line,
    Color? edge,
    Color? accentInk,
    Color? accentSoft,
    Color? ok,
    Color? warn,
    Color? warnSoft,
    Color? dangerSoft,
    Color? glass,
    Color? scrim,
    Color? shadow,
  }) {
    return AppPalette(
      ink2: ink2 ?? this.ink2,
      ink3: ink3 ?? this.ink3,
      line: line ?? this.line,
      edge: edge ?? this.edge,
      accentInk: accentInk ?? this.accentInk,
      accentSoft: accentSoft ?? this.accentSoft,
      ok: ok ?? this.ok,
      warn: warn ?? this.warn,
      warnSoft: warnSoft ?? this.warnSoft,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      glass: glass ?? this.glass,
      scrim: scrim ?? this.scrim,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      ink2: l(ink2, other.ink2),
      ink3: l(ink3, other.ink3),
      line: l(line, other.line),
      edge: l(edge, other.edge),
      accentInk: l(accentInk, other.accentInk),
      accentSoft: l(accentSoft, other.accentSoft),
      ok: l(ok, other.ok),
      warn: l(warn, other.warn),
      warnSoft: l(warnSoft, other.warnSoft),
      dangerSoft: l(dangerSoft, other.dangerSoft),
      glass: l(glass, other.glass),
      scrim: l(scrim, other.scrim),
      shadow: l(shadow, other.shadow),
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
