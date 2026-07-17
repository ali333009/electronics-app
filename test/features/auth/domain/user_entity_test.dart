import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    test('creates with required fields', () {
      final user = UserEntity(uid: 'u1', email: 'test@test.com');
      expect(user.uid, 'u1');
      expect(user.email, 'test@test.com');
      expect(user.isAdmin, false);
      expect(user.phoneVerified, false);
    });

    test('creates with all fields', () {
      final user = UserEntity(
        uid: 'u1',
        email: 'test@test.com',
        displayName: 'Test',
        firstName: 'Test',
        lastName: 'User',
        phoneNumber: '+96550000000',
        isAdmin: true,
        photoUrl: 'https://example.com/avatar.jpg',
        phoneVerified: true,
      );
      expect(user.displayName, 'Test');
      expect(user.firstName, 'Test');
      expect(user.lastName, 'User');
      expect(user.isAdmin, true);
      expect(user.photoUrl, 'https://example.com/avatar.jpg');
    });
  });
}
