import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/shared/data/mappers/firebase_failure_mapper.dart';

void main() {
  group('mapFirebaseAuthExceptionToFailure', () {
    test('network-request-failed produce FailureCode.network', () {
      final failure = mapFirebaseAuthExceptionToFailure(
        FirebaseAuthException(code: 'network-request-failed'),
      );
      expect(failure.code, FailureCode.network);
    });

    test('wrong-password produce FailureCode.invalidCredentials', () {
      final failure = mapFirebaseAuthExceptionToFailure(
        FirebaseAuthException(code: 'wrong-password'),
      );
      expect(failure.code, FailureCode.invalidCredentials);
    });

    test('email-already-in-use produce FailureCode.emailAlreadyInUse', () {
      final failure = mapFirebaseAuthExceptionToFailure(
        FirebaseAuthException(code: 'email-already-in-use'),
      );
      expect(failure.code, FailureCode.emailAlreadyInUse);
    });

    test('weak-password produce FailureCode.weakPassword', () {
      final failure = mapFirebaseAuthExceptionToFailure(
        FirebaseAuthException(code: 'weak-password'),
      );
      expect(failure.code, FailureCode.weakPassword);
    });

    test('código desconocido produce FailureCode.unknown, no invalidCredentials', () {
      final failure = mapFirebaseAuthExceptionToFailure(
        FirebaseAuthException(code: 'too-many-requests'),
      );
      expect(failure.code, FailureCode.unknown);
    });
  });

  group('mapFirebaseExceptionToFailure', () {
    test('unavailable produce FailureCode.network', () {
      final failure = mapFirebaseExceptionToFailure(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );
      expect(failure.code, FailureCode.network);
    });

    test('plugin firebase_storage produce FailureCode.storage', () {
      final failure = mapFirebaseExceptionToFailure(
        FirebaseException(plugin: 'firebase_storage', code: 'object-not-found'),
      );
      expect(failure.code, FailureCode.storage);
    });

    test('cualquier otro caso produce FailureCode.server', () {
      final failure = mapFirebaseExceptionToFailure(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );
      expect(failure.code, FailureCode.server);
    });
  });
}
