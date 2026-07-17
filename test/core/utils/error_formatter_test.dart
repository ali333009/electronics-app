import 'package:flutter_test/flutter_test.dart';
import 'package:elct/core/utils/error_formatter.dart';
import 'package:mockito/mockito.dart';
import '../../helpers/mock_localizations_gen.mocks.dart';

final l10n = MockAppLocalizations();

void main() {
  group('userErrorMessage', () {
    setUp(() {
      when(l10n.outOfStock).thenReturn('Out of stock');
      when(l10n.insufficientStock).thenReturn('Insufficient stock');
      when(l10n.loadError).thenReturn('Error loading data');
      when(l10n.invalidCredentials).thenReturn('Invalid credentials');
      when(l10n.wrongPassword).thenReturn('Wrong password');
      when(l10n.tooManyAttempts).thenReturn('Too many attempts');
      when(l10n.emailInUse).thenReturn('Email in use');
      when(l10n.weakPasswordMessage).thenReturn('Weak password');
      when(l10n.networkError).thenReturn('Network error');
      when(l10n.changeEmailPasswordRequiresReLogin).thenReturn('Please re-login');
      when(l10n.googleSignInCancelled).thenReturn('Google sign-in cancelled');
      when(l10n.unexpectedError).thenReturn('Unexpected error');
    });

    test('returns outOfStock for OUT_OF_STOCK', () {
      expect(userErrorMessage(StateError('OUT_OF_STOCK'), l10n), 'Out of stock');
    });

    test('returns insufficientStock for INSUFFICIENT_STOCK', () {
      expect(userErrorMessage(StateError('INSUFFICIENT_STOCK'), l10n), 'Insufficient stock');
    });

    test('returns loadError for PRODUCT_NOT_FOUND', () {
      expect(userErrorMessage(StateError('PRODUCT_NOT_FOUND'), l10n), 'Error loading data');
    });

    test('returns loadError for NO_USER', () {
      expect(userErrorMessage(StateError('NO_USER'), l10n), 'Error loading data');
    });

    test('returns invalidCredentials for INVALID_CREDENTIALS', () {
      expect(userErrorMessage(StateError('INVALID_CREDENTIALS'), l10n), 'Invalid credentials');
    });

    test('returns wrongPassword for WRONG_PASSWORD', () {
      expect(userErrorMessage(StateError('WRONG_PASSWORD'), l10n), 'Wrong password');
    });

    test('returns tooManyAttempts for TOO_MANY_ATTEMPTS', () {
      expect(userErrorMessage(StateError('TOO_MANY_ATTEMPTS'), l10n), 'Too many attempts');
    });

    test('returns emailInUse for EMAIL_ALREADY_IN_USE', () {
      expect(userErrorMessage(StateError('EMAIL_ALREADY_IN_USE'), l10n), 'Email in use');
    });

    test('returns weakPasswordMessage for WEAK_PASSWORD', () {
      expect(userErrorMessage(StateError('WEAK_PASSWORD'), l10n), 'Weak password');
    });

    test('returns networkError for NETWORK_ERROR', () {
      expect(userErrorMessage(StateError('NETWORK_ERROR'), l10n), 'Network error');
    });

    test('returns requiresRecentLogin for REQUIRES_RECENT_LOGIN', () {
      expect(userErrorMessage(StateError('REQUIRES_RECENT_LOGIN'), l10n), 'Please re-login');
    });

    test('returns googleSignInCancelled for GOOGLE_SIGN_IN_CANCELLED', () {
      expect(userErrorMessage(StateError('GOOGLE_SIGN_IN_CANCELLED'), l10n), 'Google sign-in cancelled');
    });

    test('returns unexpectedError for UNKNOWN', () {
      expect(userErrorMessage(StateError('UNKNOWN'), l10n), 'Unexpected error');
    });

    test('returns fallback for unknown StateError', () {
      expect(userErrorMessage(StateError('SOME_ERROR'), l10n), 'Error loading data [SOME_ERROR]');
    });

    test('returns unexpectedError for non-StateError', () {
      expect(userErrorMessage(Exception('something'), l10n), 'Unexpected error [Exception: something]');
    });
  });
}
