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
  String? _welcomeMessage;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _checkLoginStatus() {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      setState(() {
        _welcomeMessage =
            'Welcome, ${_currentUser!.email ?? _currentUser!.phoneNumber}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LANDANDPLOT')),
      body: Center(
        child: _currentUser == null
            ? _buildLoginButtons() // Show login buttons if not logged in
            : _buildProfilePage(), // Show profile if logged in
      ),
    );
  }

  Widget _buildLoginButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => _signInWithGoogle(),
          child: const Text('Sign in with Google'),
        ),
        ElevatedButton(
          onPressed: () {
            _showPhoneNumberDialog();
          },
          child: const Text('Sign in with Phone Number'),
        ),
      ],
    );
  }

  Widget _buildProfilePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_welcomeMessage != null)
          Text(_welcomeMessage!, style: const TextStyle(fontSize: 20)),
        ElevatedButton(
          onPressed: _signOut,
          child: const Text('Sign Out'),
        ),
      ],
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      _currentUser = null; // Reset the user state
      _welcomeMessage = null;
    });
  }

  Future<void> _signInWithGoogle() async {
    try {
      User? user = await signInWithGoogle();
      if (user != null && mounted) {
        setState(() {
          _currentUser = user;
          _welcomeMessage = 'Welcome, ${user.email}';
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to sign in with Google');
    }
  }

  void _showPhoneNumberDialog() {
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
                await _signInWithPhone();
              },
              child: const Text('Sign In'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendCode() async {
    try {
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
          _showErrorSnackBar('Failed to verify phone number: ${e.message}');
        },
      );
    } catch (e) {
      _showErrorSnackBar('Failed to send verification code');
    }
  }

  Future<void> _signInWithPhone() async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _codeController.text,
      );
      User? user = await signInWithPhoneAuthCredential(credential);
      if (user != null && mounted) {
        setState(() {
          _currentUser = user;
          _welcomeMessage = 'Welcome, ${user.phoneNumber}';
        });
        if (mounted) {
          Navigator.pop(context); // Close the dialog
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to sign in with phone number');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
