import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/features/moderation/domain/services/staff_gate.dart';

/// Envoltura de bloc sobre `StaffGate` para que las pantallas lean el
/// resultado del estado en vez de guardarlo en un `setState` propio.
class StaffCubit extends Cubit<bool> {
  StaffCubit(this._staffGate) : super(false);

  final StaffGate _staffGate;

  Future<void> check() async {
    final isStaff = await _staffGate.isStaff;
    emit(isStaff);
  }
}
