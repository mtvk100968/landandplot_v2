// lib/components/views/property_list_view.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../property_card.dart';

typedef FavoriteToggleCallback = void Function(
    String propertyId, bool isFavorited);
typedef PropertyTapCallback = void Function(Property property);

class PropertyListView extends StatelessWidget {
  final List<Property> properties;
  final List<String> favoritedPropertyIds;
  final String? selectedCity;
  final FavoriteToggleCallback onFavoriteToggle;
  final PropertyTapCallback onTapProperty;

  const PropertyListView({
    Key? key,
    required this.properties,
    required this.favoritedPropertyIds,
    required this.onFavoriteToggle,
    required this.onTapProperty, // Require the callback in constructor
    this.selectedCity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("🔍 PropertyListView properties count: ${properties.length}");

    if (properties.isEmpty) {
      final cityName = selectedCity ?? 'this area';
      return Center(
        child: Text('No properties found in $cityName.'),
      );
    }

    return ListView.builder(
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        final isFavorited = favoritedPropertyIds.contains(property.id);
        print("Rendering Property: ${property.id}, Property Price: ${property.totalPrice}");

        return PropertyCard(
          property: property,
          isFavorited: isFavorited,
          onFavoriteToggle: (newIsFavorited) {
            // Pass the property.id along with the new favorited status
            onFavoriteToggle(property.id, newIsFavorited);
          },
          onTap: () => onTapProperty(property), // Handle property tap
        );
      },
    );
  }
}
