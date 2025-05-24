import 'package:flutter/material.dart';

class Step7LandtypeAmenitiesDetails extends StatefulWidget {
  final List<String> selectedAmenities;
  final ValueChanged<List<String>> onAmenitiesChanged;

  const Step7LandtypeAmenitiesDetails({
    Key? key,
    required this.selectedAmenities,
    required this.onAmenitiesChanged,
  }) : super(key: key);

  @override
  _Step7LandtypeAmenitiesDetailsState createState() =>
      _Step7LandtypeAmenitiesDetailsState();
}

class _Step7LandtypeAmenitiesDetailsState
    extends State<Step7LandtypeAmenitiesDetails> {
  final List<String> allAmenities = [
    'Fencing',
    'Borewell',
    'Gate',
    'Electricity',
    'Plantation',
  ];

  late List<String> selected;

  @override
  void initState() {
    super.initState();
    selected = List.from(widget.selectedAmenities);
  }

  void _toggle(String amenity) {
    setState(() {
      if (selected.contains(amenity))
        selected.remove(amenity);
      else
        selected.add(amenity);
    });
    widget.onAmenitiesChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: allAmenities.map((amenity) {
        return CheckboxListTile(
          title: Text(amenity),
          value: selected.contains(amenity),
          onChanged: (_) => _toggle(amenity),
        );
      }).toList(),
    );
  }
}
