// lib/views/property_map_view.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../models/property_model.dart';
import '../map_related/marker.dart'; // Ensure correct import path
import '../../utils/format.dart';

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
      ClusterManagerId('propertyClusterManager');

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

    _addCustomMarkers();
  }

  Future<void> _addCustomMarkers() async {
    Set<Marker> markers = {};

    for (Property property in widget.properties) {
      // Format the price
      final String priceText =
          formatPrice(property.totalPrice, property.propertyType);

      // Create custom marker with the formatted price
      final BitmapDescriptor customIcon =
          await CustomMarker.createMarker(priceText);

      // Create marker for each property
      markers.add(
        Marker(
          markerId: MarkerId(property.id),
          position: LatLng(property.latitude, property.longitude),
          icon: customIcon,
          infoWindow: InfoWindow(
            title:
                'Land Area: ${property.landArea} ${property.propertyType == 'agri land' ? 'Acres' : 'Sq Yards'}',
            snippet: 'Price: $priceText',
          ),
          // Associate this marker with the ClusterManager
          clusterManagerId: _clusterManagerId,
        ),
      );
    }

    // Update state to display the markers
    setState(() {
      _markers = markers;
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
              myLocationEnabled: true,
              myLocationButtonEnabled: true, // Enable default location button
              // Add the ClusterManager to the GoogleMap widget
              clusterManagers: {_clusterManager},
            );
          }
        });
  }
}
