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

  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  UserLoginType _selectedLoginType = UserLoginType.user;
  String _verificationId = '';
  bool _isOtpSent = false;
  bool _isProcessing = false;
  TabController? _tabController;

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    final userType =
        (_selectedLoginType == UserLoginType.agent) ? 'agent' : 'user';

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    await _authService.verifyPhoneNumber(
      phoneNumber: phone,
      userType: userType,
      verificationCompleted: (credential) async {
        // auto‐verified
        await _authService.signInWithPhoneAuthCredential(credential, userType);
      },
      verificationFailed: (e) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${e.message}')));
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
    );
  }

  Future<void> _verifyOtp() async {
    debugPrint('ProfileScreen: Entering _verifyOtp()');
    setState(() => _isProcessing = true);
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );
      final userType = _phoneController.text.trim() == '9959788005'
          ? 'admin'
          : _selectedLoginType == UserLoginType.agent
              ? 'agent'
              : 'user';
      await _authService.signInWithPhoneAuthCredential(cred, userType);
    } catch (err) {
      debugPrint('ProfileScreen: OTP verification failed, exception=$err');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification failed')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    setState(() {
      _isOtpSent = false;
      _phoneController.text = '+91';
      _otpController.clear();
    });
  }

  Widget _buildLoginComponent() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to LANDANDPLOT',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                // <-- only TextFormField supports validator
                validator: (value) {
                  if (value == null) return 'Enter a valid +91 10-digit number';
                  final input = value.trim();
                  final pattern = RegExp(r'^(?:\+91)?[6-9]\d{9}$');
                  if (!pattern.hasMatch(input)) {
                    return 'Enter a valid +91 10-digit number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (!_isOtpSent)
                ToggleButtons(
                  borderRadius: BorderRadius.circular(8),
                  isSelected: [
                    _selectedLoginType == UserLoginType.agent,
                    _selectedLoginType == UserLoginType.user,
                  ],
                  onPressed: (index) {
                    // final phone = _phoneController.text.trim();
                    // if (!RegExp(r'^\+91\d{10}\$').hasMatch(phone)) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(
                    //       content: Text('Enter a valid +91 10-digit number'),
                    //     ),
                    //   );
                    //   return;
                    // }
                    if (!_formKey.currentState!.validate()) return;

                    setState(() {
                      _selectedLoginType =
                          index == 0 ? UserLoginType.agent : UserLoginType.user;
                    });
                    _sendOtp();
                  },
                  constraints:
                      const BoxConstraints(minWidth: 120, minHeight: 40),
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
      builder: (context, authSnap) {
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
          builder: (context, profileSnap) {
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
