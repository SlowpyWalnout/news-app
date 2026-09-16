import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/use_cases/load_settings_use_case.dart';
import '../../domain/use_cases/save_settings_use_case.dart';

class SettingsCubit extends Cubit<AppSettingsEntity> {
  SettingsCubit(this._loadSettingsUseCase, this._saveSettingsUseCase)
      : super(AppSettingsEntity.initial) {
    _loadSettings();
  }

  final LoadSettingsUseCase _loadSettingsUseCase;
  final SaveSettingsUseCase _saveSettingsUseCase;

  Future<void> _loadSettings() async {
    emit(await _loadSettingsUseCase(const NoParams()));
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    emit(state.copyWith(themeMode: themeMode));
    await _saveSettingsUseCase(state);
  }

  Future<void> toggleTheme() {
    final next = state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    return setThemeMode(next);
  }

  Future<void> setLocale(Locale locale) async {
    emit(state.copyWith(locale: locale));
    await _saveSettingsUseCase(state);
  }

  Future<void> toggleLocale() {
    final next = Locale(state.locale.languageCode == 'es' ? 'en' : 'es');
    return setLocale(next);
  }

  Future<void> setAccent(AppAccent accent) async {
    emit(state.copyWith(accent: accent));
    await _saveSettingsUseCase(state);
  }

  Future<void> setAccessible(bool accessible) async {
    emit(state.copyWith(accessible: accessible));
    await _saveSettingsUseCase(state);
  }

  Future<void> toggleAccessible() => setAccessible(!state.accessible);
}
