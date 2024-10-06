// lib/components/forms/sell_land_form.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/steps/step_basic_details.dart';
import '../widgets/steps/step_area_pricing.dart';
import '../widgets/steps/step_property_identification.dart';
import '../widgets/steps/step_place_marker.dart';
import '../widgets/steps/step_address_details.dart';
import '../widgets/steps/step_other_details.dart';
import '../widgets/steps/step_upload_media.dart';
import '../widgets/steps/step_upload_documents.dart';
import '../widgets/steps/step_owner_details.dart';
import '../../models/sell_land_form_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class SellLandForm extends StatefulWidget {
  final Function(SellLandFormData) onSubmit;

  const SellLandForm({super.key, required this.onSubmit});

  @override
  SellLandFormState createState() => SellLandFormState();
}

class SellLandFormState extends State<SellLandForm> {
  int _currentStep = 0;

  // Form Keys for each step
  final List<GlobalKey<FormState>> _formKeys = List.generate(
    9,
    (index) => GlobalKey<FormState>(),
  );

  // Step 1: Basic Details
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();

  // Step 2: Area & Pricing
  String _propertyType = 'Agricultural Land';
  final TextEditingController _landAreaController = TextEditingController();
  final TextEditingController _pricePerUnitController = TextEditingController();
  final TextEditingController _totalPriceController = TextEditingController();

  // Step 3: Property Identification
  final TextEditingController _surveyNumberController = TextEditingController();
  final TextEditingController _plotNumbersController = TextEditingController();

  // Step 4: Place Marker
  Marker? _selectedMarker;
  LatLng? _selectedLocation;

  // Step 5: Address Details
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _mandalController = TextEditingController();
  final TextEditingController _townController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  // Step 6: Other Details
  bool _roadAccess = false;
  String _roadType = 'National Highways';
  final TextEditingController _roadWidthController = TextEditingController();
  String _landFacing = 'North';

  // Step 7: Upload Media
  List<File> _images = [];
  List<File> _videos = [];

  // Step 8: Upload Documents
  List<File> _documents = [];

  // Step 9: Owner Details
  final TextEditingController _propertyOwnerController =
      TextEditingController();
  final TextEditingController _propertyRegisteredByController =
      TextEditingController();

  // Image Picker and File Picker instances
  final ImagePicker _picker = ImagePicker();

  // Method to handle location selection from Step 4
  void _onLocationSelected(LatLng position) {
    setState(() {
      _selectedMarker = Marker(
        markerId: const MarkerId('selected-location'),
        position: position,
        draggable: true,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        onDragEnd: (newPosition) {
          setState(() {
            _selectedLocation = newPosition;
          });
        },
      );
      _selectedLocation = position;
    });
  }

  // Image Picker Method
  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();

