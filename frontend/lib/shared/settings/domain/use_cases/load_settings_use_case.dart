import '../../../../core/usecase/usecase.dart';
import '../entities/app_settings_entity.dart';
import '../repository/settings_repository.dart';

class LoadSettingsUseCase implements UseCase<AppSettingsEntity, NoParams> {
  const LoadSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  @override
  Future<AppSettingsEntity> call(NoParams params) => _repository.load();
}
