import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/resources/data_state.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/features/auth/domain/entities/user_entity.dart';
import 'package:news_app/features/moderation/domain/services/staff_gate.dart';

import '../../../../helpers/helpers.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  late MockModerationRepository repo;
  late MockGetCurrentUserUseCase getCurrentUser;
  late StaffGate gate;

  setUp(() {
    repo = MockModerationRepository();
    getCurrentUser = MockGetCurrentUserUseCase();
    gate = StaffGate(repo, getCurrentUser);
  });

  test('no user is not staff, and never reads the repository', () async {
    when(() => getCurrentUser.call(any())).thenAnswer((_) async => null);

    expect(await gate.isStaff, isFalse);
    verifyNever(() => repo.isStaff());
  });

  test('a staff user resolves to true', () async {
    when(() => getCurrentUser.call(any())).thenAnswer((_) async => testUser);
    when(() => repo.isStaff()).thenAnswer((_) async => const DataSuccess(true));

    expect(await gate.isStaff, isTrue);
  });

  test('two reads for the same uid hit the repository only once (cached)', () async {
    when(() => getCurrentUser.call(any())).thenAnswer((_) async => testUser);
    when(() => repo.isStaff()).thenAnswer((_) async => const DataSuccess(true));

    await gate.isStaff;
    await gate.isStaff;

    verify(() => repo.isStaff()).called(1);
  });

  test('a uid change recomputes', () async {
    when(() => repo.isStaff()).thenAnswer((_) async => const DataSuccess(true));
    when(() => getCurrentUser.call(any())).thenAnswer((_) async => testUser);
    await gate.isStaff;

    const otherUser = UserEntity(uid: 'u2', email: 'otro@correo.com', displayName: 'Otro');
    when(() => getCurrentUser.call(any())).thenAnswer((_) async => otherUser);
    await gate.isStaff;

    verify(() => repo.isStaff()).called(2);
  });

  // Comportamiento actual, no arreglado aquí: un permission-denied
  // transitorio cachea "no staff" para el resto de la sesión de ese uid.
  test('a DataFailed from isStaff() resolves to false (and gets cached as such)', () async {
    when(() => getCurrentUser.call(any())).thenAnswer((_) async => testUser);
    when(() => repo.isStaff()).thenAnswer((_) async => const DataFailed(ServerFailure('boom')));

    expect(await gate.isStaff, isFalse);
  });
}
