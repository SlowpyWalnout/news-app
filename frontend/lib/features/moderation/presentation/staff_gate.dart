import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/features/moderation/domain/repository/moderation_repository.dart';

/// Resuelve si el usuario actual es staff y cachea el resultado por uid
/// (una lectura de `users/{uid}.role` por sesión de ese uid, no por widget).
/// Recalcula solo cuando el uid autenticado cambia.
class StaffGate {
  final ModerationRepository _repository;
  final fb_auth.FirebaseAuth _auth;

  StaffGate(this._repository, this._auth);

  String? _cachedUid;
  bool _cachedValue = false;

  Future<bool> get isStaff async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    if (uid == _cachedUid) return _cachedValue;

    final result = await _repository.isStaff();
    _cachedValue = result is DataSuccess<bool> && result.data == true;
    _cachedUid = uid;
    return _cachedValue;
  }
}
