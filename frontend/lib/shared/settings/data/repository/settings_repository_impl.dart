import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/theme/app_colors.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/repository/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _themeModeKey = 'settings.themeMode';
  static const _localeKey = 'settings.locale';
  static const _accentKey = 'settings.accent';
  static const _accessibleKey = 'settings.accessible';

  @override
  Future<AppSettingsEntity> load() async {
    final initial = AppSettingsEntity.initial;
    final themeModeName = _prefs.getString(_themeModeKey);
    final localeCode = _prefs.getString(_localeKey);
    final accentName = _prefs.getString(_accentKey);
    final accessible = _prefs.getBool(_accessibleKey);

    return AppSettingsEntity(
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == themeModeName,
        orElse: () => initial.themeMode,
      ),
      locale: localeCode != null ? Locale(localeCode) : initial.locale,
      accent: AppAccent.values.firstWhere(
        (a) => a.name == accentName,
        orElse: () => initial.accent,
      ),
      accessible: accessible ?? initial.accessible,
    );
  }

  @override
  Future<void> save(AppSettingsEntity settings) async {
    await _prefs.setString(_themeModeKey, settings.themeMode.name);
    await _prefs.setString(_localeKey, settings.locale.languageCode);
    await _prefs.setString(_accentKey, settings.accent.name);
    await _prefs.setBool(_accessibleKey, settings.accessible);
  }
}
