// lib/components/forms/steps/step_area_pricing.dart

import 'package:flutter/material.dart';

class StepAreaPricing extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String propertyType;
  final Function(String?) onPropertyTypeChanged;
  final TextEditingController landAreaController;
  final TextEditingController pricePerUnitController;
  final TextEditingController totalPriceController;

  const StepAreaPricing({
    Key? key,
    required this.formKey,
    required this.propertyType,
    required this.onPropertyTypeChanged,
    required this.landAreaController,
    required this.pricePerUnitController,
    required this.totalPriceController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String areaLabel;
    String pricePerUnitLabel;

    if (propertyType == 'Agricultural Land') {
      areaLabel = 'Area (Acres)';
      pricePerUnitLabel = 'Price per Acre';
    } else {
      areaLabel = 'Area (Sq. Yards)';
      pricePerUnitLabel = 'Price per Sq. Yard';
    }

    return Form(
      key: formKey,
      child: Column(
        children: [
          // Property Type Dropdown
          DropdownButtonFormField<String>(
            value: propertyType,
            decoration: const InputDecoration(
              labelText: 'Type of Property',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Agricultural Land',
                child: Text('Agricultural Land'),
              ),
              DropdownMenuItem(
                value: 'Farm Land',
                child: Text('Farm Land'),
              ),
              DropdownMenuItem(
                value: 'Plot',
                child: Text('Plot'),
              ),
            ],
            onChanged: onPropertyTypeChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select property type';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          // Land Area Field
          TextFormField(
            controller: landAreaController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: areaLabel,
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter land area';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          // Price Per Unit Field
          TextFormField(
            controller: pricePerUnitController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: pricePerUnitLabel,
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter price per unit';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          // Total Price Field
          TextFormField(
            controller: totalPriceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Total Price',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter total price';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
