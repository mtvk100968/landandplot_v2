import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; // Import the user model
import './user_service.dart'; // Import the user service

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<User?> signInWithGoogle() async {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
  if (googleUser != null) {
	final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
	final AuthCredential credential = GoogleAuthProvider.credential(
	  accessToken: googleAuth.accessToken,
	  idToken: googleAuth.idToken,
	);
	final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
	final User? user = userCredential.user;

	if (user != null) {
	  // Create an AppUser instance
	  AppUser appUser = AppUser(
		uid: user.uid,
		name: user.displayName,
		email: user.email,
		phoneNumber: user.phoneNumber,
	  );

	  // Save or update the user in Firestore
	  await UserService().saveUser(appUser);
	}

	return user;
  }
  return null;
}

Future<void> signInWithPhoneNumber(String phoneNumber, Function(String) codeSent, Function(FirebaseAuthException) verificationFailed) async {
  await _auth.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: (PhoneAuthCredential credential) async {
      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        // Create an AppUser instance
        AppUser appUser = AppUser(
          uid: user.uid,
          name: user.displayName,
          email: user.email,
          phoneNumber: user.phoneNumber,
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

Future<User?> signInWithPhoneAuthCredential(PhoneAuthCredential phoneAuthCredential) async {
  final UserCredential authResult = await _auth.signInWithCredential(phoneAuthCredential);
  final User? user = authResult.user;

  if (user != null) {
    // Create an AppUser instance
    AppUser appUser = AppUser(
      uid: user.uid,
      name: user.displayName,
      email: user.email,
      phoneNumber: user.phoneNumber,
    );

    // Save or update the user in Firestore
    await UserService().saveUser(appUser);
  }

  return user;
}