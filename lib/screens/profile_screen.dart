// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

// Profile Components
import '../components/profiles/admin/admin_profile.dart';
import '../components/profiles/agent/agent_profile.dart';
import '../components/profiles/user/user_profile.dart';

enum UserLoginType { agent, user }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController =
      TextEditingController(text: '+91');
  final TextEditingController _otpController = TextEditingController();

  UserLoginType _selectedLoginType = UserLoginType.user;
  String _verificationId = '';
  bool _isOtpSent = false;
  bool _isProcessing = false;
  TabController? _tabController;

  final AuthService _authService = AuthService();

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    debugPrint('🔔 _sendOtp() for $phone');
    setState(() => _isProcessing = true);

    try {
      // Optional: verify userType against Firestore
      AppUser? existingUser = await UserService().getUserByPhoneNumber(phone);
      debugPrint('👤 existingUser: $existingUser');

      if (phone != '9959788005' && existingUser != null) {
        String expectedType =
            _selectedLoginType == UserLoginType.agent ? 'agent' : 'user';
        if (existingUser.userType != expectedType) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You are registered as ${existingUser.userType}. '
                'Please sign in as ${existingUser.userType}.',
              ),
            ),
          );
          setState(() => _isProcessing = false);
          return;
        }
      }

      debugPrint('🔔 calling verifyPhoneNumber()');
      await _authService.signInWithPhoneNumber(
        phone,
        // codeSent
        (String verId) {
          debugPrint('✉️ codeSent callback: verId=$verId');
          setState(() {
            _verificationId = verId;
            _isOtpSent = true;
            _isProcessing = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('OTP sent')));
        },
        // verificationFailed
        (FirebaseAuthException e) {
          debugPrint('🔴 verificationFailed: code=${e.code}; msg=${e.message}');
          if (e.stackTrace != null) debugPrintStack(stackTrace: e.stackTrace);
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
        },
      );
      debugPrint('🔔 verifyPhoneNumber() call complete');
    } catch (e, st) {
      debugPrint('⚠️ Exception in _sendOtp(): $e');
      debugPrintStack(stackTrace: st);
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _verifyOtp() async {
    final smsCode = _otpController.text.trim();
    debugPrint('🔔 _verifyOtp() with code=$smsCode, verId=$_verificationId');
    setState(() => _isProcessing = true);

    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );
      String userType = _phoneController.text.trim() == '9959788005'
          ? 'admin'
          : (_selectedLoginType == UserLoginType.agent ? 'agent' : 'user');
      debugPrint('🔑 signing in with userType=$userType');
      await _authService.signInWithPhoneAuthCredential(cred, userType);
      debugPrint('✅ signInWithPhoneAuthCredential succeeded');
    } catch (err, st) {
      debugPrint('⚠️ OTP verification failed: $err');
      debugPrintStack(stackTrace: st);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Verification failed')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _signOut() async {
    debugPrint('🔔 _signOut()');
    await _authService.signOut();
    _phoneController.text = '+91';
    _otpController.clear();
    setState(() {
      _isOtpSent = false;
      _verificationId = '';
      _selectedLoginType = UserLoginType.user;
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
            const Text(
              'Welcome to LANDANDPLOT',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
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
              ToggleButtons(
                borderRadius: BorderRadius.circular(8),
                isSelected: [
                  _selectedLoginType == UserLoginType.agent,
                  _selectedLoginType == UserLoginType.user,
                ],
                onPressed: (i) {
                  final phone = _phoneController.text.trim();
                  if (!RegExp(r'^\+91\d{10}$').hasMatch(phone)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Enter a valid +91 10-digit number'),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    _selectedLoginType =
                        i == 0 ? UserLoginType.agent : UserLoginType.user;
                  });
                  _sendOtp();
                },
                constraints: const BoxConstraints(minWidth: 120, minHeight: 40),
                children: const [Text('As Agent'), Text('As User')],
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
            body: Center(child: CircularProgressIndicator()),
          );
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
