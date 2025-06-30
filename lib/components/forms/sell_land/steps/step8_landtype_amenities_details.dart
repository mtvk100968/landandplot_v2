import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../providers/property_provider.dart';
import 'package:provider/provider.dart';

class Step8LandtypeAmenitiesDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final List<String> selectedAmenities;
  final ValueChanged<List<String>> onAmenitiesChanged;

  const Step8LandtypeAmenitiesDetails({
    Key? key,
    required this.formKey,
    required this.selectedAmenities,
    required this.onAmenitiesChanged,
  }) : super(key: key);

  @override
  _Step8LandtypeAmenitiesDetailsState createState() =>
      _Step8LandtypeAmenitiesDetailsState();
}

class _Step8LandtypeAmenitiesDetailsState
    extends State<Step8LandtypeAmenitiesDetails> {
  @override
  Widget build(BuildContext context) {
    final propertyProvider = context.watch<PropertyProvider>();
    final selected = propertyProvider.agriAmenities;
    final allAgriAmenities = [
      'Fencing',
      'Borewell',
      'Gate',
      'Electricity',
      'Plantation',
      'farm_house_constructed',
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Agricultural Amenities", style: TextStyle(fontWeight: FontWeight.bold)),
          ...allAgriAmenities.map((amenity) {
            return CheckboxListTile(
              title: Text(amenity),
              value: selected.contains(amenity),
              onChanged: (_) {
                if (selected.contains(amenity)) {
                  propertyProvider.setAgriAmenities(
                    List.from(selected)..remove(amenity),
                  );
                } else {
                  propertyProvider.setAgriAmenities(
                    List.from(selected)..add(amenity),
                  );
                }
              },
            );
          }),
        ],
      ),
    );
  }
}