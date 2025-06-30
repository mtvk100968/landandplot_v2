// lib/widgets/sell_land_form/sell_land_form.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:landandplot/components/forms/sell_land/steps/step3_extra_details.dart';
import 'package:landandplot/components/forms/sell_land/steps/step4_address_details.dart';
import 'package:landandplot/components/forms/sell_land/steps/step5_map_location.dart';
import 'package:landandplot/components/forms/sell_land/steps/step6_media_upload.dart';
import 'package:landandplot/components/forms/sell_land/steps/step7_housetype_amenities_details.dart';
import 'package:landandplot/components/forms/sell_land/steps/step8_landtype_amenities_details.dart';
import 'package:provider/provider.dart';

import '../../../providers/property_provider.dart';
import '../../../services/property_service.dart';
import '../../../utils/keys.dart';
import '../../../components/bottom_nav_bar.dart';

// Always-present steps:
import './steps/step1_basic_details.dart';
import './steps/step2_property_details.dart'; // ← your new “extra” step

// Conditional amenities steps:

class SellLandForm extends StatefulWidget {
  const SellLandForm({Key? key}) : super(key: key);

  @override
  _SellLandFormState createState() => _SellLandFormState();
}

class _SellLandFormState extends State<SellLandForm> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // We’ll generate 8 keys (max possible pages)
  final List<GlobalKey<FormState>> _formKeys =
  List.generate(8, (_) => GlobalKey<FormState>());

  List<Widget> get _pages {
    final p = Provider.of<PropertyProvider>(context, listen: false);
    final type = p.propertyType.toLowerCase();

    // 1–5 are always shown:
    final pages = <Widget>[
      SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 100,
        ),
        child: Step1BasicDetails(formKey: _formKeys[0]),
      ),
      Step2PropertyDetails(formKey: _formKeys[1]),
      Step3ExtraDetails(formKey: _formKeys[2]),
      Step4AddressDetails(formKey: _formKeys[3]),
      Step5MapLocation(formKey: _formKeys[4]),
    ];

    // 6–8 depend on propertyType:
    if (['plot', 'agri land', 'farm land'].contains(type)) {
      pages.add(
        Padding(
          padding: const EdgeInsets.all(16),
          child: Step8LandtypeAmenitiesDetails(
            formKey: _formKeys[7],
            selectedAmenities: p.agriAmenities,
            onAmenitiesChanged: p.setAgriAmenities,
          ),
        ),
      );
      pages.add(Step6MediaUpload(formKey: _formKeys[5]));
    } else if (['house', 'villa', 'apartment'].contains(type)) {
      pages.add(
        Padding(
          padding: const EdgeInsets.all(16),
          child: Step7HousetypeAmenitiesDetails(
            formKey: _formKeys[6],
            selectedAmenities: p.selectedAmenities,
            onAmenitiesSelected: p.setSelectedAmenities,
          ),
        ),
      );
      pages.add(Step6MediaUpload(formKey: _formKeys[5]));
    } else {
      // everything else just goes straight to media
      pages.add(Step6MediaUpload(formKey: _formKeys[5]));
    }

    return pages;
  }

  int get _totalSteps => _pages.length;

  void _nextPage() {
    if (_currentPage == _totalSteps - 1) {
      _submitForm();
      return;
    }
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
    final p = Provider.of<PropertyProvider>(context, listen: false);
    final service = Provider.of<PropertyService>(context, listen: false);
    final property = p.toProperty();
    final images = p.imageFiles;

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
      final id = await service.addProperty(
        property,
        images,
        videos: p.videoFiles,
        documents: p.documentFiles,
      );
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Property Listed! ID: $id')),
      );
      p.resetForm();

      final bottomNav = bottomNavBarKey.currentState as BottomNavBarState?;
      bottomNav?.switchTab(0);
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
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: pages,
            ),
          ),
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
                  icon: Icon(_currentPage < _totalSteps - 1
                      ? Icons.arrow_forward
                      : Icons.check),
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
