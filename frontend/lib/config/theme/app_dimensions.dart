import 'package:flutter/material.dart';

/// Font sizes, minimum tap target and border width — mirrors the
/// prototype's `--f-*`, `--tap` and `--bw` custom properties, with a
/// second, larger set for accessible mode.
class AppDimensions extends ThemeExtension<AppDimensions> {
  const AppDimensions({
    required this.fXs,
    required this.fSm,
    required this.fMd,
    required this.fLg,
    required this.fH,
    required this.fHero,
    required this.tap,
    required this.borderWidth,
  });

  final double fXs;
  final double fSm;
  final double fMd;
  final double fLg;
  final double fH;
  final double fHero;
  final double tap;
  final double borderWidth;

  static const standard = AppDimensions(
    fXs: 13,
    fSm: 15,
    fMd: 17.5,
    fLg: 20,
    fH: 28,
    fHero: 36,
    tap: 56,
    borderWidth: 1.5,
  );

  static const accessible = AppDimensions(
    fXs: 15,
    fSm: 17,
    fMd: 20,
    fLg: 23,
    fH: 32,
    fHero: 40,
    tap: 68,
    borderWidth: 2.5,
  );

  @override
  AppDimensions copyWith({
    double? fXs,
    double? fSm,
    double? fMd,
    double? fLg,
    double? fH,
    double? fHero,
    double? tap,
    double? borderWidth,
  }) {
    return AppDimensions(
      fXs: fXs ?? this.fXs,
      fSm: fSm ?? this.fSm,
      fMd: fMd ?? this.fMd,
      fLg: fLg ?? this.fLg,
      fH: fH ?? this.fH,
      fHero: fHero ?? this.fHero,
      tap: tap ?? this.tap,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  @override
  AppDimensions lerp(ThemeExtension<AppDimensions>? other, double t) {
    if (other is! AppDimensions) return this;
    double l(double a, double b) => a + (b - a) * t;
    return AppDimensions(
      fXs: l(fXs, other.fXs),
      fSm: l(fSm, other.fSm),
      fMd: l(fMd, other.fMd),
      fLg: l(fLg, other.fLg),
      fH: l(fH, other.fH),
      fHero: l(fHero, other.fHero),
      tap: l(tap, other.tap),
      borderWidth: l(borderWidth, other.borderWidth),
    );
  }
}

/// Common corner radii used across the design, named for their pixel value
/// since the prototype reuses the same handful everywhere.
class AppRadii {
  AppRadii._();

  static const r9 = 9.0;
  static const r11 = 11.0;
  static const r12 = 12.0;
  static const r13 = 13.0;
  static const r14 = 14.0;
  static const r15 = 15.0;
  static const r16 = 16.0;
  static const r18 = 18.0;
  static const r20 = 20.0;
  static const r22 = 22.0;
  static const r24 = 24.0;
  static const pill = 999.0;
}
