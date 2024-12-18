// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/views/property_card.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/property_model.dart';
import '../services/user_service.dart';

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
  AppUser? _appUser;
  List<Property> _postedProperties = [];
  bool _isLoading = false;

  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _checkLoginStatus() {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _fetchAppUser();
    }
  }

  Future<void> _fetchAppUser() async {
    setState(() {
      _isLoading = true;
    });
    try {
      AppUser? user = await _userService.getUserById(_currentUser!.uid);
      if (user != null) {
        setState(() {
          _appUser = user;
          _welcomeMessage =
          'Welcome, ${_appUser!.name ?? _appUser!.email ?? _appUser!.phoneNumber}';
        });
        await _fetchPostedProperties();
      } else {
        _showErrorSnackBar('User data not found.');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load user data.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchPostedProperties() async {
    if (_appUser == null || _appUser!.postedPropertyIds.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<Property> properties =
      await _userService.getPropertiesByIds(_appUser!.postedPropertyIds);
      setState(() {
        _postedProperties = properties;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load posted properties.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildProfileDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: TextStyle(
              fontStyle:
              value == 'Not provided' ? FontStyle.italic : FontStyle.normal,
              color: value == 'Not provided' ? Colors.grey : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog() {
    final TextEditingController nameController =
    TextEditingController(text: _appUser?.name);
    final TextEditingController phoneController =
    TextEditingController(text: _appUser?.phoneNumber);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                const Text(
                  'If you change your phone number, we will need to verify it again.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String newName = nameController.text.trim();
                String newPhone = phoneController.text.trim();
                Navigator.pop(context);
                await _updateUserInfo(newName, newPhone);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _verifyNewPhoneNumber(String newPhone, String newName) async {
    // Trigger phone verification flow
    _showErrorSnackBar('Sending verification code to $newPhone...');

    await signInWithPhoneNumber(
      newPhone,
          (String verId) {
        setState(() {
          _verificationId = verId;
        });
        _showVerificationDialog(newName, newPhone);
      },
          (FirebaseAuthException e) {
        _showErrorSnackBar('Failed to verify phone number: ${e.message}');
      },
    );
  }

  void _showVerificationDialog(String newName, String newPhone) {
    final TextEditingController verifyCodeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verify Phone'),
          content: TextField(
            controller: verifyCodeController,
            decoration: const InputDecoration(labelText: 'Verification Code'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String code = verifyCodeController.text.trim();
                if (code.isEmpty) {
                  _showErrorSnackBar('Please enter the verification code.');
                  return;
                }
                Navigator.pop(context);
                await _completePhoneVerification(newName, newPhone, code);
              },
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _completePhoneVerification(
      String newName, String newPhone, String code) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: code,
      );
      User? verifiedUser = await signInWithPhoneAuthCredential(credential);

      if (verifiedUser != null && verifiedUser.phoneNumber == newPhone) {
        // Update user data after successful verification
        _appUser = AppUser(
          uid: _appUser!.uid,
          name: newName.isEmpty ? null : newName,
          email: _appUser!.email,
          phoneNumber: newPhone.isEmpty ? null : newPhone,
          postedPropertyIds: _appUser!.postedPropertyIds,
          favoritedPropertyIds: _appUser!.favoritedPropertyIds,
          inTalksPropertyIds: _appUser!.inTalksPropertyIds,
          boughtPropertyIds: _appUser!.boughtPropertyIds,
        );

        await _userService.updateUser(_appUser!);
        setState(() {
          _welcomeMessage =
          'Welcome, ${_appUser!.name ?? _appUser!.email ?? _appUser!.phoneNumber}';
        });
        _showErrorSnackBar('Profile updated successfully.');
      } else {
        _showErrorSnackBar('Phone verification failed.');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to verify phone number.');
    }
  }

  Future<void> _updateUserInfo(String newName, String newPhone) async {
    if (_appUser == null || _currentUser == null) return;

    // If phone number changed and is not empty, go through verification
    if (newPhone.isNotEmpty &&
        newPhone != _appUser!.phoneNumber &&
        newPhone != _currentUser!.phoneNumber) {
      await _verifyNewPhoneNumber(newPhone, newName);
    } else {
      // Phone not changed or empty, update name only
      _appUser = AppUser(
        uid: _appUser!.uid,
        name: newName.isEmpty ? null : newName,
        email: _appUser!.email,
        phoneNumber: _appUser!.phoneNumber,
        postedPropertyIds: _appUser!.postedPropertyIds,
        favoritedPropertyIds: _appUser!.favoritedPropertyIds,
        inTalksPropertyIds: _appUser!.inTalksPropertyIds,
        boughtPropertyIds: _appUser!.boughtPropertyIds,
      );

      try {
        await _userService.updateUser(_appUser!);
        setState(() {
          _welcomeMessage =
          'Welcome, ${_appUser!.name ?? _appUser!.email ?? _appUser!.phoneNumber}';
        });
        _showErrorSnackBar('Profile updated successfully.');
      } catch (e) {
        _showErrorSnackBar('Failed to update profile.');
      }
    }
  }

  Widget _buildLoginButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Welcome to LANDANDPLOT',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => _signInWithGoogle(),
          icon: const Icon(Icons.account_circle),
          label: const Text('Sign in with Google'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () => _showPhoneNumberDialog(),
          icon: const Icon(Icons.phone),
          label: const Text('Sign in with Phone Number'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_welcomeMessage != null)
            Text(
              _welcomeMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Profile Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  _buildProfileDetailRow(
                    'Name',
                    _appUser?.name?.isNotEmpty == true
                        ? _appUser!.name!
                        : 'Not provided',
                  ),
                  _buildProfileDetailRow(
                    'Email',
                    _appUser?.email?.isNotEmpty == true
                        ? _appUser!.email!
                        : 'Not provided',
                  ),
                  _buildProfileDetailRow(
                    'Phone',
                    _appUser?.phoneNumber?.isNotEmpty == true
                        ? _appUser!.phoneNumber!
                        : 'Not provided',
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _showEditUserDialog,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          if (_postedProperties.isNotEmpty) ...[
            const Text(
              'Your Posted Properties',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _postedProperties.length,
              itemBuilder: (context, index) {
                final property = _postedProperties[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PropertyCard(
                          property: property,
                          isFavorited: _appUser!.favoritedPropertyIds
                              .contains(property.id),
                          onFavoriteToggle: (isFavorited) {
                            _toggleFavorite(isFavorited as bool, property.id);
                          }, onImageTap: () {  },
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => _editDetails(property),
                          child: const Text(
                            'Edit Details',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ] else
            const Center(
              child: Text(
                'You have not posted any properties yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(bool isFavorited, String propertyId) {
    if (isFavorited) {
      _userService.addFavoriteProperty(_currentUser!.uid, propertyId);
    } else {
      _userService.removeFavoriteProperty(_currentUser!.uid, propertyId);
    }
    setState(() {
      if (isFavorited) {
        _appUser!.favoritedPropertyIds.add(propertyId);
      } else {
        _appUser!.favoritedPropertyIds.remove(propertyId);
      }
    });
  }

  void _editDetails(Property property) {
    _showErrorSnackBar('Edit Details feature is not available yet.');
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      _currentUser = null;
      _welcomeMessage = null;
      _appUser = null;
      _postedProperties = [];
    });
  }

  Future<void> _signInWithGoogle() async {
    try {
      User? user = await signInWithGoogle();
      if (user != null && mounted) {
        setState(() {
          _currentUser = user;
          _welcomeMessage =
          'Welcome, ${_appUser?.name ?? user.email ?? user.phoneNumber}';
        });
        await _fetchAppUser();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to sign in with Google.');
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
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _codeController,
                decoration:
                const InputDecoration(labelText: 'Verification Code'),
                keyboardType: TextInputType.number,
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
            setState(() {
              _verificationId = verId;
            });
          }
        },
            (FirebaseAuthException e) {
          _showErrorSnackBar('Failed to verify phone number: ${e.message}');
        },
      );
      _showErrorSnackBar('Verification code sent!');
    } catch (e) {
      _showErrorSnackBar('Failed to send verification code.');
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
          _welcomeMessage = 'Welcome, ${_appUser?.name ?? user.phoneNumber ?? user.email}';
        });
        await _fetchAppUser();
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to sign in with phone number.');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LANDANDPLOT'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: _currentUser == null
              ? _buildLoginButtons()
              : _buildProfilePage(),
        ),
      ),
    );
  }
}