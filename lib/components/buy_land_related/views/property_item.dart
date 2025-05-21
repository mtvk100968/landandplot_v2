// lib/components/buy_land_related/views/property_item.dart
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../models/property_model.dart';

/// Wraps your Property so the cluster‐manager can pull out a LatLng.
class PropertyItem with ClusterItem {
  final Property property;

  PropertyItem(this.property);

  @override
  LatLng get location => LatLng(
    property.latitude,
    property.longitude,
  );
}
