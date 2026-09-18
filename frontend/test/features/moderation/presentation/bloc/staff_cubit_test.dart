import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/features/moderation/presentation/bloc/staff_cubit.dart';

import '../../../../helpers/helpers.dart';

void main() {
  test('starts as false and emits true when the gate resolves staff', () async {
    final gate = MockStaffGate();
    when(() => gate.isStaff).thenAnswer((_) async => true);
    final cubit = StaffCubit(gate);
    expect(cubit.state, isFalse);

    await cubit.check();

    expect(cubit.state, isTrue);
  });

  test('emits false when the gate resolves not staff', () async {
    final gate = MockStaffGate();
    when(() => gate.isStaff).thenAnswer((_) async => false);
    final cubit = StaffCubit(gate);

    await cubit.check();

    expect(cubit.state, isFalse);
  });
}
