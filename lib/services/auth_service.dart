import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
	return userCredential.user;
  }
  return null;
}

Future<void> signInWithPhoneNumber(String phoneNumber, Function(String) codeSent, Function(FirebaseAuthException) verificationFailed) async {
  await _auth.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: (PhoneAuthCredential credential) async {
      await _auth.signInWithCredential(credential);
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
  return authResult.user;
}