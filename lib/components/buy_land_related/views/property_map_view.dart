//
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart'
    as gpi;
import '../../../../models/property_model.dart';
import '../../map_related/cluster_marker.dart';
import '../../map_related/marker.dart'; // your CustomMarker helper
import '../../../utils/format.dart';
import '../property_card2.dart';
import '../../../screens/property_details_screen.dart';

class PropertyMapView extends StatefulWidget {
  final List<Property> properties;
  final gpi.LatLng? center; // Optional parameter to specify initial center

  const PropertyMapView({Key? key, required this.properties, this.center})
      : super(key: key);

  @override
  PropertyMapViewState createState() => PropertyMapViewState();
}

class PropertyMapViewState extends State<PropertyMapView> {
  late GoogleMapController _mapController;
  Map<String, List<Property>> _buckets = {};
  Set<Marker> _markers = {};
  late bool _markersInitialized = false;
  bool _clustersBuilt = false;
  LatLng? _initialPosition;

  // Create a ClusterManagerId
  final ClusterManagerId _clusterManagerId = const ClusterManagerId(
    'propertyClusterManager',
  );
  late ClusterManager _clusterManager;

  @override
  void initState() {
    super.initState();

    // Initialize ClusterManager
    _clusterManager = ClusterManager(
      clusterManagerId: _clusterManagerId,
      onClusterTap: _onClusterTap,
    );

    // _setInitialLocation();
  }

