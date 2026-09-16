import '../../../../core/usecase/usecase.dart';
import '../entities/app_settings_entity.dart';
import '../repository/settings_repository.dart';

class SaveSettingsUseCase implements UseCase<void, AppSettingsEntity> {
  const SaveSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(AppSettingsEntity params) => _repository.save(params);
}
