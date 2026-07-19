import 'package:elct/l10n/app_localizations.dart';

String userErrorMessage(Object error, AppLocalizations l10n) {
  if (error is StateError) {
    switch (error.message) {
      case 'OUT_OF_STOCK':
        return l10n.outOfStock;
      case 'INSUFFICIENT_STOCK':
        return l10n.insufficientStock;
      case 'PRODUCT_NOT_FOUND':
      case 'NO_USER':
      case 'USER_NULL':
        return l10n.loadError;
      case 'USER_NOT_FOUND':
      case 'INVALID_EMAIL':
        return l10n.invalidEmail;
      case 'INVALID_CREDENTIALS':
        return l10n.invalidCredentials;
      case 'WRONG_PASSWORD':
        return l10n.wrongPassword;
      case 'TOO_MANY_ATTEMPTS':
        return l10n.tooManyAttempts;
      case 'EMAIL_ALREADY_IN_USE':
        return l10n.emailInUse;
      case 'WEAK_PASSWORD':
        return l10n.weakPasswordMessage;
      case 'NETWORK_ERROR':
        return l10n.networkError;
      case 'REQUIRES_RECENT_LOGIN':
        return l10n.changeEmailPasswordRequiresReLogin;
      case 'INVALID_PHONE':
        return l10n.phoneInvalid;
      case 'INVALID_OTP':
        return l10n.otpInvalid;
      case 'SMS_QUOTA_EXCEEDED':
        return l10n.tooManyAttempts;
      case 'OTP_EXPIRED':
        return l10n.unexpectedError;
      case 'GOOGLE_SIGN_IN_CANCELLED':
        return l10n.googleSignInCancelled;
      case 'GOOGLE_SIGN_IN_FAILED':
        return l10n.unexpectedError;
      case 'APP_NOT_AUTHORIZED':
      case 'MISSING_CLIENT_IDENTIFIER':
      case 'INTERNAL_ERROR':
      case 'UNKNOWN_ERROR':
      case 'UNKNOWN':
        return l10n.unexpectedError;
      case 'PLEASE_USE_GOOGLE_SIGN_IN':
        return l10n.googleSignInRequired;
      case 'NO_EMAIL':
        return l10n.noUserLoggedIn;
    }
    return '${l10n.loadError} [${error.message}]';
  }

  final msg = error.toString();
  if (msg.contains('promoNotFound') || msg.contains('promoExpiredOrUsed') || msg.contains('promoInvalid')) {
    return l10n.invalidCoupon;
  }
  
  if (msg.contains('Exception: ')) {
    return msg.replaceFirst('Exception: ', '');
  }

  return '${l10n.unexpectedError} [${error.toString()}]';
}
