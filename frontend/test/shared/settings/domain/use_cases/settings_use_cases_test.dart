import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/shared/settings/domain/use_cases/load_settings_use_case.dart';
import 'package:news_app/shared/settings/domain/use_cases/save_settings_use_case.dart';

import '../../../../helpers/helpers.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  late MockSettingsRepository repo;

  setUp(() {
    repo = MockSettingsRepository();
  });

  test('LoadSettingsUseCase delegates to the repository', () async {
    when(() => repo.load()).thenAnswer((_) async => settings());

    final result = await LoadSettingsUseCase(repo)(const NoParams());

    expect(result, settings());
    verify(() => repo.load()).called(1);
  });

  test('SaveSettingsUseCase delegates to the repository', () async {
    when(() => repo.save(any())).thenAnswer((_) async {});
    final toSave = settings();

    await SaveSettingsUseCase(repo)(toSave);

    verify(() => repo.save(toSave)).called(1);
  });
}
