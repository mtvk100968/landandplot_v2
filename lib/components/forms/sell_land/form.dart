// lib/widgets/sell_land_form/sell_land_form.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/property_provider.dart';
import '../../../services/property_service.dart';
import 'package:flutter/services.dart';

// Steps
import './steps/step1_basic_details.dart';
import './steps/step2_property_details.dart';
import './steps/step3_address_details.dart';
import './steps/step4_map_location.dart';
import './steps/step5_media_upload.dart';

// For switching tabs after successful submit
import '../../../utils/keys.dart';
import '../../../components/bottom_nav_bar.dart';

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
    ]; // Steps 3 (index 2) and 4 (index 3)

    // Determine if the current step requires validation
    bool requiresValidation = !noValidationSteps.contains(_currentPage);

    // Perform validation only if required
    if (!requiresValidation ||
        (_formKeys[_currentPage].currentState?.validate() ?? true)) {
      if (_currentPage < _totalSteps - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  Future<void> _submitForm() async {
    final propertyProvider =
        Provider.of<PropertyProvider>(context, listen: false);
    final propertyService =
        Provider.of<PropertyService>(context, listen: false);

    // Gather form data from the provider
    final property = propertyProvider.toProperty();

    // Retrieve media files directly from the provider
    List<File> images = propertyProvider.imageFiles;
    List<File> videos = propertyProvider.videoFiles;
    List<File> documents = propertyProvider.documentFiles;

    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image.')),
      );
      return;
    }

    try {
      // Show a loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Upload property with media files
      String propertyId = await propertyService.addProperty(
        property,
        images,
        videos: videos,
        documents: documents,
      );

      // Dismiss the loading indicator
      Navigator.of(context, rootNavigator: true).pop();

      // Notify user of success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Property Listed Successfully! ID: $propertyId')),
      );

      // Optionally reset the provider’s form data
      propertyProvider.resetForm();

      // Switch to the Buy Land tab (index 0)
      final bottomNavState = bottomNavBarKey.currentState as BottomNavBarState?;
      if (bottomNavState != null) {
        bottomNavState.switchTab(0);
      }
    } catch (e) {
      // Dismiss the loading indicator
      Navigator.of(context, rootNavigator: true).pop();

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
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 100,
                  ),
                  child: Step1BasicDetails(formKey: _formKeys[0]),
                ),
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
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back'),
                      )
                    : const SizedBox(),
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
