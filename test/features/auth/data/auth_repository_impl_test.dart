import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/auth/data/repositories/auth_repository_impl.dart';
import '../../../helpers/mock_datasources.dart';

void main() {
  group('AuthRepositoryImpl', () {
    late MockAuthDatasource mockDatasource;
    late AuthRepositoryImpl repository;

    setUp(() {
      mockDatasource = MockAuthDatasource();
      repository = AuthRepositoryImpl(datasource: mockDatasource);
    });

    test('signInWithEmailAndPassword returns user entity', () async {
      mockDatasource.signInResult = testUserEntity;
      final user = await repository.signInWithEmailAndPassword(
        email: 'test@test.com',
        password: 'password',
      );
      expect(user.uid, 'user-1');
    });

    test('createUserWithEmailAndPassword returns user entity', () async {
      mockDatasource.createUserResult = testUserEntity;
      final user = await repository.createUserWithEmailAndPassword(
        email: 'test@test.com',
        password: 'password',
      );
      expect(user.uid, 'user-1');
    });

    test('currentUserEmail returns null by default', () {
      expect(repository.currentUserEmail, null);
    });

    test('currentUserEmail returns email when set', () {
      mockDatasource.currentEmail = 'test@test.com';
      expect(repository.currentUserEmail, 'test@test.com');
    });

    test('signIn throws StateError on failure', () async {
      mockDatasource.throwOnSignIn = true;
      expect(
        () => repository.signInWithEmailAndPassword(email: 'a', password: 'b'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
