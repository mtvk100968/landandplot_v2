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

    // 1) show only approved
    final visible = properties.where((p) => p.adminApproved).toList();
    print("✅ Approved properties count: ${visible.length}");

    // 2) empty state
    if (visible.isEmpty) {
      final cityName = selectedCity ?? 'this area';
      return Center(child: Text('No properties found in $cityName.'));
    }

    // 3) sort the visible list
    final List<Property> sorted = [...visible]..sort((a, b) {
        final aFav = favoritedPropertyIds.contains(a.id);
        final bFav = favoritedPropertyIds.contains(b.id);
        if (aFav != bFav) return aFav ? -1 : 1;
        return b.createdAt.compareTo(a.createdAt);
      });

    return ListView.builder(
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final property = sorted[index];
        final isFavorited = favoritedPropertyIds.contains(property.id);
        return PropertyCard(
          property: property,
          isFavorited: isFavorited,
          onFavoriteToggle: (newIsFavorited) {
            onFavoriteToggle(property.id, newIsFavorited);
          },
          onTap: () => onTapProperty(property),
        );
      },
    );
  }
}
