// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import './user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initiates phone number verification and sends OTP.
  /// The [codeSent] callback returns the verificationId.
  /// [verificationFailed] is called if the process fails.
  Future<void> signInWithPhoneNumber(String phoneNumber,
      Function(String) codeSent,
      Function(FirebaseAuthException) verificationFailed,) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        final UserCredential authResult =
        await _auth.signInWithCredential(credential);
        final User? user = authResult.user;

        if (user != null) {
          // Create an AppUser instance
          // Default userType to 'user' if not specifically set
          AppUser appUser = AppUser(
            uid: user.uid,
            name: user.displayName,
            email: user.email,
            phoneNumber: user.phoneNumber,
            userType: phoneNumber == '9959788005' ? 'admin' : 'user',
          );

          // Save or update the user in Firestore
          await UserService().saveUser(appUser);
        }
      },
      verificationFailed: verificationFailed,
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  /// Signs in with the provided [phoneAuthCredential] and sets the user's type in Firestore.
  Future<User?> signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential,
      String userType,) async {
    final UserCredential authResult =
    await _auth.signInWithCredential(phoneAuthCredential);
    final User? user = authResult.user;

    if (user != null) {
      // Create an AppUser instance
      AppUser appUser = AppUser(
        uid: user.uid,
        name: user.displayName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        userType: userType,
      );

      // Save or update the user in Firestore
      await UserService().saveUser(appUser);
    }

    return user;
  }

  /// Signs out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Returns the currently signed-in [User], or null if none
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
