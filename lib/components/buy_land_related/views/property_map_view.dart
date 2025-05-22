//
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart'
    as gpi;
import '../../../../models/property_model.dart';
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
  Set<Marker> _markers = {};
  late bool _markersInitialized = false;
  bool _clustersBuilt = false;
  LatLng? _initialPosition;

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  Future<void> _setInitialLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        return;
      }
    }

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _initialPosition = LatLng(pos.latitude, pos.longitude);
    });
  }

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
    // if (_markersInitialized) return;

    final zoom = await _mapController.getZoomLevel();
    final precision =
        (18 - zoom).clamp(1, 6).round(); // smaller zoom → broader buckets

    final buckets = <String, List<Property>>{};
    for (final p in widget.properties) {
      final key =
          '${p.latitude.toStringAsFixed(precision)}:${p.longitude.toStringAsFixed(precision)}';
      buckets.putIfAbsent(key, () => []).add(p);
    }

    // 2️⃣ Build markers
    final newMarkers = <Marker>{};
    for (final group in buckets.values) {
      if (group.length == 1) {
        // single property
        final p = group.first;
        final icon = await CustomMarker.createMarker(
          formatPrice(p.totalPrice),
        );
        newMarkers.add(Marker(
          markerId: MarkerId('cluster_${p.latitude}_$p.longitude'),
          position: LatLng(p.latitude, p.longitude),
          icon: icon,
          onTap: () async {
            final zoom = await _mapController.getZoomLevel();
            _mapController.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(p.latitude, p.longitude),
                (zoom + 2).clamp(0.0, 18.0),
              ),
            );
          },
        ));
      } else {
        // cluster
        final avgLat =
            group.map((p) => p.latitude).reduce((a, b) => a + b) / group.length;
        final avgLng = group.map((p) => p.longitude).reduce((a, b) => a + b) /
            group.length;
        final icon = await CustomMarker.createMarker(group.length.toString());
        newMarkers.add(Marker(
            markerId: MarkerId('cluster_${avgLat}_$avgLng'),
            position: LatLng(avgLat, avgLng),
            icon: icon,
            onTap: () async {
              final zoom = await _mapController.getZoomLevel();
              final newZoom = (zoom + 2).clamp(0.0, 18.0);

              // Zoom in
              await _mapController.animateCamera(
                CameraUpdate.newLatLngZoom(LatLng(avgLat, avgLng), newZoom),
              );

              // Then show list of properties in the cluster
              if (context.mounted) {
                showModalBottomSheet(
                  context: context,
                  builder: (ctx) {
                    return ListView(
                      children: group.map((p) {
                        return ListTile(
                          subtitle: Text('${formatPrice(p.totalPrice)}'),
                          onTap: () {
                            Navigator.pop(context); // close the bottom sheet
                            _showPropertyCard(p); // reuse existing function
                          },
                        );
                      }).toList(),
                    );
                  },
                );
              }
            }));
      }
    }

    setState(() {
      _markers = newMarkers;
      _clustersBuilt = true;
    });
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

  void _onMapCreated(GoogleMapController ctrl) async {
    _mapController = ctrl;
    if (_initialPosition != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_initialPosition!, 14),
      );
    }

    // Move to the initial location first
    _moveToInitialLocation();

    // Now safely build clusters (mapController is ready)
    await _buildClusters();
  }

  void _moveToInitialLocation() {
    if (widget.center != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(widget.center!, 12),
      );
    } else if (_markers.isNotEmpty) {
      // Fit bounds to markers.
      final lats = _markers.map((m) => m.position.latitude);
      final lngs = _markers.map((m) => m.position.longitude);
      final sw =
          LatLng(lats.reduce(math.min) - .01, lngs.reduce(math.min) - .01);
      final ne =
          LatLng(lats.reduce(math.max) + .01, lngs.reduce(math.max) + .01);
      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
            LatLngBounds(southwest: sw, northeast: ne), 30),
      );
    } else if (_markers.isNotEmpty) {
      final bounds = _getBoundsForMarkers(_markers);
      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50),
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
            target: _initialPosition ?? const LatLng(20.5937, 78.9629), // fallback
            zoom: 8,
          ),
          onMapCreated: _onMapCreated,
          onCameraIdle: () {
            if (_mapController != null) {
              _buildClusters();
            }
          },
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
