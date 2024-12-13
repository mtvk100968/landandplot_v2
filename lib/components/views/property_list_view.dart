// lib/components/views/property_list_view.dart

import 'package:flutter/material.dart';
import '../../../models/property_model.dart';
import '../property_card.dart';

typedef FavoriteToggleCallback = void Function(
    String propertyId, bool isFavorited);

class PropertyListView extends StatelessWidget {
  final List<Property> properties;
  final List<String> favoritedPropertyIds;
  final FavoriteToggleCallback onFavoriteToggle;

  const PropertyListView({
    Key? key,
    required this.properties,
    required this.favoritedPropertyIds,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty) {
      return const Center(
        child: Text('No properties available.'),
      );
    }

    return ListView.builder(
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        final isFavorited = favoritedPropertyIds.contains(property.id);

        return PropertyCard(
          property: property,
          isFavorited: isFavorited,
          onFavoriteToggle: (newIsFavorited) {
            // Pass the property.id along with the new favorited status
            onFavoriteToggle(property.id, newIsFavorited);
          },
        );
      },
    );
  }
}
