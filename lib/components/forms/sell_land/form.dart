// lib/widgets/sell_land_form/sell_land_form.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:landandplot/components/forms/sell_land/steps/step7_landtype_amenities_details.dart';
import 'package:provider/provider.dart';
import '../../../providers/property_provider.dart';
import '../../../services/property_service.dart';

// Steps
import './steps/step1_basic_details.dart';
import './steps/step2_property_details.dart';
import './steps/step3_address_details.dart';
import './steps/step4_map_location.dart';
import './steps/step5_media_upload.dart';
import './steps/step6_housetype_amenities_details.dart';

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

  // we now need up to 6 form‐keys (the extra one is for amenities)
  final List<GlobalKey<FormState>> _formKeys = List.generate(
    7,
        (_) => GlobalKey<FormState>(),
  );

  // build pages dynamically
  List<Widget> get _pages {
    final propertyProvider =
    Provider.of<PropertyProvider>(context, listen: false);
    final type = propertyProvider.propertyType.toLowerCase();

    // always these first four steps:
    final pages = <Widget>[
      SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 100,
        ),
        child: Step1BasicDetails(formKey: _formKeys[0]),
      ),
      Step2PropertyDetails(formKey: _formKeys[1]),
      Step3AddressDetails(formKey: _formKeys[2]),
      Step4MapLocation(formKey: _formKeys[3]),
    ];

    // insert amenities **only** for Villa/Apartment
// — for agri/farm land insert:
    if (type == 'plot' || type == 'agri land' || type == 'farm land') {
      pages.add(
        Padding(
          padding: const EdgeInsets.all(16),
          child: Step7LandtypeAmenitiesDetails(
            formKey: _formKeys[6],
            selectedAmenities: propertyProvider.agriAmenities,
            onAmenitiesChanged: propertyProvider.setAgriAmenities,
          ),
        ),
      );
      pages.add(Step5MediaUpload(formKey: _formKeys[5]));
    } else if (['house','villa','apartment'].contains(type)) {
      pages.add(
        Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKeys[4],
            child: Step6HousetypeAmenitiesDetails(
              formKey: _formKeys[4],
              selectedAmenities: propertyProvider.selectedAmenities,
              onAmenitiesSelected: propertyProvider.setSelectedAmenities,
            ),
          ),
        ),
      );
      // finally media‐upload is page #5
      pages.add(Step5MediaUpload(formKey: _formKeys[5]));
    } else {
      // otherwise media‐upload is page #4
      pages.add(Step5MediaUpload(formKey: _formKeys[4]));
    }

    return pages;
  }

  int get _totalSteps => _pages.length;

  void _nextPage() {
    // if we're on the last page, submit:
    if (_currentPage == _totalSteps - 1) {
      _submitForm();
      return;
    }

    // otherwise, validate current form if it has one:
    final formKey = _formKeys[_currentPage];
    if (formKey.currentState?.validate() ?? true) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
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

    final property = propertyProvider.toProperty();
    final images = propertyProvider.imageFiles;
    final videos = propertyProvider.videoFiles;
    final docs = propertyProvider.documentFiles;

    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final propertyId = await propertyService.addProperty(
        property,
        images,
        videos: videos,
        documents: docs,
      );
      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Property Listed! ID: $propertyId')),
      );
      propertyProvider.resetForm();

      final bottomNavState =
      bottomNavBarKey.currentState as BottomNavBarState?;
      bottomNavState?.switchTab(0);
    } catch (e) {
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
    final pages = _pages;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Column(
        children: [
          // Progress
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / _totalSteps,
            ),
          ),

          // PageView
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: pages,
            ),
          ),

          // Navigation
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  ElevatedButton.icon(
                    onPressed: _prevPage,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                  ),
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
