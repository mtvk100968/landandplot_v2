// lib/widgets/sell_land_form/sell_land_form.dart
import 'dart:io';
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
    final propertyService =
        Provider.of<PropertyService>(context, listen: false);

    // Gather form data
    // Convert provider data to Property model
    // Assuming you have a Property model defined in property_model.dart

    final property = propertyProvider.toProperty();

    try {
      // Handle media files
      // Convert media URLs to Files if necessary
      // Assuming mediaUrls of imageUrls , videoUrls and documentUrls are file paths
      List<File> images = propertyProvider.imageUrls
          .where((url) =>
              url.endsWith('.jpg') ||
              url.endsWith('.jpeg') ||
              url.endsWith('.png'))
          .map((url) => File(url))
          .toList();

      List<File> videos = propertyProvider.videoUrls
          .where((url) => url.endsWith('.mp4'))
          .map((url) => File(url))
          .toList();

      List<File> documents =
          propertyProvider.documentUrls.map((url) => File(url)).toList();

      String propertyId = await propertyService.addProperty(
        property,
        images,
        videos: videos,
        documents: documents,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Property Listed Successfully! ID: $propertyId')),
      );

      // Optionally, reset the form
      propertyProvider.resetForm();

      // Navigate to another screen if desired
    } catch (e) {
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
