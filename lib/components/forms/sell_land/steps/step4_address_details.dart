// lib/components/widgets/steps/step3_address_details.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/property_provider.dart';
import '../../../../utils/validators.dart';
import 'package:flutter/services.dart';

class Step4AddressDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const Step4AddressDetails({Key? key, required this.formKey}) : super(key: key);

  @override
  _Step4AddressDetailsState createState() => _Step4AddressDetailsState();
}

class _Step4AddressDetailsState extends State<Step4AddressDetails> {
  late TextEditingController _pincodeController;
  late TextEditingController _houseNoController;
  late TextEditingController _propertyNameController;
  late TextEditingController _addressController;
  late TextEditingController _taluqMandalController;
  late TextEditingController _districtController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _villageController;

  late final VoidCallback _listener;
  late final PropertyProvider _propertyProvider;

  late FocusNode _pincodeFocusNode;

  @override
  void initState() {
    super.initState();

    // grab your provider once
    _propertyProvider = Provider.of<PropertyProvider>(context, listen: false);

    // whenever the provider changes, sync our controllers
    _listener = () => _updateControllers(_propertyProvider);
    _propertyProvider.addListener(_listener);

    // pin code focus → fire a lookup on blur
    _pincodeFocusNode = FocusNode();
    _pincodeFocusNode.addListener(() {
      if (!_pincodeFocusNode.hasFocus && _pincodeController.text.trim().length == 6) {
        _fetchLocationFromPincode();
      }
    });

    // Initialize controllers from provider...
    _pincodeController = TextEditingController(text: _propertyProvider.pincode);
    _houseNoController = TextEditingController(text: _propertyProvider.houseNo);
    _propertyNameController = TextEditingController(text: _propertyProvider.ventureName ?? '');
    _addressController = TextEditingController(text: _propertyProvider.address ?? '');
    _villageController = TextEditingController(text: _propertyProvider.village ?? '',);
    _taluqMandalController = TextEditingController(text: _propertyProvider.mandal);
    _cityController = TextEditingController(text: _propertyProvider.city);
    _districtController = TextEditingController(text: _propertyProvider.district ?? '');
    _stateController = TextEditingController(text: _propertyProvider.state);
  }

  void _updateControllers(PropertyProvider provider) {
    if (!mounted) return;
    if (_pincodeController.text != provider.pincode) {
      _pincodeController.text = provider.pincode;
    }
    if (_cityController.text != provider.city) {
      _cityController.text = provider.city;
    }
    if (_districtController.text != (provider.district ?? '')) {
      _districtController.text = provider.district ?? '';
    }
    if (_stateController.text != provider.state) {
      _stateController.text = provider.state;
    }
    if (_villageController.text != (provider.village ?? '')) {
      _villageController.text = provider.village ?? '';
    }
    setState(() {});
  }

  Future<void> _fetchLocationFromPincode() async {
    final pin = _pincodeController.text.trim();
    if (pin.length != 6) return;
    try {
      // this will call geocodePincode internally
      await _propertyProvider.setPincode(pin);
      // _updateControllers() will fire via the listener
    } catch (e) {
      debugPrint("PIN lookup failed: $e");
    }
  }

  @override
  void dispose() {
    _propertyProvider.removeListener(_listener);
    _pincodeFocusNode.dispose();
    _pincodeController.dispose();
    _houseNoController.dispose();
    _propertyNameController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _villageController.dispose();
    _taluqMandalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = Provider.of<PropertyProvider>(context);

    return Form(
      key: widget.formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Pincode
              TextFormField(
                controller: _pincodeController,
                focusNode: _pincodeFocusNode, // ✅ Added this
                decoration: const InputDecoration(labelText: 'Pincode'),
                keyboardType: TextInputType.number,
                validator: Validators.pincodeValidator,
                onFieldSubmitted: (_) => _fetchLocationFromPincode(),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: (val) => propertyProvider.setPincode(val),
              ),
              const SizedBox(height: 20),

              // House No
              TextFormField(
                controller: _houseNoController,
                decoration: const InputDecoration(labelText: 'House No'),
                validator: Validators.requiredValidator,
                onChanged: (value) => propertyProvider.setHouseNo(value),
              ),
              const SizedBox(height: 20),

              // Property Name
              // 2) Building/Project/Society Name
              TextFormField(
                controller: _propertyNameController,
                decoration: const InputDecoration(
                  labelText: 'Building / Project / Society (Name)',
                ),
                validator: Validators.requiredValidator,
                onChanged: (value) => propertyProvider.setVentureName(value),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _villageController,
                decoration: const InputDecoration(labelText: 'Village'),
                validator: Validators.requiredValidator,
                onChanged: (value) => propertyProvider.setVillage(value),
              ),
              const SizedBox(height: 20),

              // Taluq / Mandal
              TextFormField(
                controller: _taluqMandalController,
                decoration: const InputDecoration(labelText: 'Taluq / Mandal'),
                validator: Validators.requiredValidator,
                onChanged: (value) => propertyProvider.setTaluqMandal(value),
              ),
              const SizedBox(height: 20),

              // City (read-only)
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                readOnly: true,
              ),
              const SizedBox(height: 20),

              // District (read-only)
              TextFormField(
                controller: _districtController,
                decoration: const InputDecoration(labelText: 'District'),
                readOnly: true,
              ),
              const SizedBox(height: 20),

              // State (read-only)
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State'),
                readOnly: true,
              ),
              const SizedBox(height: 20),

              // Next, Add Price Details button
            ],
          ),
        ),
      ),
    );
  }
}
