import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/features/auth/data/models/user_model.dart';

import '../../../../helpers/helpers.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  group('fromFirebaseUser', () {
    test('maps every field', () {
      final user = MockFirebaseUser();
      when(() => user.uid).thenReturn('u1');
      when(() => user.email).thenReturn('rosa@correo.com');
      when(() => user.displayName).thenReturn('Rosa');
      when(() => user.photoURL).thenReturn('https://x/y.jpg');

      final model = UserModel.fromFirebaseUser(user);

      expect(model.uid, 'u1');
      expect(model.email, 'rosa@correo.com');
      expect(model.displayName, 'Rosa');
      expect(model.photoURL, 'https://x/y.jpg');
    });

    test('null email/displayName fall back to empty strings', () {
      final user = MockFirebaseUser();
      when(() => user.uid).thenReturn('u1');
      when(() => user.email).thenReturn(null);
      when(() => user.displayName).thenReturn(null);
      when(() => user.photoURL).thenReturn(null);

      final model = UserModel.fromFirebaseUser(user);

      expect(model.email, '');
      expect(model.displayName, '');
      expect(model.photoURL, isNull);
    });
  });

  test('toFirestoreProfile emits exactly displayName/photoURL/createdAt, createdAt is a FieldValue', () {
    const model = UserModel(uid: 'u1', email: 'rosa@correo.com', displayName: 'Rosa', photoURL: 'https://x/y.jpg');

    final map = model.toFirestoreProfile();

    expect(map.keys.toSet(), {'displayName', 'photoURL', 'createdAt'});
    expect(map['displayName'], 'Rosa');
    expect(map['photoURL'], 'https://x/y.jpg');
    expect(map['createdAt'], isA<FieldValue>());
  });
}