  // Future<void> _setInitialLocation() async {
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) return;

  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.deniedForever ||
  //         permission == LocationPermission.denied) {
  //       return;
  //     }
  //   }

  //   final pos = await Geolocator.getCurrentPosition();
  //   setState(() {
  //     _initialPosition = LatLng(pos.latitude, pos.longitude);
  //   });
  // }

  void _onClusterTap(Cluster cluster) async {
    // Get current zoom level
    double currentZoomLevel = await _mapController.getZoomLevel();
    double newZoomLevel = currentZoomLevel + 2;

    // Prevent excessive zooming
    if (newZoomLevel > 18.0) newZoomLevel = 18.0;

    // Animate camera to zoom into the cluster
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: cluster.position, zoom: newZoomLevel),
      ),
    );
  }

  Future<void> _buildClusters() async {
    // 1) choose how many decimals to bucket by based on zoom level:
    final zoom = await _mapController.getZoomLevel();
    // at zoom < 8, round to 0 decimals (~100 km buckets)
    // at zoom < 12, round to 1 decimal (~10 km buckets)
    // zoom 0–7.999… → use toStringAsFixed(0) (buckets of about 100 km)
    // zoom 8.0–11.999… → use toStringAsFixed(1) (buckets of about 10 km)
    // otherwise 2 decimals (~1 km)

    final precision = zoom < 8
        ? 0 // 100 km buckets
        : zoom < 12
            ? 1 // 10 km buckets
            : zoom < 15
                ? 2 // 1 km buckets
                : 3; // 100 m buckets

    // 2) group into buckets
    final buckets = <String, List<Property>>{};
    for (final p in widget.properties) {
      final key = '${p.latitude.toStringAsFixed(precision)}'
          ':${p.longitude.toStringAsFixed(precision)}';
      buckets.putIfAbsent(key, () => []).add(p);
    }

    // 3) decide your threshold for “show a circle”
    const int circleThreshold = 10; // now any bucket ≥3 gets a cluster

    final newMarkers = <Marker>{};
    for (final group in buckets.values) {
      if (group.length >= circleThreshold) {
        // draw ONE circle
        final avgLat =
            group.map((p) => p.latitude).reduce((a, b) => a + b) / group.length;
        final avgLng = group.map((p) => p.longitude).reduce((a, b) => a + b) /
            group.length;

        // --- draw one cluster circle ---
        final icon = await ClusterMarker.create(group.length);
        newMarkers.add(
          Marker(
            markerId: MarkerId('cluster_${avgLat}_$avgLng'),
            position: LatLng(avgLat, avgLng),
            icon: icon,
            onTap: () => _openClusterBounds(group),
          ),
        );
      } else {
        // fewer than threshold → draw individual green rectangles
        for (final p in group) {
          final icon =
              await CustomMarker.createMarker(formatPrice(p.totalPrice));
          newMarkers.add(Marker(
            markerId: MarkerId(p.id),
            position: LatLng(p.latitude, p.longitude),
            icon: icon,
            onTap: () => _showPropertyCard(p),
          ));
        }
      }
    }

    setState(() => _markers = newMarkers);
  }

  void _openClusterBounds(List<Property> group) {
    double minLat = group.first.latitude, maxLat = group.first.latitude;
    double minLng = group.first.longitude, maxLng = group.first.longitude;

    for (final p in group) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 60),
    );
  }

  void _showPropertyCard(Property property) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return PropertyCard2(
          property: property,
          isFavorited: false,
          onFavoriteToggle: (bool newValue) {},
          onTap: () {
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

  Future<void> _addCustomMarkers() async {
    if (_markersInitialized) {
      print("⏭️ Markers already initialized. Skipping...");
      return;
    }

    final seenIds = <String>{};
    final uniqueProps =
        widget.properties.where((p) => seenIds.add(p.id)).toList();

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

      final String priceText = formatPrice(property.totalPrice ?? 0.0);
      final BitmapDescriptor customIcon =
          await CustomMarker.createMarker(priceText);

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

  // void _onMapCreated(GoogleMapController ctrl) async {
  //   _mapController = ctrl;
  //   if (_initialPosition != null) {
  //     _mapController.animateCamera(
  //       CameraUpdate.newLatLngZoom(_initialPosition!, 14),
  //     );
  //   }

  //   // Move to the initial location first
  //   _moveToInitialLocation();

  //   // Now safely build clusters (mapController is ready)
  //   await _buildClusters();
  // }

  void _onMapCreated(GoogleMapController controller) {
    print("✅ Google Map created");
    setState(() {
      _mapController = controller;
    });

    // Future.delayed(const Duration(milliseconds: 500), () {
    print("🔹 Adding markers after map creation");
    // Add markers first
    _addCustomMarkers().then((_) {
      // Move camera **after** markers are added
      _moveToInitialLocation();
    });
  }

  /// Put this inside your PropertyMapViewState class:
  /// When the user taps a cluster marker, show a sheet listing its items.
  void _showClusterList(List<Property> group) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        padding: const EdgeInsets.all(16),
        children: group.map((p) {
          return ListTile(
            title: Text(p.name),
            subtitle: Text(formatPrice(p.totalPrice)),
            onTap: () {
              Navigator.pop(context);
              _showPropertyCard(p);
            },
          );
        }).toList(),
      ),
    );
  }

  // void _moveToInitialLocation() {
  //   if (widget.center != null) {
  //     _mapController.animateCamera(
  //       CameraUpdate.newLatLngZoom(widget.center!, 12),
  //     );
  //   } else if (_markers.isNotEmpty) {
  //     // Fit bounds to markers.
  //     final lats = _markers.map((m) => m.position.latitude);
  //     final lngs = _markers.map((m) => m.position.longitude);
  //     final sw =
  //         LatLng(lats.reduce(math.min) - .01, lngs.reduce(math.min) - .01);
  //     final ne =
  //         LatLng(lats.reduce(math.max) + .01, lngs.reduce(math.max) + .01);
  //     _mapController.animateCamera(
  //       CameraUpdate.newLatLngBounds(
  //           LatLngBounds(southwest: sw, northeast: ne), 30),
  //     );
  //   } else if (_markers.isNotEmpty) {
  //     final bounds = _getBoundsForMarkers(_markers);
  //     _mapController.animateCamera(
  //       CameraUpdate.newLatLngBounds(bounds, 50),
  //     );
  //   }
  // }

  void _moveToInitialLocation() {
    if (widget.center != null) {
      print("🔍 Moving to user-selected location: ${widget.center}");
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(widget.center!, 9), // ✅ Zoom level closer
      );
    } else if (_markers.isNotEmpty) {
      // If markers exist, calculate the bounds dynamically
      LatLngBounds bounds = _getBoundsForMarkers(_markers);
      _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    } else {
      print("🌍 Defaulting to India map.");
      _mapController.animateCamera(
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
      if (lat < minIndiaLat ||
          lat > maxIndiaLat ||
          lng < minIndiaLng ||
          lng > maxIndiaLng) {
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
        southwest: const LatLng(17.3850 - 0.5, 78.4867 - 0.5),
        northeast: const LatLng(17.3850 + 0.5, 78.4867 + 0.5),
      );
    }

    return LatLngBounds(
      southwest: LatLng(minLat - 0.03, minLng - 0.03),
      northeast: LatLng(maxLat + 0.03, maxLng + 0.03),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox.expand(
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(20.5937, 78.9629), // fallback
            zoom: 8,
          ),
          onCameraIdle: () {
            if (_mapController != null) {
              _buildClusters();
            }
          },
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
