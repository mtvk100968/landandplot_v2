import 'package:flutter/material.dart';

class Step7HousetypeAmenitiesDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final List<String> selectedAmenities;
  final Function(List<String>) onAmenitiesSelected;

  const Step7HousetypeAmenitiesDetails({
    Key? key,
    required this.formKey,
    required this.selectedAmenities,
    required this.onAmenitiesSelected,
  }) : super(key: key);

  @override
  _Step7HousetypeAmenitiesDetailsState createState() => _Step7HousetypeAmenitiesDetailsState();
}

class _Step7HousetypeAmenitiesDetailsState extends State<Step7HousetypeAmenitiesDetails> {
  final List<String> allAmenities = [
    'elevator_access',
    'Power Backup',
    'covered_or_garage_parking',
    'Guest Parking',
    '24x7 Water Supply',
    'Gym',
    'Swimming Pool',
    'CCTV',
    'Security Guard',
    'Clubhouse',
    'Children Play Area',
    'Garden',
    'Wi-Fi',
    'shopping_center',
    'gas_pipeline',
    'controlled_access_entry',
    'recycling_and_compost_facilities',
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
