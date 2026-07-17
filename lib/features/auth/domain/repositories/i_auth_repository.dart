import '../entities/user_entity.dart';

abstract class IAuthRepository {
  Stream<UserEntity?> authStateChanges();
  String? get currentUserUid;
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserEntity> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail({required String email});
  Future<void> signInWithPhoneCredential(Object credential);
  Future<UserEntity> signInWithOtp({
    required String verificationId,
    required String smsCode,
  });

  Future<void> sendVerificationEmail();
  Future<void> signOut();
  bool get hasGoogleProvider;
  Future<void> reauthenticateWithGoogle();
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> signInWithApple();
  void sendOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
    void Function(Object)? onVerificationCompleted,
  });
  Future<void> linkPhoneCredential(Object credential, {String? phoneNumber});
  Future<void> linkPhoneWithOtp({
    required String verificationId,
    required String smsCode,
    String? phoneNumber,
  });
  Future<void> saveUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String displayName,
    String? photoUrl,
    bool? phoneVerified,
  });
  Future<void> deleteCurrentUser({String? password});
  Future<void> updateDisplayName(String name);
  Future<void> verifyBeforeUpdateEmail(String email);
  Future<void> updatePassword(String password);
  Future<bool> checkEmailExists(String email);
  String? get currentUserEmail;
  Future<void> resetPasswordViaPhoneOtp({
    required String verificationId,
    required String smsCode,
    required String newPassword,
  });
}
