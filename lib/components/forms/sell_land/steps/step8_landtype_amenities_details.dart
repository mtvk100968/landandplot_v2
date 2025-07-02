import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Step8LandtypeAmenitiesDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final List<String> selectedAmenities;
  final ValueChanged<List<String>> onAmenitiesSelected;

  const Step8LandtypeAmenitiesDetails({
    Key? key,
    required this.formKey,
    required this.selectedAmenities,
    required this.onAmenitiesSelected,
  }) : super(key: key);

  @override
  _Step8LandtypeAmenitiesDetailsState createState() =>
      _Step8LandtypeAmenitiesDetailsState();
}

class _Step8LandtypeAmenitiesDetailsState
    extends State<Step8LandtypeAmenitiesDetails> {
  final List<String> allAgriAmenities = [
    'Fencing',
    'Borewell',
    'Gate',
    'Electricity',
    'Plantation',
    'farm_house_constructed',
  ];

  late List<String> selected;

  @override
  void initState() {
    super.initState();
    selected = List<String>.from(widget.selectedAmenities);
  }

  void toggleAmenity(String amenity) {
    setState(() {
      if (selected.contains(amenity)) {
        selected.remove(amenity);
      } else {
        selected.add(amenity);
      }
    });
    widget.onAmenitiesSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: allAgriAmenities.map((amenity) {
        return CheckboxListTile(
          title: Text(amenity),
          value: selected.contains(amenity),
          onChanged: (_) => toggleAmenity(amenity),
        );
      }).toList(),
    );
  }
}
