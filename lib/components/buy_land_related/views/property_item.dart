import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../models/property_model.dart';

/// Wraps your Property so the cluster‐manager can pull out a LatLng.
class PropertyItem {
  final Property property;

  PropertyItem(this.property);

  @override
  LatLng get location => LatLng(
    property.latitude,
    property.longitude,
  );

  @override
  String get geohash => ''; // Optional: You can compute using a geohash lib

  @override
  Property? get item => property;
}
