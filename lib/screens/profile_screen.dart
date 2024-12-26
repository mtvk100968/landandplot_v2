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
  String? _welcomeMessage;
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
    _loadUserData(); // Load user details and posted properties
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  // Fetch user details and their posted properties
  Future<void> _loadUserData() async {
    _currentUser = FirebaseAuth.instance.currentUser;

    if (_currentUser != null) {
      setState(() => _isLoadingProperties = true);

      // Fetch user details from Firestore
      AppUser? appUser = await UserService().getUserById(_currentUser!.uid);

      if (appUser != null) {
        // Update local user state
        setState(() {
          _userName = appUser.name;
          _userPhone = appUser.phoneNumber;
          _userEmail = appUser.email;
        });

        // Debug: Print postedPropertyIds
        print('DEBUG: postedPropertyIds -> ${appUser.postedPropertyIds}');

        // If the user has posted properties, fetch them
        if (appUser.postedPropertyIds.isNotEmpty) {
          try {
            // Firestore allows a maximum of 10 elements in a `whereIn` query
            // If you have more, you'll need to batch them
            final List<String> propertyIds =
                appUser.postedPropertyIds.length > 10
                    ? appUser.postedPropertyIds.sublist(0, 10)
                    : appUser.postedPropertyIds;

            print('DEBUG: Fetching properties with IDs -> $propertyIds');

            final QuerySnapshot<Map<String, dynamic>> propertySnapshots =
                await FirebaseFirestore.instance
                    .collection('properties')
                    .where(FieldPath.documentId, whereIn: propertyIds)
                    .get();

            print(
                'DEBUG: Retrieved ${propertySnapshots.docs.length} properties');

            final List<Property> fetchedProperties =
                propertySnapshots.docs.map((doc) {
              // Use the new fromDocument constructor
              return Property.fromDocument(doc);
            }).toList();

            setState(() {
              _userPostedProperties = fetchedProperties;
            });

            print('DEBUG: Fetched Properties -> $_userPostedProperties');
          } catch (e) {
            print('Error fetching posted properties: $e');
          }
        } else {
          print('DEBUG: No postedPropertyIds found for user.');
        }
      } else {
        print('DEBUG: AppUser not found for UID: ${_currentUser!.uid}');
      }

      setState(() => _isLoadingProperties = false);
    } else {
      print('DEBUG: No current user found.');
    }
  }

  void _checkLoginStatus() {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      setState(() {
        _welcomeMessage =
            'Welcome, ${_currentUser!.email ?? _currentUser!.phoneNumber}';
      });
    }
  }

  // ADDED: Pull-to-refresh method to reload user data
  Future<void> _refreshProfile() async {
    await _loadUserData();
    // The setState calls happen inside _loadUserData, so no need for an extra setState here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A gradient background for the entire screen
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        // Use a scrollable widget so the user can pull down
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: _currentUser == null
                    ? _buildLoginButtons()
                    : _buildProfilePage(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => _signInWithGoogle(),
            icon: const Icon(Icons.login),
            label: const Text('Sign in with Google'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 3,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showPhoneNumberDialog(),
            icon: const Icon(Icons.phone),
            label: const Text('Sign in with Phone Number'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              foregroundColor: Colors.white,
              elevation: 3,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Message with Avatar
          Row(
            children: [
              if (_currentUser != null && _currentUser!.photoURL != null)
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(_currentUser!.photoURL!),
                )
              else
                const CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      AssetImage('assets/images/default_avatar.png'),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _welcomeMessage ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // A card for user info
          Card(
            color: Colors.white.withOpacity(0.85),
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
                  if (_userName != null)
                    Text(
                      'Name: $_userName',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  if (_userPhone != null)
                    Text(
                      'Phone: $_userPhone',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  if (_userEmail != null)
                    Text(
                      'Email: $_userEmail',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Posted Properties section
          Text(
            'Your Posted Properties',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Display posted properties
          _isLoadingProperties
              ? const Center(child: CircularProgressIndicator())
              : _userPostedProperties.isEmpty
                  ? const Text(
                      'No properties posted yet.',
                      style: TextStyle(color: Colors.white70),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _userPostedProperties.length,
                      itemBuilder: (context, index) {
                        final property = _userPostedProperties[index];
                        return Card(
                          color: Colors.white.withOpacity(0.9),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Your custom PropertyCard widget
                                PropertyCard(
                                  property: property,
                                  isFavorited: false,
                                  onFavoriteToggle: (bool newState) {
                                    // Handle favorite toggle if needed
                                  },
                                ),

                                const SizedBox(height: 4),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // Currently does nothing
                                      // Could later link to WhatsApp Business
                                    },
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Request to Edit'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

          const SizedBox(height: 24),

          // Sign out button
          Center(
            child: ElevatedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      _currentUser = null;
      _welcomeMessage = null;
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
          _welcomeMessage = 'Welcome, ${user.email}';
        });
        _loadUserData(); // Reload user data after successful login
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
              onPressed: () async {
                await _sendCode();
              },
              child: const Text('Send Code'),
            ),
            TextButton(
              onPressed: () async {
                await _signInWithPhone();
              },
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
          _welcomeMessage = 'Welcome, ${user.phoneNumber}';
        });
        // Refresh user data
        _loadUserData();
        if (mounted) {
          Navigator.pop(context); // Close the dialog
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to sign in with phone number');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
