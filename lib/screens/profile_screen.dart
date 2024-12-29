import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/property_model.dart';
import '../components/property_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
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
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    _currentUser = FirebaseAuth.instance.currentUser;

    if (_currentUser != null) {
      setState(() => _isLoadingProperties = true);

      // Fetch user details from Firestore
      AppUser? appUser = await UserService().getUserById(_currentUser!.uid);

      if (appUser != null) {
        setState(() {
          _userName = appUser.name;
          _userPhone = appUser.phoneNumber;
          _userEmail = appUser.email;
        });

        // Fetch user properties
        if (appUser.postedPropertyIds.isNotEmpty) {
          try {
            final QuerySnapshot<Map<String, dynamic>> propertySnapshots =
                await FirebaseFirestore.instance
                    .collection('properties')
                    .where(FieldPath.documentId,
                        whereIn: appUser.postedPropertyIds)
                    .get();

            setState(() {
              _userPostedProperties = propertySnapshots.docs
                  .map((doc) => Property.fromDocument(doc))
                  .toList();
            });
          } catch (e) {
            print('Error fetching properties: $e');
          }
        }
      }

      setState(() => _isLoadingProperties = false);
    }
  }

  void _checkLoginStatus() {
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> _refreshProfile() async {
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: _currentUser == null ? _buildSignInUI() : _buildProfilePage(),
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
                  'Login to LANDANDPLOT',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.lightGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _signInWithGoogle(),
                  label: const Text('With Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showPhoneNumberDialog(),
                  label: const Text('With Number'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
          const SizedBox(height: 24),
          Card(
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Divider(),
                  if (_userName != null) Text('Name: $_userName'),
                  if (_userPhone != null) Text('Phone: $_userPhone'),
                  if (_userEmail != null) Text('Email: $_userEmail'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Posted Properties',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          _isLoadingProperties
              ? const Center(child: CircularProgressIndicator())
              : _userPostedProperties.isEmpty
                  ? const Text('No properties posted yet.')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _userPostedProperties.length,
                      itemBuilder: (context, index) {
                        return PropertyCard(
                          property: _userPostedProperties[index],
                          isFavorited: false,
                          onFavoriteToggle: (bool newState) {},
                        );
                      },
                    ),
        ],
      ),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Phone Number'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              TextField(
                controller: _codeController,
                decoration:
                    const InputDecoration(labelText: 'Verification Code'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _sendCode,
              child: const Text('Send Code'),
            ),
            TextButton(
              onPressed: _signInWithPhone,
              child: const Text('Sign In'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendCode() async {
    try {
      await signInWithPhoneNumber(
        _phoneController.text,
        (String verId) {
          if (mounted) {
            setState(() => _verificationId = verId);
          }
        },
        (FirebaseAuthException e) {
          _showErrorSnackBar('Failed to verify phone number: ${e.message}');
        },
      );
    } catch (e) {
      _showErrorSnackBar('Failed to send verification code');
    }
  }

  Future<void> _signInWithPhone() async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _codeController.text,
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
      SnackBar(content: Text(message)),
    );
  }
}
