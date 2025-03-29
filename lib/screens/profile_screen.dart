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

  AppUser? _appUser;
  bool _isLoadingProfile = false;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser != null) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoadingProfile = true;
    });
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      AppUser? fetchedUser = await UserService().getUserById(user.uid);
      setState(() {
        _appUser = fetchedUser;
        _isLoadingProfile = false;
        if (fetchedUser != null) {
          if (fetchedUser.userType == 'admin') {
            _tabController = TabController(length: 3, vsync: this);
          } else {
            _tabController = TabController(length: 2, vsync: this);
          }
        }
      });
    }
  }

  Future<void> _sendOtp() async {
    setState(() {
      _isProcessing = true;
    });
    String phone = _phoneController.text.trim();

    // NEW: Check if a user with this phone already exists with a different type.
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
      await _loadUserProfile();
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
      _appUser = null;
      _isOtpSent = false;
      _phoneController.text = '+91';
      _otpController.clear();
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
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
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
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('As User'),
                    ),
                  ),
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

  Widget _buildProfileComponent() {
    if (_appUser == null) {
      return const Center(child: CircularProgressIndicator());
    }
    switch (_appUser!.userType) {
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
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(body: _buildLoginComponent());
    } else if (_isLoadingProfile) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (_appUser == null) {
      // If no profile exists after loading, fall back to the login screen.
      return Scaffold(body: _buildLoginComponent());
    } else {
      return _buildProfileComponent();
    }
  }
}
