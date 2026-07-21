import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../domain/entities/user_entity.dart';

/// Firebase-backed authentication datasource.
///
/// Handles sign-in, sign-up, Google auth, phone/OTP auth,
/// password reset, email verification, profile persistence,
/// account deletion, token refresh, and auth state streaming.
class AuthDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Internal Helpers ─────────────────────────────────────────

  String _mapErrorCode(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'USER_NOT_FOUND';
      case 'invalid-credential':
        return 'INVALID_CREDENTIALS';
      case 'invalid-email':
      case 'missing-email':
        return 'INVALID_EMAIL';
      case 'wrong-password':
        return 'WRONG_PASSWORD';
      case 'too-many-requests':
        return 'TOO_MANY_ATTEMPTS';
      case 'email-already-in-use':
        return 'EMAIL_ALREADY_IN_USE';
      case 'weak-password':
        return 'WEAK_PASSWORD';
      case 'network-request-failed':
        return 'NETWORK_ERROR';
      case 'requires-recent-login':
        return 'REQUIRES_RECENT_LOGIN';
      case 'invalid-phone-number':
        return 'INVALID_PHONE';
      case 'invalid-verification-code':
        return 'INVALID_OTP';
      case 'quota-exceeded':
        return 'SMS_QUOTA_EXCEEDED';
      case 'session-expired':
        return 'OTP_EXPIRED';
      case 'app-not-authorized':
        return 'APP_NOT_AUTHORIZED';
      case 'missing-client-identifier':
        return 'MISSING_CLIENT_IDENTIFIER';
      case 'internal-error':
      case 'unknown':
        return 'INTERNAL_ERROR: ${e.message}';
      default:
        return 'UNKNOWN_ERROR';
    }
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  UserEntity _toEntity(User? user, {Map<String, dynamic>? firestoreData}) {
    if (user == null) throw StateError('USER_NULL');

    final fsDisplayName = firestoreData?['displayName'] as String?;
    final resolvedDisplayName =
        (fsDisplayName != null && fsDisplayName.isNotEmpty)
            ? fsDisplayName
            : (user.displayName ?? '');

    final fsFirstName = firestoreData?['firstName'] as String?;
    final fsLastName = firestoreData?['lastName'] as String?;

    String firstName = '';
    String lastName = '';
    if (fsFirstName != null && fsFirstName.isNotEmpty) {
      firstName = fsFirstName;
      lastName = fsLastName ?? '';
    } else {
      final parts = resolvedDisplayName.split(' ');
      firstName = parts.isNotEmpty ? parts.first : '';
      lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    final fsPhone = firestoreData?['phoneNumber'] as String?;
    final resolvedPhone = (fsPhone != null && fsPhone.isNotEmpty)
        ? fsPhone
        : user.phoneNumber;

    return UserEntity(
      uid: user.uid,
      email: user.email,
      displayName: resolvedDisplayName.isNotEmpty ? resolvedDisplayName : null,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: resolvedPhone,
      isAdmin: firestoreData?['isAdmin'] ?? false,
      photoUrl: firestoreData?['photoUrl'] as String? ?? user.photoURL,
      phoneVerified: firestoreData?['phoneVerified'] ?? false,
    );
  }

  // ─── Authentication ───────────────────────────────────────────

  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        return _toEntity(user, firestoreData: doc.data());
      }
      return _toEntity(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        try {
          // fetchSignInMethodsForEmail is removed in firebase_auth 5+
          // Instead, check if the user document in Firestore has a Google provider
          final querySnap = await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();
          if (querySnap.docs.isNotEmpty) {
            final data = querySnap.docs.first.data();
            final provider = data['provider'] as String? ?? '';
            if (provider == 'google') {
              throw StateError('PLEASE_USE_GOOGLE_SIGN_IN');
            }
          }
        } on StateError {
          rethrow;
        } catch (_) {}
      }
      throw StateError(_mapErrorCode(e));
    }
  }

  Future<UserEntity> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      try {
        await _saveEmailAvailability(email);
      } catch (_) {}
      final user = cred.user;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        return _toEntity(user, firestoreData: doc.data());
      }
      return _toEntity(user);
    } on FirebaseAuthException catch (e) {
      throw StateError(_mapErrorCode(e));
    }
  }

  Future<UserEntity> signInWithGoogle() async {
    try {
      User? user;

      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');
        final userCred = await _auth.signInWithPopup(provider);
        user = userCred.user;
      } else {
        try {
          final googleUser = await GoogleSignIn.instance.authenticate();
          final googleAuth = googleUser.authentication;
          final credential = GoogleAuthProvider.credential(
            idToken: googleAuth.idToken,
          );
          final userCred = await _auth.signInWithCredential(credential);
          user = userCred.user;
        } on Exception catch (_) {
          throw StateError('GOOGLE_SIGN_IN_CANCELLED');
        }
      }

      if (user == null) throw StateError('USER_NULL');
      final displayName = user.displayName ?? '';
      final parts = displayName.split(' ');
      final firstName = parts.isNotEmpty ? parts.first : '';
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      final existingDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      final firestoreData = existingDoc.data();
      await _firestore.collection('users').doc(user.uid).set({
        'displayName': displayName,
        'firstName': firstName,
        'lastName': lastName,
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'phoneNumber':
            user.phoneNumber ?? firestoreData?['phoneNumber'] ?? '',
        'phoneVerified': firestoreData?['phoneVerified'] ?? false,
        'createdAt': FieldValue.serverTimestamp(),
        'isAdmin': firestoreData?['isAdmin'] ?? false,
      }, SetOptions(merge: true));
      if (user.email != null) {
        try {
          await _saveEmailAvailability(user.email!);
        } catch (_) {}
      }
      return _toEntity(user, firestoreData: firestoreData);
    } on FirebaseAuthException catch (e) {
      throw StateError(_mapErrorCode(e));
    }
  }

  Future<UserEntity> signInWithApple() async {
    try {
      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleIdCredential.identityToken,
        accessToken: appleIdCredential.authorizationCode,
      );

      final userCred = await _auth.signInWithCredential(oauthCredential);
      final user = userCred.user;

      if (user == null) throw StateError('USER_NULL');

      final existingDoc = await _firestore.collection('users').doc(user.uid).get();
      final firestoreData = existingDoc.data();

      final existingDisplayName = firestoreData?['displayName'] as String?;
      final existingFirstName = firestoreData?['firstName'] as String?;
      final existingLastName = firestoreData?['lastName'] as String?;
      
      String displayName = '';
      String firstName = '';
      String lastName = '';

      if (appleIdCredential.givenName != null || appleIdCredential.familyName != null) {
        firstName = appleIdCredential.givenName ?? '';
        lastName = appleIdCredential.familyName ?? '';
        displayName = '$firstName $lastName'.trim();
      } else if (existingDisplayName != null && existingDisplayName.isNotEmpty) {
        displayName = existingDisplayName;
        firstName = existingFirstName ?? '';
        lastName = existingLastName ?? '';
      } else if (user.displayName != null && user.displayName!.isNotEmpty) {
        displayName = user.displayName!;
        final parts = displayName.split(' ');
        firstName = parts.isNotEmpty ? parts.first : '';
        lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }

      await _firestore.collection('users').doc(user.uid).set({
        if (displayName.isNotEmpty) 'displayName': displayName,
        if (firstName.isNotEmpty) 'firstName': firstName,
        if (lastName.isNotEmpty) 'lastName': lastName,
        'email': user.email ?? firestoreData?['email'] ?? '',
        'photoUrl': user.photoURL ?? firestoreData?['photoUrl'] ?? '',
        'phoneNumber': user.phoneNumber ?? firestoreData?['phoneNumber'] ?? '',
        'phoneVerified': firestoreData?['phoneVerified'] ?? false,
        'createdAt': firestoreData == null ? FieldValue.serverTimestamp() : (firestoreData['createdAt'] ?? FieldValue.serverTimestamp()),
        'isAdmin': firestoreData?['isAdmin'] ?? false,
      }, SetOptions(merge: true));

      if (user.email != null) {
        try {
          await _saveEmailAvailability(user.email!);
        } catch (_) {}
      }

      return _toEntity(user, firestoreData: existingDoc.data() ?? {});
    } on FirebaseAuthException catch (e) {
      throw StateError(_mapErrorCode(e));
    } catch (e) {
      throw StateError('APPLE_SIGN_IN_FAILED');
    }
  }

  Future<void> signOut() async {
    final user = _auth.currentUser;
    final hasGoogleProvider =
        user?.providerData.any((info) => info.providerId == 'google.com') ??
        false;
    if (hasGoogleProvider) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
    }
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw StateError(_mapErrorCode(e));
    }
  }

  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('NO_USER');
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw StateError(_mapErrorCode(e));
    }
  }

  // ─── Account Management ────────────────────────────────────────

  Future<void> deleteCurrentUser({String? password}) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('NO_USER');

    final email = user.email;
    final uid = user.uid;

    // Step 1: Delete all Firestore data FIRST (while user is still authenticated)
    try {
      final batch = _firestore.batch();
      batch.delete(_firestore.collection('users').doc(uid));
      if (email != null && email.isNotEmpty) {
        batch.delete(_firestore.collection('emailAvailability').doc(email.toLowerCase()));
      }
      final cartSnap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('cart')
          .get();
      for (final doc in cartSnap.docs) {
        batch.delete(doc.reference);
      }
      final addressSnap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('addresses')
          .get();
      for (final doc in addressSnap.docs) {
        batch.delete(doc.reference);
      }
      final wishlistSnap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('wishlist')
          .get();
      for (final doc in wishlistSnap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      final ordersSnap = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: uid)
          .get();
      final orderBatch = _firestore.batch();
      for (final doc in ordersSnap.docs) {
        orderBatch.delete(doc.reference);
      }
      await orderBatch.commit();
    } catch (_) {}

    // Step 2: Delete Firebase Auth account LAST
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw StateError(_mapErrorCode(e));
    }
  }

  Future<void> reauthenticateWithCredential(AuthCredential credential) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('NO_USER');
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> reauthenticateWithGoogle() async {
    final googleUser = await GoogleSignIn.instance.authenticate();
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    await reauthenticateWithCredential(credential);
  }

  Future<void> updateDisplayName(String name) async {
    try {
      await _auth.currentUser?.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      throw StateError(_mapErrorCode(e));
    }
  }

  Future<void> verifyBeforeUpdateEmail(String email) async {
    try {
      await _auth.currentUser?.verifyBeforeUpdateEmail(email);
    } on FirebaseAuthException catch (e) {
      throw StateError(_mapErrorCode(e));
    }
  }

  Future<void> updatePassword(String password) async {
    try {
      await _auth.currentUser?.updatePassword(password);
    } on FirebaseAuthException catch (e) {
      throw StateError(_mapErrorCode(e));
    }
  }

  bool get hasGoogleProvider {
    final user = _auth.currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'google.com');
  }

  String? get currentUserEmail => _auth.currentUser?.email;

  String? get currentUserUid => _auth.currentUser?.uid;

  // ─── Phone / OTP ──────────────────────────────────────────────

  void sendOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
    void Function(PhoneAuthCredential)? onVerificationCompleted,
  }) {
    _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) {
        onVerificationCompleted?.call(credential);
      },
      verificationFailed: (e) {
        onError(_mapErrorCode(e));
      },
      codeSent: (verificationId, resendToken) {
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  Future<void> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    try {
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw StateError(_mapErrorCode(e));
    }
  }

  Future<void> linkPhoneCredential(
    PhoneAuthCredential credential, {
    String? phoneNumber,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('NO_USER');
    try {
      await user.linkWithCredential(credential);
      final data = <String, dynamic>{
        'phoneVerified': true,
      };
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        data['phoneNumber'] = phoneNumber;
      }
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(data, SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      throw StateError(_mapErrorCode(e));
    }
  }

  Future<void> linkPhoneWithOtp({
    required String verificationId,
    required String smsCode,
    String? phoneNumber,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await linkPhoneCredential(credential, phoneNumber: phoneNumber);
  }

  Future<UserEntity> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;
      if (user == null) throw StateError('USER_NULL');
      return UserEntity(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
      );
    } on FirebaseAuthException catch (e) {
      throw StateError(_mapErrorCode(e));
    } catch (e) {
      throw StateError('INTERNAL_ERROR');
    }
  }

  // ─── Profile ──────────────────────────────────────────────────

  Future<void> saveUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String displayName,
    String? photoUrl,
    bool? phoneVerified,
  }) async {
    try {
      final existingDoc = await _firestore.collection('users').doc(uid).get();
      final existingIsAdmin = existingDoc.data()?['isAdmin'] ?? false;
      final existingPhoneVerified =
          existingDoc.data()?['phoneVerified'] ?? false;
      await _firestore.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'displayName': displayName,
        'email': email,
        'phoneNumber': phoneNumber,
        'phoneVerified': phoneVerified ?? existingPhoneVerified,
        'photoUrl': photoUrl ?? existingDoc.data()?['photoUrl'] ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'isAdmin': existingIsAdmin,
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw StateError(e.code);
    }
  }

  Future<void> _saveEmailAvailability(String email) async {
    await _firestore
        .collection('emailAvailability')
        .doc(_normalizeEmail(email))
        .set({'email': email, 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final doc = await _firestore
          .collection('emailAvailability')
          .doc(_normalizeEmail(email))
          .get();
      return doc.exists;
    } catch (_) {
      return false;
    }
  }

  // ─── Auth State ────────────────────────────────────────────────

  Stream<UserEntity?> authStateChanges() =>
      _auth.authStateChanges().asyncMap((user) async {
        if (user == null) return null;
        try {
          final doc = await _firestore.collection('users').doc(user.uid).get();
          return _toEntity(user, firestoreData: doc.data());
        } catch (_) {
          return _toEntity(user);
        }
      });

  // ─── Reset Password via Phone OTP ─────────────────────────────

  /// Verifies the OTP, signs in with the phone credential (temporarily),
  /// then updates the password of the email/password account linked to
  /// the same user, and finally signs back to the original state.
  Future<void> resetPasswordViaPhoneOtp({
    required String verificationId,
    required String smsCode,
    required String newPassword,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    try {
      // Sign in with phone credential to get the user
      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;
      if (user == null) throw StateError('USER_NOT_FOUND');
      // Update password directly
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw StateError(_mapErrorCode(e));
    }
  }
}
