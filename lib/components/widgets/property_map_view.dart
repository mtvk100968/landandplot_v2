import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/property_model.dart';

class PropertyMapView extends StatefulWidget {
  final List<Property> properties;

  const PropertyMapView({
    super.key,
    required this.properties,
  });

  @override
  _PropertyMapViewState createState() => _PropertyMapViewState();
}

class _PropertyMapViewState extends State<PropertyMapView> {
  late GoogleMapController mapController;

  // Convert properties to map markers
  Set<Marker> _buildMarkers(List<Property> properties) {
    return properties
        .map(
          (property) => Marker(
            markerId: MarkerId(property.id),
            position: LatLng(property.latitude, property.longitude),
            infoWindow: InfoWindow(
              title: 'Land Area: ${property.landArea} Sq Yards',
              snippet: 'Price: \$${property.landPrice}',
            ),
          ),
        )
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(20.5937, 78.9629), // Default to India
        zoom: 5,
      ),
      onMapCreated: (controller) {
        mapController = controller;
      },
      markers: _buildMarkers(widget.properties),
    );
  }
}
