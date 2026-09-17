import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/resources/failure.dart';
import 'package:news_app/l10n/app_localizations_es.dart';
import 'package:news_app/shared/presentation/failure_localizer.dart';

void main() {
  final l10n = AppLocalizationsEs();

  group('describeFailureCode', () {
    test('network y invalidCredentials producen textos distintos', () {
      final network = describeFailureCode(l10n, FailureCode.network);
      final credentials = describeFailureCode(l10n, FailureCode.invalidCredentials);
      expect(network, isNot(equals(credentials)));
      expect(network, l10n.authErrorNetwork);
      expect(credentials, l10n.loginCredentialError);
    });

    test('cancelled no muestra texto (el usuario solo cerró el picker)', () {
      expect(describeFailureCode(l10n, FailureCode.cancelled), isEmpty);
    });

    test('storage/server/unknown caen al mensaje genérico', () {
      expect(describeFailureCode(l10n, FailureCode.storage), l10n.authErrorGeneric);
      expect(describeFailureCode(l10n, FailureCode.server), l10n.authErrorGeneric);
      expect(describeFailureCode(l10n, FailureCode.unknown), l10n.authErrorGeneric);
    });
  });

  group('describeFailure', () {
    test('usa el code del Failure, no su message crudo', () {
      const failure = NetworkFailure('raw english firebase message');
      final message = describeFailure(l10n, failure);
      expect(message, l10n.authErrorNetwork);
      expect(message, isNot(contains('raw english')));
    });
  });
}
