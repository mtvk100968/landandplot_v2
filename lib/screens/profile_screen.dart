import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/property_model.dart';
import '../components/basic_property_card.dart';
import './property_details_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  String _verificationId = '';
  User? _currentUser;

  // State variables to hold user info
  String? _userName;
  String? _userPhone;
  String? _userEmail;

  // List of properties posted by this user
  List<Property> _userPostedProperties = [];
  bool _isLoadingProperties = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserData() async {
    _currentUser = FirebaseAuth.instance.currentUser;

    if (_currentUser != null) {
      if (mounted) setState(() => _isLoadingProperties = true);

      AppUser? appUser = await UserService().getUserById(_currentUser!.uid);

      if (appUser != null && mounted) {
        setState(() {
          _userName = appUser.name;
          _userPhone = appUser.phoneNumber;
          _userEmail = appUser.email;
        });

        // Fetch user properties
        if (appUser.postedPropertyIds.isNotEmpty) {
          print('Debug: postedPropertyIds: ${appUser.postedPropertyIds}');
          try {
            List<Property> properties = [];
            if (appUser.postedPropertyIds.length == 1) {
              print(
                  'Debug: Only one property found. Fetching single property.');
              final doc = await FirebaseFirestore.instance
                  .collection('properties')
                  .doc(appUser.postedPropertyIds.first)
                  .get();
              print('Debug: Fetched document data: ${doc.data()}');
              if (doc.exists && doc.data() != null) {
                properties.add(Property.fromDocument(doc));
                print('Debug: Added property from single fetch.');
              } else {
                print('Debug: Document does not exist or contains null data.');
              }
            } else {
              print('Debug: Multiple properties found. Fetching in batches.');
              properties = await UserService()
                  .getPropertiesByIds(appUser.postedPropertyIds);
              print(
                  'Debug: Batch fetch returned ${properties.length} properties.');
            }

            if (mounted) {
              setState(() {
                _userPostedProperties = properties;
                print(
                    'Debug: _userPostedProperties updated with ${properties.length} properties.');
              });
            }
          } catch (e) {
            print('Debug: Error fetching properties: $e');
          }
        } else {
          print('Debug: postedPropertyIds is empty.');
        }
      }

      if (mounted) {
        setState(() => _isLoadingProperties = false);
      }
    }
  }

  void _checkLoginStatus() {
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> _refreshProfile() async {
    await _loadUserData();
  }

  void _editPhoneNumber() {
    final phoneCtrl = TextEditingController(text: '+91');
    final codeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Phone Number'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: phoneCtrl,
                  decoration:
                      const InputDecoration(labelText: 'New Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: codeCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Verification Code'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await signInWithPhoneNumber(
                  phoneCtrl.text,
                  (String verId) {
                    setState(() => _verificationId = verId);
                    _showSuccessSnackBar('Verification code sent.');
                  },
                  (FirebaseAuthException e) {
                    _showErrorSnackBar(e.message ?? 'Verification failed.');
                  },
                );
              },
              child: const Text('Send Code'),
            ),
            TextButton(
              onPressed: () async {
                final credential = PhoneAuthProvider.credential(
                  verificationId: _verificationId,
                  smsCode: codeCtrl.text,
                );

                try {
                  await FirebaseAuth.instance.currentUser!
                      .linkWithCredential(credential);
                  await UserService().updateUser(
                    AppUser(
                      uid: _currentUser!.uid,
                      phoneNumber: phoneCtrl.text,
                    ),
                  );
                  setState(() => _userPhone = phoneCtrl.text);
                  Navigator.pop(context);
                  _showSuccessSnackBar('Phone updated successfully.');
                } catch (e) {
                  _showErrorSnackBar('Verification failed.');
                }
              },
              child: const Text('Verify & Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      _currentUser = null;
      _userName = null;
      _userPhone = null;
      _userEmail = null;
      _userPostedProperties.clear();
    });
  }

  Future<void> _signInWithGoogle() async {
    try {
      User? user = await signInWithGoogle();
      if (user != null && mounted) {
        setState(() {
          _currentUser = user;
        });
        _loadUserData();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to sign in with Google');
    }
  }

  void _showPhoneNumberDialog() {
    final phoneCtrl = TextEditingController(text: '+91');
    final codeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Phone Number'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: codeCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Verification Code'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => _sendCode(phoneCtrl.text),
              child: const Text('Send Code'),
            ),
            TextButton(
              onPressed: () => _signInWithPhone(codeCtrl.text),
              child: const Text('Sign In'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendCode(String phoneNumber) async {
    try {
      await signInWithPhoneNumber(
        phoneNumber,
        (String verId) {
          if (mounted) {
            setState(() => _verificationId = verId);
          }
        },
        (FirebaseAuthException e) {
          _showErrorSnackBar('Failed to verify phone number: ${e.message}');
        },
      );
      _showSuccessSnackBar('Verification code sent.');
    } catch (e) {
      _showErrorSnackBar('Failed to send verification code');
    }
  }

  Future<void> _signInWithPhone(String code) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: code,
      );
      User? user = await signInWithPhoneAuthCredential(credential);
      if (user != null && mounted) {
        setState(() {
          _currentUser = user;
        });
        _loadUserData();
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to sign in with phone number');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshProfile,
          child: _currentUser == null ? _buildSignInUI() : _buildProfilePage(),
        ),
      ),
    );
  }

  Widget _buildSignInUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sign-In/Sign-Up',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _signInWithGoogle(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(FontAwesomeIcons.google, size: 20),
                      SizedBox(width: 10),
                      Text('With Google'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showPhoneNumberDialog(),
                  icon: const Icon(Icons.phone),
                  label: const Text('With Number'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Profile',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: _editPhoneNumber,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.green, size: 40),
              title: Text(
                _userName ?? 'No Name',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${_userEmail ?? "Not provided"}'),
                  Text('Phone: ${_userPhone ?? "Not provided"}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Properties Posted Section
          Text(
            'My Listings',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _isLoadingProperties
              ? const Center(child: CircularProgressIndicator())
              : _userPostedProperties.isEmpty
                  ? const Center(
                      child: Text(
                        'No listings yet.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : Column(
                      children: _userPostedProperties.map((property) {
                        return BasicPropertyCard(
                          property: property,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PropertyDetailsScreen(property: property),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
          const SizedBox(height: 20),
          // Logout Button
          Center(
            child: TextButton(
              onPressed: _signOut,
              child: const Text(
                'Logout',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
