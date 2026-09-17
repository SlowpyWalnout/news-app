import '../../core/resources/failure.dart';
import '../../l10n/app_localizations.dart';

/// Maps a [FailureCode] to a localized, user-facing string. Keeps the
/// mapping out of screens so every flow shows the same wording for the same
/// underlying error instead of leaking raw Firebase/Dio exception text.
///
/// [FailureCode.invalidCredentials]/[FailureCode.emailAlreadyInUse]/
/// [FailureCode.weakPassword] only ever come from auth failures, but it's
/// harmless for non-auth call sites to pass them through this same switch.
String describeFailureCode(AppLocalizations l10n, FailureCode code) {
  switch (code) {
    case FailureCode.network:
      return l10n.authErrorNetwork;
    case FailureCode.invalidCredentials:
      return l10n.loginCredentialError;
    case FailureCode.emailAlreadyInUse:
      return l10n.authErrorEmailInUse;
    case FailureCode.weakPassword:
      return l10n.authErrorWeakPassword;
    case FailureCode.cancelled:
      return '';
    case FailureCode.storage:
    case FailureCode.server:
    case FailureCode.unknown:
      return l10n.authErrorGeneric;
  }
}

String describeFailure(AppLocalizations l10n, Failure failure) => describeFailureCode(l10n, failure.code);
