// lib/components/forms/steps/step_other_details.dart

import 'package:flutter/material.dart';

class StepOtherDetails extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool roadAccess;
  final Function(bool) onRoadAccessChanged;
  final String roadType;
  final Function(String?) onRoadTypeChanged;
  final TextEditingController roadWidthController;
  final String landFacing;
  final Function(String?) onLandFacingChanged;

  const StepOtherDetails({
    Key? key,
    required this.formKey,
    required this.roadAccess,
    required this.onRoadAccessChanged,
    required this.roadType,
    required this.onRoadTypeChanged,
    required this.roadWidthController,
    required this.landFacing,
    required this.onLandFacingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Road Access Switch
          SwitchListTile(
            title: const Text('Road Access'),
            value: roadAccess,
            onChanged: onRoadAccessChanged,
          ),
          const SizedBox(height: 10),
          // Road Type Dropdown
          DropdownButtonFormField<String>(
            value: roadType,
            decoration: const InputDecoration(
              labelText: 'Road Type',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'National Highways',
                child: Text('National Highways'),
              ),
              DropdownMenuItem(
                value: 'State Highways',
                child: Text('State Highways'),
              ),
              DropdownMenuItem(
                value: 'Expressways',
                child: Text('Expressways'),
              ),
              DropdownMenuItem(
                value: 'Bypass Roads',
                child: Text('Bypass Roads'),
              ),
              DropdownMenuItem(
                value: 'ORR Roads',
                child: Text('ORR Roads'),
              ),
              DropdownMenuItem(
                value: 'RRR Roads',
                child: Text('RRR Roads'),
              ),
              DropdownMenuItem(
                value: 'Tar Roads',
                child: Text('Tar Roads'),
              ),
              DropdownMenuItem(
                value: 'Soil Roads',
                child: Text('Soil Roads'),
              ),
            ],
            onChanged: onRoadTypeChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select road type';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          // Road Width Field
          TextFormField(
            controller: roadWidthController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Road Width (in feet)',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter road width';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          // Land Facing Dropdown
          DropdownButtonFormField<String>(
            value: landFacing,
            decoration: const InputDecoration(
              labelText: 'Land Facing',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'North',
                child: Text('North'),
              ),
              DropdownMenuItem(
                value: 'South',
                child: Text('South'),
              ),
              DropdownMenuItem(
                value: 'East',
                child: Text('East'),
              ),
              DropdownMenuItem(
                value: 'West',
                child: Text('West'),
              ),
            ],
            onChanged: onLandFacingChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select land facing direction';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
