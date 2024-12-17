import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'profile_screen.dart';

class UserRegistration extends StatefulWidget {
  @override
  _UserRegistrationState createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _extraAddressController = TextEditingController();

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;

    if (_currentUser == null) {
      print('No authenticated user.');
      // Navigate to login or show an appropriate message
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen(
            propertyList: [],
            favoritedPropertyIds: [],
            onFavoriteToggle: (String propertyId, bool isFavorited) {  },)
          ),
        );
      });
    } else {
      _phoneController.text = _currentUser!.phoneNumber ?? '';
      _emailController.text = _currentUser!.email ?? '';
    }
  }

  Future<void> _saveUserData() async {
    if (_currentUser != null) {
      try {
        print('Saving user data...');
        // Format the phone number before saving
        String formattedPhoneNumber = formatPhoneNumber(_phoneController.text);
        print('Formatted Phone Number: $formattedPhoneNumber');

        await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).set({
          'name': _nameController.text,
          'email': _emailController.text,
          'phoneNumber': formattedPhoneNumber,
          'city': _cityController.text,
          'state': _stateController.text,
          'district': _districtController.text,
          'pincode': _pincodeController.text,
          'extraAddress': _extraAddressController.text,
        });

        print('User data saved successfully.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              propertyList: [],
              favoritedPropertyIds: [],
              onFavoriteToggle: (propertyId, isFavorited) {},
            ),
          ),
        );
      } catch (e) {
        print('Error saving user data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving user data: $e')),
        );
      }
    } else {
      print('No authenticated user.');
    }
  }

  String formatPhoneNumber(String phoneNumber) {
    if (!phoneNumber.startsWith('+')) {
      return '+91$phoneNumber'; // Assuming a default country code of +91 (India)
    }
    return phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _extraAddressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stateController,
              decoration: const InputDecoration(
                labelText: 'State',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _districtController,
              decoration: const InputDecoration(
                labelText: 'District',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pincodeController,
              decoration: const InputDecoration(
                labelText: 'Pincode',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveUserData,
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
