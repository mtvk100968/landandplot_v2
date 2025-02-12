// lib/views/property_map_view.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../models/property_model.dart';
import '../map_related/marker.dart'; // Ensure correct import path
import '../../utils/format.dart';
import '../property_card2.dart';
import '../../screens/property_details_screen.dart';

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

  Set<Marker> _markers = {}; // Standard markers

  // Create a ClusterManagerId
  final ClusterManagerId _clusterManagerId =
      const ClusterManagerId('propertyClusterManager');

  // Create a ClusterManager
  late ClusterManager _clusterManager;

  @override
  void initState() {
    super.initState();

    // Initialize ClusterManager with the ClusterManagerId and onClusterTap callback
    _clusterManager = ClusterManager(
      clusterManagerId: _clusterManagerId,
      onClusterTap: _onClusterTap,
    );
  }

  Future<void> _addCustomMarkers() async {
    Set<Marker> markers = {};

    for (Property property in widget.properties) {
      // Format the price
      final String priceText = formatPrice(property.totalPrice);

      // Create custom marker with the formatted price
      final BitmapDescriptor customIcon =
          await CustomMarker.createMarker(priceText);

      // Create marker for each property
      markers.add(
        Marker(
          markerId: MarkerId(property.id),
          position: LatLng(property.latitude, property.longitude),
          icon: customIcon,
          onTap: () => _showPropertyCard(property),
          // Associate this marker with the ClusterManager
          clusterManagerId: _clusterManagerId,
        ),
      );
    }

    // Update state to display the markers
    setState(() {
      _markers = markers;
      print("Markers added: ${_markers.length}");
    });
  }

  // // Callback when a cluster is tapped
  void _onClusterTap(Cluster cluster) async {
    // Retrieve the current camera position
    final LatLng currentCenter = await mapController.getLatLng(
      ScreenCoordinate(
        x: (MediaQuery.of(context).size.width / 2).round(),
        y: (MediaQuery.of(context).size.height / 2).round(),
      ),
    );

    // Define the new zoom level
    final double newZoomLevel = 12.0; // Adjust this value as needed

    // Animate the camera to the cluster's position with the new zoom level
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: cluster.position,
          zoom: newZoomLevel,
        ),
      ),
    );
  }

  void _showPropertyCard(Property property) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return PropertyCard2(
          property: property,
          isFavorited: false, // Update with your favorite logic if needed
          onFavoriteToggle: (bool newValue) {
            // Implement your favorite toggle logic here
          },
          onTap: () {
            // Navigate to the property details screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PropertyDetailsScreen(property: property),
              ),
            );
          },
        );
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    // Ensure markers are added after the map is created
    _addCustomMarkers();

    // Adjust initial zoom if needed
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(20.5937, 78.9629),
          zoom: 10,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.white,
        child: SizedBox.expand(
          child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: const CameraPosition(
              target: LatLng(20.5937, 78.9629), // Center of India
              zoom: 5,
            ),
            onMapCreated: _onMapCreated,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true, // Enable default location button
            clusterManagers: {_clusterManager}, // Ensure this works correctly
          ),
        ),
      ),
    );
  }
}
