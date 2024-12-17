import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:landandplot/screens/phone_number_otp_screen.dart';
import 'package:landandplot/screens/user_registration.dart';

class LoginScreen extends StatefulWidget {
  final List<dynamic> propertyList;
  final List<String> favoritedPropertyIds;
  final Function(String propertyId, bool isFavorited) onFavoriteToggle;

  const LoginScreen({
    Key? key,
    required this.propertyList,
    required this.favoritedPropertyIds,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Screen')),
      body: _currentUser == null
          ? _buildLoginButtons()
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${_currentUser!.email ?? 'User'}',
              style: const TextStyle(fontSize: 18),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                setState(() {
                  _currentUser = null;
                });
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButtons() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              User? user = await _signInWithGoogle();
              if (user != null) {
                final bool isRegistered = await _isUserRegistered(user.uid);
                if (!isRegistered) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserRegistration()),
                  );
                }
              }
            },
            child: const Text('Login with Google'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PhoneNumberOtpScreen()),
              );
            },
            child: const Text('Login with Phone Number'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserRegistration()),
              );
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print('Google Sign-In canceled.');
        return null; // User canceled sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      print('User signed in: ${userCredential.user?.email}');
      return userCredential.user;
    } catch (e) {
      print('Error during Google Sign-In: $e');
      return null;
    }
  }

  Future<bool> _isUserRegistered(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}
