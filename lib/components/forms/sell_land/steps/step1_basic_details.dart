// lib/components/widgets/steps/step1_basic_details.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../../models/user_model.dart';
import '../../../../providers/property_provider.dart';

class Step1BasicDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const Step1BasicDetails({Key? key, required this.formKey}) : super(key: key);

  @override
  _Step1BasicDetailsState createState() => _Step1BasicDetailsState();
}

class _Step1BasicDetailsState extends State<Step1BasicDetails> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Attempt to fetch phone number from Firebase Auth
      _phoneController.text = user.phoneNumber ?? '';

      try {
        // Fetch additional details from Firestore
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            currentUser = AppUser.fromDocument(doc.data()!);
            _emailController.text = currentUser?.email ?? '';
            _phoneController.text = currentUser?.phoneNumber ??
                user.phoneNumber ??
                ''; // Use Firestore as fallback
            _nameController.text = currentUser?.name ?? '';
          });
        }
      } catch (e) {
        print("Error fetching Firestore user data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Wrap content here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Step 1: Basic Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Your Phone Number",
                  prefixText: "+91",
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Your Email'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Your Name",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ownerNameController,
                decoration: const InputDecoration(
                  labelText: "Property Owner Name",
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                items: const [
                  DropdownMenuItem(
                      value: "Agri Land", child: Text("Agri Land")),
                  DropdownMenuItem(value: "Farm Land", child: Text("Farm")),
                  DropdownMenuItem(value: "Plot", child: Text("Plot")),
                  DropdownMenuItem(value: "House", child: Text("House")),
                  DropdownMenuItem(
                      value: "Apartment", child: Text("Apartment")),
                ],
                onChanged: (value) {
                  if (value != null) {
                    Provider.of<PropertyProvider>(context, listen: false)
                        .setPropertyType(value);
                  }
                },
                decoration: const InputDecoration(
                  labelText: "Property Type",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a property type';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}