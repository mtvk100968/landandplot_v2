// lib/components/widgets/steps/step3_address_details.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/property_provider.dart';
import '../../../../utils/validators.dart';
import 'package:flutter/services.dart';

class Step3AddressDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const Step3AddressDetails({Key? key, required this.formKey})
      : super(key: key);

  @override
  _Step3AddressDetailsState createState() => _Step3AddressDetailsState();
}

class _Step3AddressDetailsState extends State<Step3AddressDetails> {
  late TextEditingController _pincodeController;
  late TextEditingController _addressController; // New controller
  late TextEditingController _districtController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;

  @override
  void initState() {
    super.initState();
    final propertyProvider =
        Provider.of<PropertyProvider>(context, listen: false);
    _pincodeController = TextEditingController(text: propertyProvider.pincode);
    _addressController = TextEditingController(
        text: propertyProvider.address ?? ''); // Initialize
    _districtController =
        TextEditingController(text: propertyProvider.district ?? '');
    _cityController = TextEditingController(text: propertyProvider.city);
    _stateController = TextEditingController(text: propertyProvider.state);

    // Listen to provider changes and update controllers
    propertyProvider.addListener(_updateControllers);
  }

  void _updateControllers() {
    final propertyProvider =
        Provider.of<PropertyProvider>(context, listen: false);

    if (_pincodeController.text != propertyProvider.pincode) {
      _pincodeController.text = propertyProvider.pincode;
    }

    if (_addressController.text != (propertyProvider.address ?? '')) {
      // Update address
      _addressController.text = propertyProvider.address ?? '';
    }

    if (_districtController.text != (propertyProvider.district ?? '')) {
      _districtController.text = propertyProvider.district ?? '';
    }

    if (_cityController.text != propertyProvider.city) {
      _cityController.text = propertyProvider.city;
    }

    if (_stateController.text != propertyProvider.state) {
      _stateController.text = propertyProvider.state;
    }

    // Force rebuild to update mandal dropdown
    setState(() {});
  }

  @override
  void dispose() {
    final propertyProvider =
        Provider.of<PropertyProvider>(context, listen: false);
    propertyProvider.removeListener(_updateControllers);
    _pincodeController.dispose();
    _addressController.dispose(); // Dispose address controller
    _districtController.dispose();
    _cityController.dispose();
    _stateController.dispose();
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
          // Prevent overflow in smaller screens
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pincode Field
              TextFormField(
                controller: _pincodeController,
                decoration: InputDecoration(
                  labelText: 'Pincode',
                ),
                keyboardType: TextInputType.number,
                validator: Validators.pincodeValidator,
                onChanged: (value) {
                  propertyProvider.setPincode(value);
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
              ),
              SizedBox(height: 20),

              // Address Field (New)
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter your address',
                ),
                keyboardType: TextInputType.streetAddress,
                validator:
                    Validators.requiredValidator, // Ensure address is entered
                onChanged: (value) {
                  propertyProvider.setAddress(value);
                },
                maxLines: 3, // Allow multiple lines for address
              ),
              SizedBox(height: 20),

              // Show loading indicator if geocoding is in progress

              if (propertyProvider.isGeocoding)
                Center(child: CircularProgressIndicator()),
              if (!propertyProvider.isGeocoding) ...[
                // City Field (Read-only)
                if (propertyProvider.pincode.length == 6)
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'City',
                    ),
                    readOnly: true,
                  ),
                SizedBox(height: 20),

                // Mandal Dropdown
                if (propertyProvider.district != null &&
                    propertyProvider.district!.isNotEmpty)
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Mandal'),
                    value: propertyProvider.mandal != null &&
                            propertyProvider.mandal!.isNotEmpty
                        ? propertyProvider.mandal
                        : null,
                    items: propertyProvider.mandalList.map((mandal) {
                      return DropdownMenuItem(
                        value: mandal,
                        child: Text(mandal),
                      );
                    }).toList(),
                    onChanged: propertyProvider.district != null
                        ? (value) {
                            if (value != null) {
                              propertyProvider.setMandal(value);
                            }
                          }
                        : null, // Disable if no district selected
                    validator: Validators.requiredValidator,
                    hint: Text('Select Mandal'),
                  ),
                SizedBox(height: 20),

                // District Field (Read-only)
                if (propertyProvider.pincode.length == 6)
                  TextFormField(
                    controller: _districtController,
                    decoration: InputDecoration(
                      labelText: 'District',
                    ),
                    readOnly: true,
                  ),
                SizedBox(height: 20),

                // State Field (Read-only)
                if (propertyProvider.pincode.length == 6)
                  TextFormField(
                    controller: _stateController,
                    decoration: InputDecoration(
                      labelText: 'State',
                    ),
                    readOnly: true,
                  ),
                SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
