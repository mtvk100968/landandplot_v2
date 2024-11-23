// lib/components/widgets/steps/step1_basic_details.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../providers/property_provider.dart';
import '../../../../utils/validators.dart';

class Step1BasicDetails extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const Step1BasicDetails({Key? key, required this.formKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final propertyProvider = Provider.of<PropertyProvider>(context);

    return SingleChildScrollView(
        child: Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Your Phone Number'),
              keyboardType: TextInputType.phone,
              initialValue: propertyProvider.phoneNumber.isNotEmpty
                  ? propertyProvider.phoneNumber
                  : '+91',
              validator: Validators.phoneValidator,
              onChanged: (value) => propertyProvider.setPhoneNumber(value),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\+?[0-9]*$')),
                LengthLimitingTextInputFormatter(13),
              ],
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(labelText: 'Your Name'),
              initialValue: propertyProvider.name,
              validator: Validators.requiredValidator,
              onChanged: (value) => propertyProvider.setName(value),
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(labelText: 'Property Owner Name'),
              initialValue: propertyProvider.propertyOwnerName,
              validator: Validators.requiredValidator,
              onChanged: (value) =>
                  propertyProvider.setPropertyOwnerName(value),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Property Type'),
              value: propertyProvider.propertyType,
              items: ['Plot', 'Farm Land', 'Agri Land']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type[0].toUpperCase() +
                            type.substring(1).replaceAll('_', ' ')),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  propertyProvider.setPropertyType(value);
                }
              },
              validator: Validators.requiredValidator,
            ),
          ],
        ),
      ),
    ));
  }
}
