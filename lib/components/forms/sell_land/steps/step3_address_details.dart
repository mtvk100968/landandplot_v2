// lib/components/widgets/steps/step3_address_details.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/property_provider.dart';
import '../../../../utils/validators.dart';
import 'package:flutter/services.dart';

class Step3AddressDetails extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const Step3AddressDetails({Key? key, required this.formKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final propertyProvider = Provider.of<PropertyProvider>(context);

    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Prevent overflow in smaller screens
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pincode Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Pincode',
                ),
                keyboardType: TextInputType.number,
                initialValue: propertyProvider.pincode,
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

              // District Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'District'),
                value: propertyProvider.district != null &&
                        propertyProvider.district!.isNotEmpty
                    ? propertyProvider.district
                    : null,
                items: propertyProvider.districtList.map((district) {
                  return DropdownMenuItem(
                    value: district,
                    child: Text(district),
                  );
                }).toList(),
                onChanged: propertyProvider.pincode.length == 6
                    ? (value) {
                        if (value != null) {
                          propertyProvider.setDistrict(value);
                        }
                      }
                    : null, // Disable if pincode is not entered
                validator: Validators.requiredValidator,
                hint: Text('Select District'),
              ),
              SizedBox(height: 20),

              // Mandal Dropdown
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

              // Village Field
              TextFormField(
                decoration: InputDecoration(labelText: 'Village'),
                initialValue: propertyProvider.village,
                validator: Validators.requiredValidator,
                onChanged: (value) => propertyProvider.setVillage(value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
