import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

// Profile Components
import '../components/admin_profile.dart';
import '../components/agent_profile.dart';
import '../components/user_profile.dart';

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
    setState(() {
      _isProcessing = true;
    });
    String phone = _phoneController.text.trim();

    // Check if a user with this phone already exists with a different type.
    AppUser? existingUser = await UserService().getUserByPhoneNumber(phone);
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
      (e) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Verification failed')));
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
      String userType = _phoneController.text.trim() == '9959788005'
          ? 'admin'
          : _selectedLoginType == UserLoginType.agent
              ? 'agent'
              : 'user';

      await signInWithPhoneAuthCredential(credential, userType);
      setState(() {
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP Verification failed')));
    }
  }

  Future<void> _signOut() async {
    await signOut();
    setState(() {
      _isOtpSent = false;
      _phoneController.text = '+91';
      _otpController.clear();
    });
  }

  /// Login component using a ToggleButtons segmented control.
  Widget _buildLoginComponent() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to LandAndPlot',
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
                  _selectedLoginType == UserLoginType.user
                ],
                onPressed: (index) {
                  String phone = _phoneController.text.trim();
                  // Basic check for a 10-digit number, assuming +91 prefix
                  if (!RegExp(r'^\+91\d{10}$').hasMatch(phone)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Enter a valid 10-digit phone number')),
                    );
                    return;
                  }
                  setState(() {
                    _selectedLoginType =
                        index == 0 ? UserLoginType.agent : UserLoginType.user;
                  });
                  _sendOtp();
                },
                constraints: const BoxConstraints(minWidth: 120, minHeight: 40),
                children: const [
                  Text('As Agent'),
                  Text('As User'),
                ],
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

  /// Builds the appropriate profile component based on the user's type.
  Widget _buildProfileComponent(AppUser appUser) {
    // Initialize TabController if not already set.
    if (_tabController == null) {
      if (appUser.userType == 'admin') {
        _tabController = TabController(length: 3, vsync: this);
      } else {
        _tabController = TabController(length: 2, vsync: this);
      }
    }
    switch (appUser.userType) {
      case 'admin':
        return AdminProfile(
          tabController: _tabController!,
          onSignOut: _signOut,
        );
      case 'agent':
        return AgentProfile(
          tabController: _tabController!,
          onSignOut: _signOut,
        );
      default:
        return UserProfile(
          tabController: _tabController!,
          onSignOut: _signOut,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to Firebase Auth changes.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // While waiting for auth state, show a loader.
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        // If no user is signed in, show the login component.
        if (authSnapshot.data == null) {
          return Scaffold(body: _buildLoginComponent());
        }
        // If user is signed in, listen to Firestore user document changes.
        return StreamBuilder<AppUser?>(
          stream: UserService().getUserStream(authSnapshot.data!.uid),
          builder: (context, profileSnapshot) {
            // While waiting for the profile stream, show a loader.
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            // If profile data is not available, show an error with a sign-out option.
            if (!profileSnapshot.hasData || profileSnapshot.data == null) {
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
            // Otherwise, show the profile component.
            return _buildProfileComponent(profileSnapshot.data!);
          },
        );
      },
    );
  }
}
