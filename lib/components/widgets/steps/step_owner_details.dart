// lib/components/forms/steps/step_owner_details.dart

import 'package:flutter/material.dart';

class StepOwnerDetails extends StatelessWidget {
  final TextEditingController propertyOwnerController;
  final TextEditingController propertyRegisteredByController;

  const StepOwnerDetails({
    super.key,
    required this.propertyOwnerController,
    required this.propertyRegisteredByController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Property Owner Field
        TextFormField(
          controller: propertyOwnerController,
          decoration: const InputDecoration(
            labelText: 'Property Owner',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null || value.isEmpty
              ? 'Please enter property owner'
              : null,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 10),
        // Property Registered By Field
        TextFormField(
          controller: propertyRegisteredByController,
          decoration: const InputDecoration(
            labelText: 'Property Registered By',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null || value.isEmpty
              ? 'Please enter who registered the property'
              : null,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
