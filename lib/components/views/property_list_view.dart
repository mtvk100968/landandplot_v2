import 'package:flutter/material.dart';
import '../../../models/property_model.dart';
import '../cards/property_card.dart';

class PropertyListView extends StatelessWidget {
  final List<Property> properties;

  const PropertyListView({
    super.key,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        return PropertyCard(
            property: property); // Use PropertyCard for each property
      },
    );
  }
}
