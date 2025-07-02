// lib/components/forms/sell_land/steps/step9_development_amenities.dart

import 'package:flutter/material.dart';

class Step10DevelopmentAmenitiesDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final List<String> selectedAmenities;
  final Function(List<String>) onAmenitiesSelected;

  const Step10DevelopmentAmenitiesDetails({
    Key? key,
    required this.formKey,
    required this.selectedAmenities,
    required this.onAmenitiesSelected,
  }) : super(key: key);

  @override
  _Step10DevelopmentAmenitiesDetailsState createState() =>
      _Step10DevelopmentAmenitiesDetailsState();
}

class _Step10DevelopmentAmenitiesDetailsState
    extends State<Step10DevelopmentAmenitiesDetails> {
  final Map<String, String> allAmenities = {
    'Road Access': 'road_access',
    'Water Supply': 'water_supply',
    'Electricity': 'electricity',
    'Drainage': 'drainage',
    'Boundary Fencing': 'boundary_fencing',
    'Soil Testing': 'soil_testing',
    'Street Lighting': 'street_lighting',
    'Legal Approvals': 'legal_approvals',
    'Green Spaces': 'green_spaces',
  };

  late List<String> selected;

  @override
  void initState() {
    super.initState();
    selected = List.from(widget.selectedAmenities);
  }

  void _toggle(String key) {
    setState(() {
      if (selected.contains(key))
        selected.remove(key);
      else
        selected.add(key);
    });
    widget.onAmenitiesSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: allAmenities.entries.map((e) {
            return CheckboxListTile(
              title: Text(e.key),
              value: selected.contains(e.value),
              onChanged: (_) => _toggle(e.value),
            );
          }).toList(),
        ),
      ),
    );
  }
}