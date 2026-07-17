import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elct/features/auth/presentation/providers/auth_provider.dart';

void main() {
  group('auth providers', () {
    test('registrationDataProvider starts with null', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      expect(container.read(registrationDataProvider), null);
    });

    test('registrationDataProvider can be set', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      container.read(registrationDataProvider.notifier).state = const RegistrationData(
        firstName: 'Test',
        lastName: 'User',
        email: 'test@test.com',
        password: 'password',
        phoneNumber: '+96550000000',
      );
      final data = container.read(registrationDataProvider);
      expect(data, isNotNull);
      expect(data!.firstName, 'Test');
      expect(data.email, 'test@test.com');
    });
  });
}
