// lib/components/forms/sell_land/steps/step9_commercial_amenities.dart

import 'package:flutter/material.dart';

class Step9CommercialAmenitiesDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final List<String> selectedAmenities;
  final Function(List<String>) onAmenitiesSelected;

  const Step9CommercialAmenitiesDetails({
    Key? key,
    required this.formKey,
    required this.selectedAmenities,
    required this.onAmenitiesSelected,
  }) : super(key: key);

  @override
  _Step9CommercialAmenitiesDetailsState createState() =>
      _Step9CommercialAmenitiesDetailsState();
}

class _Step9CommercialAmenitiesDetailsState
    extends State<Step9CommercialAmenitiesDetails> {
  // Friendly labels on the left, but store the keys if you prefer:
  final Map<String,String> allAmenities = {
    'Lift'            : 'lift',
    'Toilets'         : 'toilets',
    'Parking'         : 'parking',
    'Security'        : 'security',
    'Housekeeping'    : 'housekeeping',
    'Power Backup'    : 'power_backup',
    'CCTV'            : 'cctv',
    'Fire Safety'     : 'fire_safety',
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
    );
  }
}
