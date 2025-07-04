// lib/components/buy_land_related/sign_in_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';

enum UserLoginType { agent, user }

class SignInBottomSheet extends StatefulWidget {
  const SignInBottomSheet({Key? key}) : super(key: key);

  @override
  _SignInBottomSheetState createState() => _SignInBottomSheetState();
}

class _SignInBottomSheetState extends State<SignInBottomSheet> {
  final _authService = AuthService();
  final TextEditingController _phoneController =
  TextEditingController(text: '+91');
  final TextEditingController _otpController = TextEditingController();

  bool _isOtpSent = false;
  bool _isProcessing = false;
  String _verificationId = '';
  UserLoginType _selectedLoginType = UserLoginType.user;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();

    // ✅ Basic phone number validation
    if (phone.length < 13 || !phone.startsWith('+91')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Indian phone number')),
      );
      return;
    }

    final userType = _selectedLoginType == UserLoginType.agent ? 'agent' : 'user';
    debugPrint("▶️ _sendOtp() starting for $phone as $userType");
    setState(() => _isProcessing = true);

    try {
      debugPrint("  → about to call verifyPhoneNumber()");
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,                             // ← use `phone`, not `phoneNumber`
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            // final userType = _selectedLoginType == UserLoginType.agent ? 'agent' : 'user';
            await _authService.signInWithPhoneAuthCredential(credential, userType);
            Navigator.pop(context, true); // Auto-signed in
          } catch (e) {
            debugPrint("❌ Auto-sign-in failed: $e");
          }
        },

        // verificationFailed: (FirebaseAuthException e) {
        //   debugPrint("❌ verificationFailed: ${e.code} ${e.message}");
        //   print('Full exception: $e');
        //   // ScaffoldMessenger.of(context).showSnackBar(
        //   //     SnackBar(content: Text('Verification failed: ${e.code} — ${e.message}'))
        //   // );
        //   // setState(() => _isProcessing = false);
        // },

        verificationFailed: (FirebaseAuthException e) {
          debugPrint("❌ verificationFailed: ${e.code} ${e.message}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${e.message ?? 'Unknown error'}')),
          );
          setState(() => _isProcessing = false);
        },


        codeSent: (verificationId, resendToken) {
          debugPrint("✉️ codeSent: id=$verificationId, token=$resendToken");
          setState(() {
            _verificationId = verificationId;
            _isOtpSent     = true;
            _isProcessing  = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP sent via SMS'))
          );
        },

        codeAutoRetrievalTimeout: (verificationId) {
          debugPrint("⏰ autoRetrievalTimeout: id=$verificationId");
        },
      );

      debugPrint("  ← verifyPhoneNumber() returned");
    } catch (err, st) {
      debugPrint("🔴 verifyPhoneNumber threw: $err\n$st");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    // ✅ Basic OTP validation
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 6-digit OTP')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );
      final userType =
      _selectedLoginType == UserLoginType.agent
          ? 'agent'
          : 'user';

      await _authService.signInWithPhoneAuthCredential(
          credential, userType);

      setState(() => _isProcessing = false);
      Navigator.pop(context, true); // OTP verified and signed in
    } catch (_) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP verification failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // makes room for the on-screen keyboard
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

            // Phone input
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Agent / User buttons
            if (!_isOtpSent)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () {
                        setState(() =>
                        _selectedLoginType = UserLoginType.agent);
                        _sendOtp();
                      },
                      child: const Text('As Agent'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () {
                        setState(() =>
                        _selectedLoginType = UserLoginType.user);
                        _sendOtp();
                      },
                      child: const Text('As User'),
                    ),
                  ),
                ],
              ),

            // OTP input + Verify button
            if (_isOtpSent) ...[
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
                onPressed: _isProcessing ? null : _verifyOtp,
                child: const Text('Verify OTP'),
              ),
            ],

            // Loading spinner
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
