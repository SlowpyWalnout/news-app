import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/config/theme/app_colors.dart';
import 'package:news_app/shared/settings/presentation/cubit/settings_cubit.dart';

import '../../../../helpers/helpers.dart';

// La carga de LoadSettingsUseCase arranca en el constructor. blocTest's
// `build` es sincrónico (no puede esperar esa hidratación antes de correr
// `act`), y un toggle que corre en carrera con ella puede ser sobrescrito
// por el valor cargado llegando después — así que todo este archivo se
// queda en test() crudo con pumpEventQueue() tras construir.
void main() {
  setUpAll(registerCommonFallbacks);

  late MockLoadSettingsUseCase load;
  late MockSaveSettingsUseCase save;

  setUp(() {
    load = MockLoadSettingsUseCase();
    save = MockSaveSettingsUseCase();
    when(() => load.call(any())).thenAnswer((_) async => settings());
    when(() => save.call(any())).thenAnswer((_) async {});
  });

  Future<SettingsCubit> buildSettled() async {
    final cubit = SettingsCubit(load, save);
    await pumpEventQueue();
    return cubit;
  }

  test('hydrates from LoadSettingsUseCase on construction', () async {
    when(() => load.call(any())).thenAnswer((_) async => settings(themeMode: ThemeMode.dark));

    final cubit = await buildSettled();

    expect(cubit.state.themeMode, ThemeMode.dark);
  });

  test('toggleTheme flips light <-> dark and persists', () async {
    final cubit = await buildSettled();

    await cubit.toggleTheme();

    expect(cubit.state.themeMode, ThemeMode.dark);
    verify(() => save.call(any())).called(1);
  });

  test('toggleLocale flips es <-> en', () async {
    final cubit = await buildSettled();

    await cubit.toggleLocale();

    expect(cubit.state.locale.languageCode, 'en');
  });

  test('setAccent updates the accent', () async {
    final cubit = await buildSettled();

    await cubit.setAccent(AppAccent.violet);

    expect(cubit.state.accent, AppAccent.violet);
  });

  test('toggleAccessible flips accessible', () async {
    final cubit = await buildSettled();

    await cubit.toggleAccessible();

    expect(cubit.state.accessible, isTrue);
  });
}
