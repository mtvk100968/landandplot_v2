import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

// Profile Components
import '../components/profiles/admin/admin_profile.dart';
import '../components/profiles/agent/agent_profile.dart';
import '../components/profiles/user/user_profile.dart';

const _bypassPhones = ['+19999999999', '+18888888888', '+17777777777'];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController(text: '+91');
  final _otpController = TextEditingController();

  String _verificationId = '';
  bool _isOtpSent = false;
  bool _isProcessing = false;
  TabController? _tabController;

  final AuthService _authService = AuthService();

  bool _isAllowedPhone(String p) {
    p = p.trim();
    return _bypassPhones.contains(p) || (p.startsWith('+91') && p.length == 13);
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (!_isAllowedPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid +91 10-digit number')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await _authService.signInWithPhoneNumber(
        phone,
        (String verId) {
          setState(() {
            _verificationId = verId;
            _isOtpSent = true;
            _isProcessing = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('OTP sent')));
        },
        (FirebaseAuthException e) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
        },
      );
    } catch (e, st) {
      debugPrint('sendOtp error: $e\n$st');
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to send OTP')));
    }
  }

  Future<void> _verifyOtp() async {
    final smsCode = _otpController.text.trim();
    if (smsCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 6-digit OTP')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );

      // After you change AuthService, it should NOT need userType:
      await _authService.signInWithPhoneAuthCredential(cred);

      // if AuthService still needs type, pass 'user' for now:
      // await _authService.signInWithPhoneAuthCredential(cred, 'user');
    } catch (err, st) {
      debugPrint('verifyOtp failed: $err\n$st');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Verification failed')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    _phoneController.text = '+91';
    _otpController.clear();
    setState(() {
      _isOtpSent = false;
      _verificationId = '';
      _isProcessing = false;
    });
  }

  Widget _buildLoginComponent() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to LANDANDPLOT',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (!_isOtpSent)
              ElevatedButton(
                onPressed: _isProcessing ? null : _sendOtp,
                child: const Text('Send OTP'),
              ),
            if (_isOtpSent) ...[
              const SizedBox(height: 20),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isProcessing ? null : _verifyOtp,
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify OTP'),
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

  Widget _buildProfileComponent(AppUser appUser) {
    _tabController ??= TabController(
      length: appUser.userType == 'admin' ? 3 : 2,
      vsync: this,
    );
    switch (appUser.userType) {
      case 'admin':
        return AdminProfile(
          appUser: appUser,
          tabController: _tabController!,
          onSignOut: _signOut,
        );
      case 'agent':
        return AgentProfile(
          appUser: appUser,
          tabController: _tabController!,
          onSignOut: _signOut,
        );
      default:
        return UserProfile(initialUser: appUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (authSnap.data == null) {
          return Scaffold(body: _buildLoginComponent());
        }
        return StreamBuilder<AppUser?>(
          stream: UserService().getUserStream(authSnap.data!.uid),
          builder: (ctx, profileSnap) {
            if (profileSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final appUser = profileSnap.data;
            if (appUser == null) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Profile not found.'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _signOut,
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return _buildProfileComponent(appUser);
          },
        );
      },
    );
  }
}
