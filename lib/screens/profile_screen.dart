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

  Future<void> _sendOtp() async {
    setState(() => _isProcessing = true);
    String phone = _phoneController.text.trim();
    debugPrint('ProfileScreen: sending OTP to $phone as $_selectedLoginType');

    AppUser? existingUser = await UserService().getUserByPhoneNumber(phone);
    debugPrint('ProfileScreen: existingUser=$existingUser');

    if (existingUser != null) {
      String expectedType =
          _selectedLoginType == UserLoginType.agent ? 'agent' : 'user';
      if (existingUser.userType != expectedType) {
        debugPrint('ProfileScreen: wrong userType, expected $expectedType');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('You are already registered as ${existingUser.userType}. '
                    'Please sign in as ${existingUser.userType}.'),
          ),
        );
        setState(() => _isProcessing = false);
        return;
      }
    }

    await signInWithPhoneNumber(
      phone,
      (verId) {
        debugPrint('ProfileScreen: OTP sent, verId=$verId');
        setState(() {
          _verificationId = verId;
          _isOtpSent = true;
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('OTP sent')));
      },
      (e) {
        debugPrint('ProfileScreen: OTP send failed, error=${e.message}');
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? 'Failed')));
      },
    );
  }

  Future<void> _verifyOtp() async {
    setState(() => _isProcessing = true);
    debugPrint('ProfileScreen: verifying OTP ${_otpController.text.trim()}');
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

      debugPrint('ProfileScreen: signing in with userType=$userType');
      await signInWithPhoneAuthCredential(cred, userType);
    } catch (err) {
      debugPrint('ProfileScreen: OTP verification failed, exception=$err');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Verification failed')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _signOut() async {
    debugPrint('ProfileScreen: signing out');
    await signOut();
    setState(() {
      _isOtpSent = false;
      _phoneController.text = '+91';
      _otpController.clear();
    });
  }

  Widget _buildLoginComponent() {
    debugPrint('ProfileScreen: building login component');
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
                          content: Text('Enter a valid +91 10-digit number')),
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
                onPressed: _verifyOtp,
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
        'ProfileScreen: building profile for $appUser (userType=${appUser.userType})');
    debugPrint('ProfileScreen: _tabController before init = $_tabController');
    _tabController ??= TabController(
      length: appUser.userType == 'admin' ? 3 : 2,
      vsync: this,
    );
    debugPrint('ProfileScreen: _tabController after init = $_tabController');

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
          appUser: appUser,
          tabController: _tabController!,
          onSignOut: _signOut,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ProfileScreen: build() called');
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
