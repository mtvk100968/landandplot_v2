// lib/views/property_map_view.dart

import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../models/property_model.dart';
import '../../map_related/marker.dart'; // Ensure correct import path
import '../../../utils/format.dart';
import '../property_card2.dart';
import '../../../screens/property_details_screen.dart';

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

  // default to Hyderabad if location not allowed
  LatLng _initialCenter = const LatLng(17.3850, 78.4867);

  // Create a ClusterManagerId
  final ClusterManagerId _clusterManagerId =
      const ClusterManagerId('propertyClusterManager');

  // Create a ClusterManager
  late ClusterManager _clusterManager;

  @override
  void initState() {
    super.initState();

    // Initialize ClusterManager
    _clusterManager = ClusterManager(
      clusterManagerId: _clusterManagerId,
      onClusterTap: _onClusterTap,
    );

    // Wait for the first frame before adding markers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addCustomMarkers();
    });
  }

  Future<void> _addCustomMarkers() async {
    Set<Marker> markers = {};
    print("Number of properties: ${widget.properties.length}");

    for (Property property in widget.properties) {
      // Format the price
      final String priceText = property.totalPrice != null
          ? formatPrice(property.totalPrice!)
          : 'N/A';

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
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

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

    // attempt to center on user, else Hyderabad
    _determinePosition().then((pos) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(pos.latitude, pos.longitude),
            zoom: 12,
          ),
        ),
      );
    }).catchError((_) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _initialCenter, zoom: 10),
        ),
      );
    });
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
