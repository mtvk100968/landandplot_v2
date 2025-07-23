import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

const _bypassPhones = ['+19999999999', '+18888888888', '+17777777777'];

class SignInBottomSheet extends StatefulWidget {
  const SignInBottomSheet({Key? key}) : super(key: key);

  @override
  _SignInBottomSheetState createState() => _SignInBottomSheetState();
}

class _SignInBottomSheetState extends State<SignInBottomSheet> {
  final _authService = AuthService();
  final _phoneController = TextEditingController(text: '+91');
  final _otpController = TextEditingController();

  bool _isOtpSent = false;
  bool _isProcessing = false;
  String _verificationId = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  bool _isAllowedPhone(String p) {
    p = p.trim();
    return _bypassPhones.contains(p) || (p.startsWith('+91') && p.length == 13);
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();

    if (!_isAllowedPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid Indian phone number')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _authService.signInWithPhoneAuthCredential(credential);
            if (mounted) Navigator.pop(context, true);
          } catch (e) {
            debugPrint('❌ Auto sign-in failed: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
        },
        codeSent: (verificationId, resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
            _isProcessing = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('OTP sent via SMS')));
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } catch (err, st) {
      debugPrint('verifyPhoneNumber error: $err\n$st');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
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
        smsCode: otp,
      );
      await _authService.signInWithPhoneAuthCredential(credential);
      if (mounted) {
        setState(() => _isProcessing = false);
        Navigator.pop(context, true);
      }
    } catch (_) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP verification failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              ElevatedButton(
                onPressed: _isProcessing ? null : _sendOtp,
                child: const Text('Send OTP'),
              ),
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
