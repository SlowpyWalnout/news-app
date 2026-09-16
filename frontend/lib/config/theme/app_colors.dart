import 'package:flutter/material.dart';

/// Accent variants available from the Perfil screen, mirroring the
/// prototype's `data-accent` values.
enum AppAccent { lime, violet, cyan }

/// Raw sRGB values converted once (offline) from the prototype's oklch
/// design tokens. Values that are identical between light/dark or across
/// accents in the source are only listed once.
class AppColors {
  AppColors._();

  // Neutral surfaces — light
  static const stageLight = Color(0xFFF1F0ED);
  static const bgLight = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surface2Light = Color(0xFFF4F3F1);
  static const inkLight = Color(0xFF0B0A07);
  static const ink2Light = Color(0xFF494843);
  static const ink3Light = Color(0xFF71706C);
  static const lineLight = Color(0xFFDFDEDB);
  static const edgeLight = Color(0xFF0B0A07);
  static const glassLight = Color(0x29FFFFFF);
  static const dangerLight = Color(0xFFC5000F);
  static const dangerSoftLight = Color(0xFFFFEDEA);
  static const okLight = Color(0xFF006B30);
  static const warnLight = Color(0xFF7E4F04);
  static const warnSoftLight = Color(0xFFFFEFCD);

  // Neutral surfaces — dark
  static const stageDark = Color(0xFF050403);
  static const bgDark = Color(0xFF0B0A07);
  static const surfaceDark = Color(0xFF141310);
  static const surface2Dark = Color(0xFF1F1E1A);
  static const inkDark = Color(0xFFF9F8F7);
  static const ink2Dark = Color(0xFFC0BFBC);
  static const ink3Dark = Color(0xFF8F8D8A);
  static const lineDark = Color(0xFF2D2B27);
  static const edgeDark = Color(0xFFF9F8F7);
  static const glassDark = Color(0x21F9F8F7);
  static const dangerDark = Color(0xFFFF6760);
  static const dangerSoftDark = Color(0xFF411512);
  static const okDark = Color(0xFF6BE592);
  static const warnDark = Color(0xFFF1BF5B);
  static const warnSoftDark = Color(0xFF352300);

  // Accent — lime (default)
  static const accentLime = Color(0xFFB2EB2C);
  static const onAccentLime = Color(0xFF091000);
  static const accentInkLimeLight = Color(0xFF3A5C00);
  static const accentSoftLimeLight = Color(0xFFE6F8CD);
  static const accentSoftLimeDark = Color(0xFF1E2C00);

  // Accent — violet
  static const accentVioletLight = Color(0xFF9953FF);
  static const accentVioletDark = Color(0xFFAE78FF);
  static const onAccentViolet = Color(0xFFFCFBFF);
  static const accentInkVioletLight = Color(0xFF7334CF);
  static const accentSoftVioletLight = Color(0xFFF2EBFF);
  static const accentSoftVioletDark = Color(0xFF2E1C4F);

  // Accent — cyan
  static const accentCyan = Color(0xFF00D8EB);
  static const onAccentCyan = Color(0xFF001418);
  static const accentInkCyanLight = Color(0xFF006B80);
  static const accentSoftCyanLight = Color(0xFFCEFAFF);
  static const accentSoftCyanDark = Color(0xFF002F36);

  static ({
    Color accent,
    Color onAccent,
    Color accentInk,
    Color accentSoft,
  }) accentSet(AppAccent accent, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    switch (accent) {
      case AppAccent.lime:
        return (
          accent: accentLime,
          onAccent: onAccentLime,
          accentInk: isDark ? accentLime : accentInkLimeLight,
          accentSoft: isDark ? accentSoftLimeDark : accentSoftLimeLight,
        );
      case AppAccent.violet:
        return (
          accent: isDark ? accentVioletDark : accentVioletLight,
          onAccent: onAccentViolet,
          accentInk: isDark ? accentVioletDark : accentInkVioletLight,
          accentSoft: isDark ? accentSoftVioletDark : accentSoftVioletLight,
        );
      case AppAccent.cyan:
        return (
          accent: accentCyan,
          onAccent: onAccentCyan,
          accentInk: isDark ? accentCyan : accentInkCyanLight,
          accentSoft: isDark ? accentSoftCyanDark : accentSoftCyanLight,
        );
    }
  }
}
