// lib/views/property_map_view.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/property_model.dart';
import '../widgets/marker.dart'; // Ensure correct import path

class PropertyMapView extends StatefulWidget {
  final List<Property> properties;

  const PropertyMapView({
    super.key,
    required this.properties,
  });

  @override
  PropertyMapViewState createState() => PropertyMapViewState();
}

class PropertyMapViewState extends State<PropertyMapView> {
  late GoogleMapController mapController;

  // Initialize a Set to store markers
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _addCustomMarkers();
  }

  Future<void> _addCustomMarkers() async {
    Set<Marker> markers = {};

    for (Property property in widget.properties) {
      // Format the price (ensure "L" or "C" is added based on the value)
      final String priceText = _formatPrice(property.totalPrice);

      // Create custom marker with the formatted price (including L/C)
      final BitmapDescriptor customIcon =
          await CustomMarker.createMarker(priceText);

      // Add marker for each property
      markers.add(
        Marker(
          markerId: MarkerId(property.id),
          position: LatLng(property.latitude, property.longitude),
          icon: customIcon,
          infoWindow: InfoWindow(
            title: 'Land Area: ${property.landArea} Sq Yards',
            snippet: 'Price: $priceText',
          ),
        ),
      );
    }

    // Update state to display the markers
    setState(() {
      _markers = markers;
    });
  }

  /// Formats the price to display in 'L' for lakh or 'C' for crore.
  String _formatPrice(double price) {
    if (price >= 10000000) {
      return '${(price / 10000000).toStringAsFixed(1)}C'; // Crore
    } else if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(1)}L'; // Lakh
    } else {
      return price.toStringAsFixed(0); // Below 1 lakh
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _addCustomMarkers(),
      builder: (context, snapshot) {
        // Show a loading indicator until markers are loaded
        if (snapshot.connectionState == ConnectionState.waiting &&
            _markers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading markers'));
        } else {
          return GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(20.5937, 78.9629), // Center of India
              zoom: 5,
            ),
            onMapCreated: _onMapCreated,
            markers: _markers,
          );
        }
      },
    );
  }
}
