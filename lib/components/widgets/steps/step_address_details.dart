// lib/components/forms/steps/step_address_details.dart

import 'package:flutter/material.dart';

class StepAddressDetails extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController pincodeController;
  final TextEditingController villageController;
  final TextEditingController mandalController;
  final TextEditingController townController;
  final TextEditingController districtController;
  final TextEditingController stateController;
  final Function() onPincodeSubmitted;

  const StepAddressDetails({
    Key? key,
    required this.formKey,
    required this.pincodeController,
    required this.villageController,
    required this.mandalController,
    required this.townController,
    required this.districtController,
    required this.stateController,
    required this.onPincodeSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Pincode Field
          TextFormField(
            controller: pincodeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Pincode',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (value) {
              if (value.length == 6) {
                onPincodeSubmitted();
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter pincode';
              }
              if (value.length != 6) {
                return 'Pincode must be 6 digits';
              }
              if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                return 'Enter a valid pincode';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          // Village Field
          TextFormField(
            controller: villageController,
            decoration: const InputDecoration(
              labelText: 'Village',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter village';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          // Mandal Field
          TextFormField(
            controller: mandalController,
            decoration: const InputDecoration(
              labelText: 'Mandal',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter mandal';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          // Town Field
          TextFormField(
            controller: townController,
            decoration: const InputDecoration(
              labelText: 'Town',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter town';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          // District Field
          TextFormField(
            controller: districtController,
            decoration: const InputDecoration(
              labelText: 'District',
              border: OutlineInputBorder(),
            ),
            readOnly: true,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'District not fetched';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          // State Field
          TextFormField(
            controller: stateController,
            decoration: const InputDecoration(
              labelText: 'State',
              border: OutlineInputBorder(),
            ),
            readOnly: true,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'State not fetched';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
