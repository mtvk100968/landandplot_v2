import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

enum UserLoginType { agent, user }

class SignInBottomSheet extends StatefulWidget {
  const SignInBottomSheet({Key? key}) : super(key: key);

  @override
  _SignInBottomSheetState createState() => _SignInBottomSheetState();
}

class _SignInBottomSheetState extends State<SignInBottomSheet> {
  final TextEditingController _phoneController =
      TextEditingController(text: '+91');
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isProcessing = false;
  String _verificationId = '';
  UserLoginType _selectedLoginType = UserLoginType.user;

  Future<void> _sendOtp() async {
    setState(() {
      _isProcessing = true;
    });
    // Check if a user with this phone already exists with a different type.
    AppUser? existingUser =
        await UserService().getUserByPhoneNumber(_phoneController.text.trim());
    if (existingUser != null) {
      String expectedType =
          _selectedLoginType == UserLoginType.agent ? 'agent' : 'user';
      if (existingUser.userType != expectedType) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'You are already registered as ${existingUser.userType}. Please sign in as ${existingUser.userType}.'),
          ),
        );
        setState(() {
          _isProcessing = false;
        });
        return;
      }
    }
    await signInWithPhoneNumber(
      _phoneController.text.trim(),
      (verId) {
        setState(() {
          _verificationId = verId;
          _isOtpSent = true;
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent')),
        );
      },
      (e) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Verification failed')),
        );
      },
    );
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isProcessing = true;
    });
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );
      String userType =
          _selectedLoginType == UserLoginType.agent ? 'agent' : 'user';
      await signInWithPhoneAuthCredential(credential, userType);
      setState(() {
        _isProcessing = false;
      });
      Navigator.pop(context, true); // Return true on successful sign in.
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP Verification failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Adjusts for keyboard appearance.
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sign In to Favorite',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (!_isOtpSent)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedLoginType = UserLoginType.agent;
                        });
                        _sendOtp();
                      },
                      child: const Text('As Agent'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedLoginType = UserLoginType.user;
                        });
                        _sendOtp();
                      },
                      child: const Text('As User'),
                    ),
                  ),
                ],
              ),
            if (_isOtpSent)
              Column(
                children: [
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter OTP',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _verifyOtp,
                    child: const Text('Verify OTP'),
                  ),
                ],
              ),
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
