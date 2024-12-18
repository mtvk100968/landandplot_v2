// lib/widgets/sell_land_form/sell_land_form.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './steps/step1_basic_details.dart';
import './steps/step2_property_details.dart';
import './steps/step3_address_details.dart';
import './steps/step4_map_location.dart';
import './steps/step5_media_upload.dart';
import 'package:provider/provider.dart';
import '../../../providers/property_provider.dart';
import '../../../services/property_service.dart';
import 'package:flutter/services.dart';

class SellLandForm extends StatefulWidget {
  const SellLandForm({Key? key}) : super(key: key);

  @override
  _SellLandFormState createState() => _SellLandFormState();
}

class _SellLandFormState extends State<SellLandForm> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalSteps = 5;

  // Form Keys for each step
  final List<GlobalKey<FormState>> _formKeys = List.generate(
    5,
        (_) => GlobalKey<FormState>(),
  );

  void _nextPage() {
    // Define the indices of the steps that do not require validation
    const List<int> noValidationSteps = [
      2,
      3
    ]; // Steps 3 and 4 (zero-based index)

    // Determine if the current step requires validation
    bool requiresValidation = !noValidationSteps.contains(_currentPage);

    // Perform validation only if required
    if (!requiresValidation ||
        (_formKeys[_currentPage].currentState?.validate() ?? true)) {
      if (_currentPage < _totalSteps - 1) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      } else {
        _submitForm();
      }
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  Future<void> _submitForm() async {
    final propertyProvider =
    Provider.of<PropertyProvider>(context, listen: false);

    // Ensure all form steps are validated
    bool allValid = true;
    for (var i = 0; i < _formKeys.length; i++) {
      if (!(_formKeys[i].currentState?.validate() ?? false)) {
        print("Validation failed at step: $i");
        allValid = false;
        break;
      }
    }

    if (!allValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    // Check for missing required fields
    if (propertyProvider.latitude == null || propertyProvider.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a location on the map.')),
      );
      return;
    }

    try {
      // Show a loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // Prepare data for submission
      final propertyData = {
        'phoneNumber': propertyProvider.phoneNumber,
        'email': propertyProvider.email.isNotEmpty ? propertyProvider.email : null,
        'name': propertyProvider.name,
        'propertyOwner': propertyProvider.propertyOwner.isNotEmpty ? propertyProvider.propertyOwner : null,
        'propertyType': propertyProvider.propertyType,
        'area': propertyProvider.area,
        'pricePerUnit': propertyProvider.pricePerUnit,
        'totalPrice': propertyProvider.totalPrice,
        'surveyNumber': propertyProvider.surveyNumber,
        'pincode': propertyProvider.pincode,
        'address': propertyProvider.address,
        'district': propertyProvider.district,
        'city': propertyProvider.city,
        'state': propertyProvider.state,
        'latitude': propertyProvider.latitude,
        'longitude': propertyProvider.longitude,
      };

      // Save data to Firestore
      await FirebaseFirestore.instance.collection('properties').add(propertyData);

      // Dismiss the loading indicator
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Property listed successfully!')),
      );

      // Reset form data
      propertyProvider.resetForm();

      // Optionally, navigate to another screen
    } catch (e) {
      // Dismiss the loading indicator
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to list property: $e')),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_currentPage > 0) {
      _prevPage();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Column(
        children: [
          // Progress Indicator
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / _totalSteps,
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                Step1BasicDetails(formKey: _formKeys[0]),
                Step2PropertyDetails(formKey: _formKeys[1]),
                Step3AddressDetails(formKey: _formKeys[2]),
                Step4MapLocation(formKey: _formKeys[3]),
                Step5MediaUpload(formKey: _formKeys[4]),
              ],
            ),
          ),
          // Navigation Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _currentPage > 0
                    ? ElevatedButton.icon(
                  onPressed: _prevPage,
                  icon: Icon(Icons.arrow_back),
                  label: Text('Back'),
                )
                    : SizedBox(),
                ElevatedButton.icon(
                  onPressed: _nextPage,
                  icon: Icon(
                    _currentPage < _totalSteps - 1
                        ? Icons.arrow_forward
                        : Icons.check,
                  ),
                  label: Text(
                    _currentPage < _totalSteps - 1 ? 'Next' : 'Submit',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