      if (!mounted) return;

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        setState(() {
          _images = pickedFiles.map((xfile) => File(xfile.path)).toList();
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  // Video Picker Method
  Future<void> _pickVideos() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _videos = result.paths.map((path) => File(path!)).toList();
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking videos: $e')),
      );
    }
  }

  // Document Picker Method
  Future<void> _pickDocuments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _documents = result.paths.map((path) => File(path!)).toList();
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking documents: $e')),
      );
    }
  }

  // Method to validate and proceed to the next step
  void _nextStep() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      // Additional validations for specific steps
      if (_currentStep == 3 && _selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a location on the map')),
        );
        return;
      }

      if (_currentStep == 6 && _images.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload at least one image')),
        );
        return;
      }

      setState(() {
        if (_currentStep < 8) {
          _currentStep += 1;
        } else {
          _submitForm();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the required fields')),
      );
    }
  }

  // Method to go back to the previous step
  void _prevStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep -= 1;
      }
    });
  }

  // Method to handle form submission
  void _submitForm() {
    // Ensure all forms are valid
    bool allValid = true;
    for (var key in _formKeys) {
      if (!key.currentState!.validate()) {
        allValid = false;
      }
    }

    if (allValid && _selectedLocation != null && _images.isNotEmpty) {
      // Process Plot Numbers: Convert comma-separated string to List<String>
      List<String>? plotNumbersList;
      if (_plotNumbersController.text.trim().isNotEmpty) {
        plotNumbersList = _plotNumbersController.text
            .trim()
            .split(',')
            .map((e) => e.trim())
            .where((element) => element.isNotEmpty)
            .toList();
      }

      // Create a SellLandFormData instance with all collected data
      SellLandFormData formData = SellLandFormData(
        name: _nameController.text.trim(),
        mobileNumber: _mobileNumberController.text.trim(),
        propertyType: _propertyType,
        landArea: double.parse(_landAreaController.text.trim()),
        pricePerUnit: double.parse(_pricePerUnitController.text.trim()),
        totalPrice: double.parse(_totalPriceController.text.trim()),
        surveyNumber: _surveyNumberController.text.trim().isNotEmpty
            ? _surveyNumberController.text.trim()
            : null,
        plotNumbers: _plotNumbersController.text.trim().isNotEmpty
            ? _plotNumbersController.text.trim()
            : null,
        selectedLocation: _selectedLocation!,
        pincode: _pincodeController.text.trim(),
        village: _villageController.text.trim(),
        mandal: _mandalController.text.trim(),
        town: _townController.text.trim(),
        district: _districtController.text.trim(),
        state: _stateController.text.trim(),
        roadAccess: _roadAccess,
        roadType: _roadType,
        roadWidth: double.parse(_roadWidthController.text.trim()),
        landFacing: _landFacing,
        images: _images,
        videos: _videos,
        documents: _documents,
        propertyOwner: _propertyOwnerController.text.trim(),
        propertyRegisteredBy: _propertyRegisteredByController.text.trim(),
      );

      // Pass the collected data back to the parent via the onSubmit callback
      widget.onSubmit(formData);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _mobileNumberController.dispose();
    _landAreaController.dispose();
    _pricePerUnitController.dispose();
    _totalPriceController.dispose();
    _surveyNumberController.dispose();
    _plotNumbersController.dispose();
    _pincodeController.dispose();
    _villageController.dispose();
    _mandalController.dispose();
    _townController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _roadWidthController.dispose();
    _propertyOwnerController.dispose();
    _propertyRegisteredByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stepper(
      type: StepperType.vertical,
      currentStep: _currentStep,
      onStepContinue: _nextStep,
      onStepCancel: _prevStep,
      controlsBuilder: (BuildContext context, ControlsDetails details) {
        final isLastStep = _currentStep == 8;
        return Row(
          children: <Widget>[
            ElevatedButton(
              onPressed: details.onStepContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.green, // Updated from 'primary' to 'backgroundColor'
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(isLastStep ? 'Submit' : 'Next'),
            ),
            const SizedBox(width: 10),
            if (_currentStep > 0)
              IconButton(
                onPressed: details.onStepCancel,
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
                color:
                    Colors.grey, // Optional: Set the color to match your theme
              ),
          ],
        );
      },
      steps: [
        // Step 1: Basic Details
        Step(
          title: const Text('Basic Details'),
          isActive: _currentStep >= 0,
          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          content: StepBasicDetails(
            formKey: _formKeys[0],
            nameController: _nameController,
            mobileNumberController: _mobileNumberController,
          ),
        ),
        // Step 2: Area & Pricing
        Step(
          title: const Text('Area & Pricing'),
          isActive: _currentStep >= 1,
          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          content: StepAreaPricing(
            formKey: _formKeys[1],
            propertyType: _propertyType,
            onPropertyTypeChanged: (value) {
              setState(() {
                _propertyType = value ?? _propertyType;
              });
            },
            landAreaController: _landAreaController,
            pricePerUnitController: _pricePerUnitController,
            totalPriceController: _totalPriceController,
          ),
        ),
        // Step 3: Property Identification
        Step(
          title: const Text('Property Identification'),
          isActive: _currentStep >= 2,
          state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          content: StepPropertyIdentification(
            formKey: _formKeys[2],
            propertyType: _propertyType,
            surveyNumberController: _surveyNumberController,
            plotNumbersController: _plotNumbersController,
          ),
        ),
        // Step 4: Place Marker
        Step(
          title: const Text('Place Marker'),
          isActive: _currentStep >= 3,
          state: _currentStep > 3 ? StepState.complete : StepState.indexed,
          content: StepPlaceMarker(
            mapController: null, // Handled internally
            selectedMarker: _selectedMarker,
            onMapTapped: _onLocationSelected,
          ),
        ),
        // Step 5: Address Details
        Step(
          title: const Text('Address Details'),
          isActive: _currentStep >= 4,
          state: _currentStep > 4 ? StepState.complete : StepState.indexed,
          content: StepAddressDetails(
            formKey: _formKeys[4],
            pincodeController: _pincodeController,
            villageController: _villageController,
            mandalController: _mandalController,
            townController: _townController,
            districtController: _districtController,
            stateController: _stateController,
            onPincodeSubmitted: () {
              // Implement pincode lookup if needed
              // For example, auto-fill district and state based on pincode
            },
          ),
        ),
        // Step 6: Other Details
        Step(
          title: const Text('Other Details'),
          isActive: _currentStep >= 5,
          state: _currentStep > 5 ? StepState.complete : StepState.indexed,
          content: StepOtherDetails(
            formKey: _formKeys[5],
            roadAccess: _roadAccess,
            onRoadAccessChanged: (value) {
              setState(() {
                _roadAccess = value;
              });
            },
            roadType: _roadType,
            onRoadTypeChanged: (value) {
              setState(() {
                _roadType = value ?? _roadType;
              });
            },
            roadWidthController: _roadWidthController,
            landFacing: _landFacing,
            onLandFacingChanged: (value) {
              setState(() {
                _landFacing = value ?? _landFacing;
              });
            },
          ),
        ),
        // Step 7: Upload Media
        Step(
          title: const Text('Upload Media'),
          isActive: _currentStep >= 6,
          state: _currentStep > 6 ? StepState.complete : StepState.indexed,
          content: StepUploadMedia(
            images: _images,
            videos: _videos,
            onPickImages: _pickImages,
            onPickVideos: _pickVideos,
            onRemoveImage: (index) {
              setState(() {
                _images.removeAt(index);
              });
            },
            onRemoveVideo: (index) {
              setState(() {
                _videos.removeAt(index);
              });
            },
          ),
        ),
        // Step 8: Upload Documents
        Step(
          title: const Text('Upload Documents'),
          isActive: _currentStep >= 7,
          state: _currentStep > 7 ? StepState.complete : StepState.indexed,
          content: StepUploadDocuments(
            documents: _documents,
            onPickDocuments: _pickDocuments,
            onRemoveDocument: (index) {
              setState(() {
                _documents.removeAt(index);
              });
            },
          ),
        ),
        // Step 9: Owner Details
        Step(
          title: const Text('Owner Details'),
          isActive: _currentStep >= 8,
          state: _currentStep == 8 ? StepState.editing : StepState.indexed,
          content: StepOwnerDetails(
            propertyOwnerController: _propertyOwnerController,
            propertyRegisteredByController: _propertyRegisteredByController,
          ),
        ),
      ],
    );
  }
}
