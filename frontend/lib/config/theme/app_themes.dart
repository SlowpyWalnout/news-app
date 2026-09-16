import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_palette.dart';

/// Builds a [ThemeData] for the given brightness/accent/accessibility
/// combination, from the tokens converted in [AppColors].
ThemeData appTheme({
  required Brightness brightness,
  required AppAccent accent,
  required bool accessible,
}) {
  final isDark = brightness == Brightness.dark;
  final a = AppColors.accentSet(accent, brightness);

  final ink = isDark ? AppColors.inkDark : AppColors.inkLight;
  final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
  final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
  final ink2 = accessible ? ink : (isDark ? AppColors.ink2Dark : AppColors.ink2Light);
  final ink3 = isDark ? AppColors.ink3Dark : AppColors.ink3Light;
  final line = isDark ? AppColors.lineDark : AppColors.lineLight;
  final edge = isDark ? AppColors.edgeDark : AppColors.edgeLight;
  final danger = isDark ? AppColors.dangerDark : AppColors.dangerLight;
  final dangerSoft = isDark ? AppColors.dangerSoftDark : AppColors.dangerSoftLight;
  final ok = isDark ? AppColors.okDark : AppColors.okLight;
  final warn = isDark ? AppColors.warnDark : AppColors.warnLight;
  final warnSoft = isDark ? AppColors.warnSoftDark : AppColors.warnSoftLight;
  final glass = isDark ? AppColors.glassDark : AppColors.glassLight;
  final scrim = isDark ? AppColors.stageDark : AppColors.stageLight;
  final shadow = isDark ? Colors.black.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.10);

  final dims = accessible ? AppDimensions.accessible : AppDimensions.standard;

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: a.accent,
    onPrimary: a.onAccent,
    secondary: a.accentInk,
    onSecondary: bg,
    error: danger,
    onError: bg,
    surface: surface,
    onSurface: ink,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: bg,
    colorScheme: colorScheme,
    fontFamily: 'Figtree',
    textTheme: TextTheme(
      headlineLarge: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w600, color: ink),
      headlineMedium: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w600, color: ink),
      titleLarge: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w600, color: ink),
      bodyMedium: TextStyle(fontFamily: 'Figtree', color: ink),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: ink),
      titleTextStyle: TextStyle(
        fontFamily: 'Space Grotesk',
        fontWeight: FontWeight.w600,
        fontSize: dims.fMd,
        color: ink,
      ),
    ),
    extensions: [
      dims,
      AppPalette(
        ink2: ink2,
        ink3: ink3,
        line: line,
        edge: edge,
        accentInk: a.accentInk,
        accentSoft: a.accentSoft,
        ok: ok,
        warn: warn,
        warnSoft: warnSoft,
        dangerSoft: dangerSoft,
        glass: glass,
        scrim: scrim,
        shadow: shadow,
      ),
    ],
  );
}
