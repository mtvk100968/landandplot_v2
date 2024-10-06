// lib/components/forms/steps/step_property_identification.dart

import 'package:flutter/material.dart';

class StepPropertyIdentification extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String propertyType;
  final TextEditingController surveyNumberController;
  final TextEditingController plotNumbersController;

  const StepPropertyIdentification({
    super.key,
    required this.formKey,
    required this.propertyType,
    required this.surveyNumberController,
    required this.plotNumbersController,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Survey Number Field
          TextFormField(
            controller: surveyNumberController,
            decoration: const InputDecoration(
              labelText: 'Survey Number',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (propertyType != 'Plot') {
                if (value == null || value.isEmpty) {
                  return 'Please enter survey number';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          // Plot Numbers Field (only for Plot type)
          if (propertyType == 'Plot')
            TextFormField(
              controller: plotNumbersController,
              decoration: const InputDecoration(
                labelText: 'Plot Numbers (comma separated)',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (propertyType == 'Plot') {
                  if (value == null || value.isEmpty) {
                    return 'Please enter plot numbers';
                  }
                }
                return null;
              },
            ),
        ],
      ),
    );
  }
}
