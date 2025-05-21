// lib/views/property_map_view.dart
import 'dart:math' as math;

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
  final LatLng? center; // Optional parameter to specify initial center

  const PropertyMapView({Key? key, required this.properties, this.center})
      : super(key: key);

  @override
  PropertyMapViewState createState() => PropertyMapViewState();
}

class PropertyMapViewState extends State<PropertyMapView> {
  late GoogleMapController mapController;

  Set<Marker> _markers = {};
  late bool _markersInitialized = false;

  // // default to Hyderabad if location not allowed
  // LatLng _initialCenter = const LatLng(17.3850, 78.4867);

  // Create a ClusterManagerId
  final ClusterManagerId _clusterManagerId = const ClusterManagerId(
    'propertyClusterManager',
  );

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

  }

  Future<void> _addCustomMarkers() async {
    if (_markersInitialized) {
      print("⏭️ Markers already initialized. Skipping...");
      return;
    }

    final seenIds = <String>{};
    final uniqueProps = widget.properties.where((p) => seenIds.add(p.id)).toList();

    Set<Marker> markers = {};
    print("Number of properties: ${widget.properties.length}");
    print("Number of unique properties: ${uniqueProps.length}");

    if (uniqueProps.isEmpty) {
      print("⚠️ No properties found!");
      return;
    }

    for (Property property in uniqueProps) {
      print(
        "📍 Processing property: ${property.id}, (${property.latitude}, ${property.longitude})",
      );

      if (property.latitude == 0 || property.longitude == 0) {
        print("⚠️ Skipping property with invalid coordinates: ${property.id}");
        continue;
      }

      final String priceText = formatPrice(property.totalPrice);
      final BitmapDescriptor customIcon = await CustomMarker.createMarker(priceText);

      markers.add(
        Marker(
          markerId: MarkerId(property.id),
          position: LatLng(property.latitude, property.longitude),
          icon: customIcon,
          onTap: () => _showPropertyCard(property),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = markers;
        _markersInitialized = true;
        print("✅ Markers added: ${_markers.length}");
      });
    }
  }

  void _onClusterTap(Cluster cluster) async {
    // Get current zoom level
    double currentZoomLevel = await mapController.getZoomLevel();
    double newZoomLevel = currentZoomLevel + 2;

    // Prevent excessive zooming
    if (newZoomLevel > 18.0) newZoomLevel = 18.0;

    // Animate camera to zoom into the cluster
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: cluster.position, zoom: newZoomLevel),
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
    print("✅ Google Map created");
    setState(() {
      mapController = controller;
    });

    // Future.delayed(const Duration(milliseconds: 500), () {
    print("🔹 Adding markers after map creation");
    // Add markers first
    _addCustomMarkers().then((_) {
      // Move camera **after** markers are added
      _moveToInitialLocation();
    });
  }

  void _moveToInitialLocation() {
    if (widget.center != null) {
      print("🔍 Moving to user-selected location: ${widget.center}");
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(widget.center!, 9), // ✅ Zoom level closer
      );
    } else if (_markers.isNotEmpty) {
      // If markers exist, calculate the bounds dynamically
      LatLngBounds bounds = _getBoundsForMarkers(_markers);
      mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    } else {
      print("🌍 Defaulting to India map.");
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          const LatLng(20.5937, 78.9629),
          9,
        ), // India default
      );
    }
  }

  LatLngBounds _getBoundsForMarkers(Set<Marker> markers) {
    // India's general latitude and longitude bounds
    const double minIndiaLat = 6.0;
    const double maxIndiaLat = 38.0;
    const double minIndiaLng = 68.0;
    const double maxIndiaLng = 97.0;

    double? minLat, maxLat, minLng, maxLng;

    for (Marker marker in markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;

      // Skip markers outside India
      if (lat < minIndiaLat || lat > maxIndiaLat || lng < minIndiaLng || lng > maxIndiaLng) {
        print("🛑 Skipping out-of-bound marker at ($lat, $lng)");
        continue;
      }

      minLat = (minLat == null) ? lat : math.min(minLat, lat);
      maxLat = (maxLat == null) ? lat : math.max(maxLat, lat);
      minLng = (minLng == null) ? lng : math.min(minLng, lng);
      maxLng = (maxLng == null) ? lng : math.max(maxLng, lng);
    }

    // Fallback if all were out of India
    if (minLat == null || maxLat == null || minLng == null || maxLng == null) {
      return LatLngBounds(
        southwest: const LatLng(20.5937 - 0.5, 78.9629 - 0.5),
        northeast: const LatLng(20.5937 + 0.5, 78.9629 + 0.5),
      );
    }

    return LatLngBounds(
      southwest: LatLng(minLat - 0.05, minLng - 0.05),
      northeast: LatLng(maxLat + 0.05, maxLng + 0.05),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox.expand(
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: const CameraPosition(
            target: LatLng(20.5937, 78.9629),
            zoom: 8,
          ),
          onMapCreated: _onMapCreated,
          markers: _markers, // ✅ Show only markers
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          compassEnabled: true, // ✅ Enables the Compass
          zoomControlsEnabled: true, // ✅ Shows Zoom Buttons),
        ),
      ),
    );
  }
}