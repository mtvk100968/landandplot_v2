import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String _verificationId = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _signInWithGoogleAndNavigate(),
              child: const Text('Sign in with Google'),
            ),
            ElevatedButton(
              onPressed: () {
                _showPhoneNumberDialog(context);
              },
              child: const Text('Sign in with Phone Number'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithGoogleAndNavigate() async {
    User? user = await signInWithGoogle();
    if (user != null && mounted) {
      _navigateToBuyLand();
    }
  }

  void _navigateToBuyLand() {
    Navigator.pushReplacementNamed(context, '/buy_land');
  }

  void _showPhoneNumberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Phone Number'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              TextField(
                controller: _codeController,
                decoration:
                    const InputDecoration(labelText: 'Verification Code'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _sendCode();
              },
              child: const Text('Send Code'),
            ),
            TextButton(
              onPressed: () async {
                await _signInWithPhoneAndNavigate();
              },
              child: const Text('Sign In'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendCode() async {
    await signInWithPhoneNumber(
      _phoneController.text,
      (String verId) {
        if (mounted) {
          setState(() {
            _verificationId = verId;
          });
        }
      },
      (FirebaseAuthException e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to verify phone number: ${e.message}'),
            ),
          );
        }
      },
    );
  }

  Future<void> _signInWithPhoneAndNavigate() async {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: _codeController.text,
    );
    User? user = await signInWithPhoneAuthCredential(credential);
    if (user != null && mounted) {
      _navigateToBuyLand();
    }
  }
}
