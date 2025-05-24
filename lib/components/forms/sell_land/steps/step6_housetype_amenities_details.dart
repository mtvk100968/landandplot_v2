import 'package:flutter/material.dart';

class Step6HousetypeAmenitiesDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final List<String> selectedAmenities;
  final Function(List<String>) onAmenitiesSelected;

  const Step6HousetypeAmenitiesDetails({
    Key? key,
    required this.formKey,
    required this.selectedAmenities,
    required this.onAmenitiesSelected,
  }) : super(key: key);

  @override
  _Step6HousetypeAmenitiesDetailsState createState() => _Step6HousetypeAmenitiesDetailsState();
}

class _Step6HousetypeAmenitiesDetailsState extends State<Step6HousetypeAmenitiesDetails> {
  final List<String> allAmenities = [
    'Lift',
    'Power Backup',
    'Parking',
    '24x7 Water Supply',
    'Gym',
    'Swimming Pool',
    'CCTV',
    'Security Guard',
    'Clubhouse',
    'Children Play Area',
    'Garden',
    'Wi-Fi',
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
      children: allAmenities.map((amenity) {
        return CheckboxListTile(
          title: Text(amenity),
          value: selected.contains(amenity),
          onChanged: (_) => toggleAmenity(amenity),
        );
      }).toList(),
    );
  }
}
