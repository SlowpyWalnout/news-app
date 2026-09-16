import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

class AppSettingsEntity extends Equatable {
  const AppSettingsEntity({
    required this.themeMode,
    required this.locale,
    required this.accent,
    required this.accessible,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final AppAccent accent;
  final bool accessible;

  static const initial = AppSettingsEntity(
    themeMode: ThemeMode.system,
    locale: Locale('es'),
    accent: AppAccent.lime,
    accessible: false,
  );

  AppSettingsEntity copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    AppAccent? accent,
    bool? accessible,
  }) {
    return AppSettingsEntity(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      accent: accent ?? this.accent,
      accessible: accessible ?? this.accessible,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale, accent, accessible];
}
