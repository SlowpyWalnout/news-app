import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/config/theme/app_colors.dart';
import 'package:news_app/shared/settings/data/repository/settings_repository_impl.dart';
import 'package:news_app/shared/settings/domain/entities/app_settings_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('load() returns AppSettingsEntity.initial when nothing is stored', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = SettingsRepositoryImpl(await SharedPreferences.getInstance());

    expect(await repo.load(), AppSettingsEntity.initial);
  });

  test('load() falls back to the initial value for a garbage stored themeMode/accent', () async {
    SharedPreferences.setMockInitialValues({
      'settings.themeMode': 'not-a-real-mode',
      'settings.accent': 'not-a-real-accent',
    });
    final repo = SettingsRepositoryImpl(await SharedPreferences.getInstance());

    final loaded = await repo.load();

    expect(loaded.themeMode, AppSettingsEntity.initial.themeMode);
    expect(loaded.accent, AppSettingsEntity.initial.accent);
  });

  test('save() then load() round-trips every field', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = SettingsRepositoryImpl(await SharedPreferences.getInstance());
    const settings = AppSettingsEntity(
      themeMode: ThemeMode.dark,
      locale: Locale('en'),
      accent: AppAccent.violet,
      accessible: true,
    );

    await repo.save(settings);
    final loaded = await repo.load();

    expect(loaded, settings);
  });
}
