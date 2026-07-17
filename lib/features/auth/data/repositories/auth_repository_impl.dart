import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_datasource.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthDatasource _datasource;

  AuthRepositoryImpl({AuthDatasource? datasource})
    : _datasource = datasource ?? AuthDatasource();

  @override
  Stream<UserEntity?> authStateChanges() => _datasource.authStateChanges();

  @override
  String? get currentUserUid => _datasource.currentUserUid;

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      _datasource.signInWithEmailAndPassword(email: email, password: password);

  @override
  Future<UserEntity> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) => _datasource.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  @override
  Future<void> sendPasswordResetEmail({required String email}) =>
      _datasource.sendPasswordResetEmail(email: email);

  @override
  Future<void> signInWithPhoneCredential(Object credential) =>
      _datasource.signInWithPhoneCredential(credential as PhoneAuthCredential);

  @override
  Future<void> sendVerificationEmail() => _datasource.sendVerificationEmail();

  @override
  Future<void> signOut() => _datasource.signOut();

  @override
  bool get hasGoogleProvider => _datasource.hasGoogleProvider;

  @override
  Future<void> reauthenticateWithGoogle() =>
      _datasource.reauthenticateWithGoogle();

  @override
  Future<UserEntity> signInWithGoogle() => _datasource.signInWithGoogle();

  @override
  Future<UserEntity> signInWithApple() => _datasource.signInWithApple();

  @override
  void sendOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
    void Function(Object)? onVerificationCompleted,
  }) => _datasource.sendOtp(
    phoneNumber: phoneNumber,
    onCodeSent: onCodeSent,
    onError: onError,
    onVerificationCompleted: onVerificationCompleted,
  );

  @override
  Future<void> linkPhoneCredential(Object credential, {String? phoneNumber}) =>
      _datasource.linkPhoneCredential(
        credential as PhoneAuthCredential,
        phoneNumber: phoneNumber,
      );

  @override
  Future<UserEntity> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final user = await _datasource.signInWithOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return user;
  }

  @override
  Future<void> linkPhoneWithOtp({
    required String verificationId,
    required String smsCode,
    String? phoneNumber,
  }) => _datasource.linkPhoneWithOtp(
    verificationId: verificationId,
    smsCode: smsCode,
    phoneNumber: phoneNumber,
  );

  @override
  Future<void> saveUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String displayName,
    String? photoUrl,
    bool? phoneVerified,
  }) => _datasource.saveUserProfile(
    uid: uid,
    firstName: firstName,
    lastName: lastName,
    email: email,
    phoneNumber: phoneNumber,
    displayName: displayName,
    photoUrl: photoUrl,
    phoneVerified: phoneVerified,
  );

  @override
  Future<void> deleteCurrentUser({String? password}) =>
      _datasource.deleteCurrentUser(password: password);

  @override
  Future<void> updateDisplayName(String name) =>
      _datasource.updateDisplayName(name);

  @override
  Future<void> verifyBeforeUpdateEmail(String email) =>
      _datasource.verifyBeforeUpdateEmail(email);

  @override
  Future<void> updatePassword(String password) =>
      _datasource.updatePassword(password);

  @override
  Future<bool> checkEmailExists(String email) =>
      _datasource.checkEmailExists(email);

  @override
  String? get currentUserEmail => _datasource.currentUserEmail;

  @override
  Future<void> resetPasswordViaPhoneOtp({
    required String verificationId,
    required String smsCode,
    required String newPassword,
  }) => _datasource.resetPasswordViaPhoneOtp(
        verificationId: verificationId,
        smsCode: smsCode,
        newPassword: newPassword,
      );
}
