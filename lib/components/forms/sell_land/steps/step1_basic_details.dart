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

  final propertyTypes = [
    'Plot',
    'Farm Land',
    'Agri Land',
    'House',
    'Villa',
    'Apartment',
    'Development',
    'Commercial Space',
  ];

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

  /// Build a row of ChoiceChips for "Property Type"
  Widget _buildPropertyTypeSelection() {
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final propertyTypeOptions = [
      'Plot',
      'Farm Land',
      'Agri Land',
      'House',
      'Villa',
      'Apartment',
      'Development',
      'Commercial Space',
    ];

    return Wrap(
      spacing: 8.0,
      children: propertyTypeOptions.map((option) {
        final isSelected = (propertyProvider.propertyType == option);
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              propertyProvider.setPropertyType(option);
            }
          },
        );
      }).toList(),
    );
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
              decoration: InputDecoration(
                labelText: 'Your Phone Number',
                prefixText: '+91 ',             // <-- show +91 as a non‐editable prefix
              ),
              keyboardType: TextInputType.number,
              initialValue: propertyProvider.phoneNumber.startsWith('+91')
                  ? propertyProvider.phoneNumber.substring(3)
                  : '',
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,         // only digits
                LengthLimitingTextInputFormatter(10),           // max 10 of them
              ],
              validator: (val) {
                if (val == null || val.length != 10) {
                  return 'Please enter exactly 10 digits';
                }
                return null;
              },
              onChanged: (val) {
                // store your provider with the +91 prefix
                propertyProvider.setPhoneNumber('+91' + val);
              },
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
            // 1) Property Type row
            const Text("Property Type", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildPropertyTypeSelection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
