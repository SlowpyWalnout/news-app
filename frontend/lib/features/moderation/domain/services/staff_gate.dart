import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/auth/domain/use_cases/get_current_user_use_case.dart';
import 'package:news_app/features/moderation/domain/repository/moderation_repository.dart';

/// Resuelve si el usuario actual es staff y cachea el resultado por uid
/// (una lectura de `users/{uid}.role` por sesión de ese uid, no por widget).
/// Recalcula solo cuando el uid autenticado cambia.
class StaffGate {
  final ModerationRepository _repository;
  final GetCurrentUserUseCase _getCurrentUser;

  StaffGate(this._repository, this._getCurrentUser);

  String? _cachedUid;
  bool _cachedValue = false;

  Future<bool> get isStaff async {
    final user = await _getCurrentUser.call(const NoParams());
    final uid = user?.uid;
    if (uid == null) return false;
    if (uid == _cachedUid) return _cachedValue;

    final result = await _repository.isStaff();
    _cachedValue = result is DataSuccess<bool> && result.data == true;
    _cachedUid = uid;
    return _cachedValue;
  }
}
