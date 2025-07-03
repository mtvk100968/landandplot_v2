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
  late PropertyProvider _propertyProvider;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController propertyOwnerName = TextEditingController();
  final TextEditingController _reraController = TextEditingController();

  AppUser? currentUser;

    bool get _showReraField {
        return [
          'Plot',
          'Apartment',
          'Villa',
          'House',
          'Farm Land',
        ].contains(_propertyProvider.propertyType);
      }

  final propertyTypes = [
    'Plot',
    'Agri Land',
    'Farm Land',
    'Apartment',
    'House',
    'Villa',
    'Commercial',
    'Development',
  ];

  @override
  void initState() {
    super.initState();
    // grab your provider once
    _propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    _reraController.text = _propertyProvider.reraNo ?? '';

    // now you can initialize phone controller from it
    final full = _propertyProvider.phoneNumber;
    final local = full.startsWith('91') ? full.substring(3) : full;
    _phoneController.text = local;
    _fetchCurrentUser();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    propertyOwnerName.dispose();
    _emailController.dispose();
    _reraController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // ① strip off 91 before writing into the controller:
      final rawAuth = user.phoneNumber ?? '';
      _phoneController.text =
          rawAuth.startsWith('91') ? rawAuth.substring(3) : rawAuth;

      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final su = AppUser.fromDocument(doc.data()!);
          setState(() {
            currentUser = su;

            // ② again strip 91 when coming from Firestore:
            final rawFs = su.phoneNumber ?? '';
            _phoneController.text =
                rawFs.startsWith('+91') ? rawFs.substring(3) : rawFs;

            _emailController.text = su.email ?? '';
            _nameController.text = su.name ?? '';
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
      'Agri Land',
      'Farm Land',
      'Apartment',
      'House',
      'Villa',
      'Commercial',
      'Development',
    ];

    return Wrap(
      spacing: 8.0,
      children: propertyTypeOptions.map((option) {
        final isSelected = (propertyProvider.propertyType == option);
        return ChoiceChip(
          label: Text(option),
          selected: propertyProvider.propertyType == option,
          onSelected: (selected) {
            if (selected) propertyProvider.setPropertyType(option);
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
              controller: _phoneController,
              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: 'Phone',
                prefixText: '+91 ', // ← fixed, non‐editable prefix
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // only digits
                LengthLimitingTextInputFormatter(10), // max 10 of them
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
              decoration: InputDecoration(
                labelText: 'Property Owner Name',
                hintText: 'Optional',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              initialValue: propertyProvider.propertyOwnerName,
              onChanged: (value) => propertyProvider.setPropertyOwnerName(value),
              inputFormatters: [
                capitalizeWordsInputFormatter(),
              ],
              // no validator ⇒ it’s optional
            ),

            SizedBox(height: 20),

            // 1) Property Type row
            const Text("Property Type",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildPropertyTypeSelection(),


            const SizedBox(height: 20),
            // ───────────── RERA # ─────────────
            if (_showReraField) ...[
              const Text(
                'RERA Number (optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reraController,
                decoration: const InputDecoration(
                  hintText: 'e.g. RERA/KA/RERA1234567',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  // store in provider (null if empty)
                  propertyProvider.setReraNo(
                    val.trim().isEmpty ? null : val.trim(),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
