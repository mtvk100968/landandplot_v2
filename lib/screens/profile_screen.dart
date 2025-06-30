/// lib/screens/profile_screen.dart

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
  const ProfileScreen({super.key});

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
    debugPrint('ProfileScreen: >>> Entering _sendOtp()');
    setState(() => _isProcessing = true);
    final phone = _phoneController.text.trim();

    try {
      AppUser? existingUser = await UserService().getUserByPhoneNumber(phone);
      debugPrint('ProfileScreen: getUserByPhoneNumber returned $existingUser');

      // skip type-mismatch check for the admin number
      if (phone != '9959788005' && existingUser != null) {
        String expectedType =
        _selectedLoginType == UserLoginType.agent ? 'agent' : 'user';
        debugPrint(
            'ProfileScreen: existingUser.userType=${existingUser.userType}, expected=$expectedType');
        if (existingUser.userType != expectedType) {
          debugPrint('ProfileScreen: wrong userType, showing snackbar');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'You are already registered as ${existingUser.userType}. '
                      'Please sign in as ${existingUser.userType}.'),
            ),
          );
          setState(() => _isProcessing = false);
          return;
        }
      }

      debugPrint('ProfileScreen: calling signInWithPhoneNumber()');
      await _authService.signInWithPhoneNumber(phone, (verId) {
        debugPrint('ProfileScreen: OTP sent callback, verId=$verId');
        setState(() {
          _verificationId = verId;
          _isOtpSent = true;
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('OTP sent')));
      },
          // (e) {
          //   debugPrint(
          //       'ProfileScreen: OTP send failed callback, error=${e.message}');
          //   setState(() => _isProcessing = false);
          //   ScaffoldMessenger.of(context).showSnackBar(
          //       SnackBar(content: Text(e.message ?? 'Failed sending OTP')));
          // },
              (FirebaseAuthException e) {
            debugPrint('❌ OTP send failed');
            debugPrint('Code: ${e.code}');
            debugPrint('Message: ${e.message}');
            debugPrint('Details: ${e.toString()}');
            if (e.stackTrace != null) {
              debugPrint('StackTrace: ${e.stackTrace}');
            }

            setState(() => _isProcessing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message ?? 'Failed sending OTP')),
            );
          });
      debugPrint('ProfileScreen: signInWithPhoneNumber() returned');
    } catch (e, st) {
      debugPrint('ProfileScreen: Exception in _sendOtp(): $e');
      debugPrint('$st');
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _verifyOtp() async {
    debugPrint('ProfileScreen: >>> Entering _verifyOtp()');
    setState(() => _isProcessing = true);
    debugPrint(
        'ProfileScreen: Verifying OTP ${_otpController.text.trim()} with verificationId=$_verificationId');
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );
      String userType = _phoneController.text.trim() == '9959788005'
          ? 'admin'
          : _selectedLoginType == UserLoginType.agent
          ? 'agent'
          : 'user';
      debugPrint('ProfileScreen: Signing in with userType=$userType');
      await _authService.signInWithPhoneAuthCredential(cred, userType);
      debugPrint('ProfileScreen: signInWithPhoneAuthCredential completed');
    } catch (err) {
      debugPrint('ProfileScreen: OTP verification failed, exception=$err');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Verification failed')));
    } finally {
      setState(() => _isProcessing = false);
      debugPrint('ProfileScreen: _verifyOtp() finished');
    }
  }

  Future<void> _signOut() async {
    debugPrint('ProfileScreen: >>> Entering _signOut()');
    await _authService.signOut();
    debugPrint('ProfileScreen: signOut() completed');
    _phoneController.text      = '+91';
    _otpController.clear();
    setState(() {
      _isOtpSent            = false;
      _verificationId       = '';
      _selectedLoginType    = UserLoginType.user;
      _isProcessing         = false;
    });
  }

  Widget _buildLoginComponent() {
    debugPrint('ProfileScreen: >>> Building login component');
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
                  debugPrint('ProfileScreen: ToggleButtons onPressed index=$i');
                  final phone = _phoneController.text.trim();
                  if (!RegExp(r'^\+91\d{10}$').hasMatch(phone)) {
                    debugPrint('ProfileScreen: Invalid phone format');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Enter a valid +91 10-digit number')),
                    );
                    return;
                  }
                  setState(() {
                    _selectedLoginType =
                    i == 0 ? UserLoginType.agent : UserLoginType.user;
                  });
                  debugPrint(
                      'ProfileScreen: _selectedLoginType=$_selectedLoginType');
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
                onPressed: () {
                  debugPrint('ProfileScreen: Verify OTP button pressed');
                  _verifyOtp();
                },
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

  Widget _buildProfileComponent(AppUser appUser) {
    debugPrint(
        'ProfileScreen: >>> Building profile component for userType=${appUser.userType}');
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
        return UserProfile(
          initialUser: appUser,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ProfileScreen: >>> build() called');
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, authSnap) {
        debugPrint(
            'ProfileScreen: authStateChanges snapshot: state=${authSnap.connectionState}, data=${authSnap.data}');
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (authSnap.data == null) {
          debugPrint('ProfileScreen: no Firebase user found');
          return Scaffold(body: _buildLoginComponent());
        }
        debugPrint('ProfileScreen: Firebase user UID = ${authSnap.data!.uid}');
        return StreamBuilder<AppUser?>(
          stream: UserService().getUserStream(authSnap.data!.uid),
          builder: (ctx, profileSnap) {
            debugPrint(
                'ProfileScreen: getUserStream snapshot: state=${profileSnap.connectionState}, data=${profileSnap.data}');
            if (profileSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final appUser = profileSnap.data;
            if (appUser == null) {
              debugPrint('ProfileScreen: AppUser is null');
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