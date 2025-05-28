import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../providers/property_provider.dart';
import 'package:provider/provider.dart';

class Step7LandtypeAmenitiesDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final List<String> selectedAmenities;
  final ValueChanged<List<String>> onAmenitiesChanged;

  const Step7LandtypeAmenitiesDetails({
    Key? key,
    required this.formKey,
    required this.selectedAmenities,
    required this.onAmenitiesChanged,
  }) : super(key: key);

  @override
  _Step7LandtypeAmenitiesDetailsState createState() =>
      _Step7LandtypeAmenitiesDetailsState();
}

class _Step7LandtypeAmenitiesDetailsState
    extends State<Step7LandtypeAmenitiesDetails> {

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PropertyProvider>(context);

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
          const Text("Agricultural Amenities (String List)", style: TextStyle(fontWeight: FontWeight.bold)),
          ...allAgriAmenities.map((amenity) {
            return CheckboxListTile(
              title: Text(amenity),
              value: widget.selectedAmenities.contains(amenity),
              onChanged: (_) {
                final updated = List<String>.from(widget.selectedAmenities);
                if (updated.contains(amenity)) {
                  updated.remove(amenity);
                } else {
                  updated.add(amenity);
                }
                widget.onAmenitiesChanged(updated);
              },
            );
          }),
        ],
      ),
    );
  }
}
