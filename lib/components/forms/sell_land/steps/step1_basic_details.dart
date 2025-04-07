// lib/components/widgets/steps/step1_basic_details.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../providers/property_provider.dart';
import '../../../../utils/validators.dart';
import '../../../../utils/format.dart';
import '../../../../models/user_model.dart';

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
    final propertyProvider = Provider.of<PropertyProvider>(context);
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Your Phone Number'),
              keyboardType: TextInputType.phone,
              initialValue: propertyProvider.phoneNumber.isNotEmpty
                  ? propertyProvider.phoneNumber
                  : '+91',
              validator: Validators.phoneValidator,
              onChanged: (value) => propertyProvider.setPhoneNumber(value),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\+?[0-9]*$')),
                LengthLimitingTextInputFormatter(13),
              ],
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(labelText: 'Your Name'),
              initialValue: propertyProvider.name,
              validator: Validators.requiredValidator,
              onChanged: (value) => propertyProvider.setName(value),
              inputFormatters: [
                capitalizeWordsInputFormatter(),
              ],
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(labelText: 'Property Owner Name'),
              initialValue: propertyProvider.propertyOwnerName,
              validator: Validators.requiredValidator,
              onChanged: (value) =>
                  propertyProvider.setPropertyOwnerName(value),
              inputFormatters: [
                capitalizeWordsInputFormatter(),
              ],
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Property Type'),
              value: propertyProvider.propertyType,
              items: ['Plot', 'Farm Land', 'Agri Land']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type[0].toUpperCase() +
                            type.substring(1).replaceAll('_', ' ')),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  propertyProvider.setPropertyType(value);
                }
              },
              validator: Validators.requiredValidator,
            ),
          ],
        ),
      ),
    );
  }
}
