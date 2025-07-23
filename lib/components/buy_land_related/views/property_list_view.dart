// lib/components/views/property_list_view.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../../models/property_model.dart';
import '../property_card.dart';

typedef FavoriteToggleCallback = void Function(
    String propertyId, bool isFavorited);
typedef PropertyTapCallback = void Function(Property property);

double _distKm(double lat1, double lon1, double lat2, double lon2) {
  const earthR = 6371.0;
  final dLat = (lat2 - lat1) * math.pi / 180.0;
  final dLon = (lon2 - lon1) * math.pi / 180.0;
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1 * math.pi / 180.0) *
          math.cos(lat2 * math.pi / 180.0) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthR * c;
}

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
    required this.onTapProperty,
    this.selectedCity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("🔍 PropertyListView properties count: ${properties.length}");

    // 1) only approved
    final visible = properties.where((p) => p.adminApproved).toList();
    print("✅ Approved properties count: ${visible.length}");

    // 2) empty state
    if (visible.isEmpty) {
      final cityName = selectedCity ?? 'this area';
      return Center(child: Text('No properties found in $cityName.'));
    }

    // Pre-calc favourite points
    final favProps = visible
        .where((p) => favoritedPropertyIds.contains(p.id))
        .toList(growable: false);
    final favPoints =
        favProps.map((p) => [p.latitude, p.longitude]).toList(growable: false);

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    double score(Property p) {
      // Distance to nearest favourite property (km)
      double dist = double.infinity;
      if (favPoints.isNotEmpty) {
        for (final fp in favPoints) {
          final d = _distKm(fp[0], fp[1], p.latitude, p.longitude);
          if (d < dist) dist = d;
        }
      }

      // Recency (days old)
      final ageMs = nowMs - p.createdAt.toDate().millisecondsSinceEpoch;
      final daysOld = ageMs <= 0 ? 0.0 : ageMs / 86400000.0;

      // Weight recency lightly so distance dominates
      return dist.isInfinite ? daysOld : dist + (daysOld * 0.05);
    }

    // 3) smart sort
    final List<Property> sorted = [...visible]..sort((a, b) {
        final sa = score(a);
        final sb = score(b);
        if (sa != sb) return sa.compareTo(sb);

        // tie-breakers
        final aFav = favoritedPropertyIds.contains(a.id);
        final bFav = favoritedPropertyIds.contains(b.id);
        if (aFav != bFav) return aFav ? -1 : 1;

        return b.createdAt.compareTo(a.createdAt); // newest first
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
