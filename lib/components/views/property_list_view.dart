import 'package:flutter/material.dart';
import '../../../models/property_model.dart';
import '../cards/property_card.dart';

class PropertyListView extends StatelessWidget {
  final List<Property> properties;
  final Function(Property) onFavoriteToggle;

  const PropertyListView({
    Key? key,
    required this.properties,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        return PropertyCard(
          property: property,
          onFavoriteToggle: onFavoriteToggle,  // Pass the method to PropertyCard
          isFavorited: property.isFavorited,   // Pass the favorite status
        );
      },
    );
  }
}