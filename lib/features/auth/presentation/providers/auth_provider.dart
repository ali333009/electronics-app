import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';

final authStateProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.uid;
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl();
});

class RegistrationData {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phoneNumber;

  const RegistrationData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phoneNumber,
  });
}

final registrationDataProvider = StateProvider<RegistrationData?>(
  (ref) => null,
);
final registrationErrorProvider = StateProvider<String?>((ref) => null);
