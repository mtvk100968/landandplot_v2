//
import 'dart:async';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart'
as gpi;
import '../../../../models/property_model.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
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
  List<String> _favoritedIds = [];
  late final String _currentUid;
  final Map<String, BitmapDescriptor> _markerCache = {};

  // Create a ClusterManagerId
  final ClusterManagerId _clusterManagerId = const ClusterManagerId(
    'propertyClusterManager',
  );
  late ClusterManager _clusterManager;

  // @override
  // void initState() {
  //   super.initState();
  //
  //   // Initialize ClusterManager
  //   _clusterManager = ClusterManager(
  //     clusterManagerId: _clusterManagerId,
  //     onClusterTap: _onClusterTap,
  //   );
  //
  //   // _setInitialLocation();
  // }

  @override
  void initState() {
    super.initState();

    // ✅ Initialize ClusterManager (required for clusters to work)
    _clusterManager = ClusterManager(
      clusterManagerId: _clusterManagerId,
      onClusterTap: _onClusterTap,
    );

    // ✅ Delay marker generation until after first frame to avoid blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addCustomMarkers().then((_) => _moveToInitialLocation());
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
    final fbUser = FirebaseAuth.instance.currentUser!;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StreamBuilder<AppUser?>(
          stream: UserService().getUserStream(fbUser.uid),
          builder: (c, snap) {
            if (snap.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            final appUser = snap.data;
            final favIds = appUser?.favoritedPropertyIds ?? [];

            // 2) Seed the card with whether this property is in the fav list
            return PropertyCard2(
              property: property,
              isFavorited: favIds.contains(property.id),
              onFavoriteToggle: (newFav) async {
                // 3) Push the update to Firestore
                if (newFav) {
                  await UserService()
                      .addFavoriteProperty(fbUser.uid, property.id);
                } else {
                  await UserService()
                      .removeFavoriteProperty(fbUser.uid, property.id);
                }
                // no need to pop the sheet—when the stream updates,
                // both this card and your FavoritesScreen will rebuild themselves.
              },
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PropertyDetailsScreen(property: property),
                  ),
                );
              },
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
    final uniqueProps = widget.properties.where((p) => seenIds.add(p.id)).toList();

    print("📦 Total properties: ${widget.properties.length}");
    print("🧹 Unique properties: ${uniqueProps.length}");

    if (uniqueProps.isEmpty) {
      if (mounted) {
        setState(() {
          _markers = {};
          _markersInitialized = true;
        });
        await _moveToInitialLocation();
      }
      return;
    }

    // ✅ Move heavy async work off UI thread
    final generatedMarkers = await _generateMarkers(uniqueProps);

    if (mounted) {
      setState(() {
        _markers = generatedMarkers;
        _markersInitialized = true;
        print("✅ Markers added: ${_markers.length}");
      });
    }
  }

  Future<Set<Marker>> _generateMarkers(List<Property> props) async {
    final markers = <Marker>{};

    for (Property p in props) {
      if (p.latitude == 0 || p.longitude == 0) {
        print("⚠️ Skipping property with invalid coordinates: ${p.id}");
        continue;
      }

      final priceText = formatPrice(p.totalPrice ?? 0.0);
      final icon = await _getOrCreateIcon(priceText);

      markers.add(
        Marker(
          markerId: MarkerId(p.id),
          position: LatLng(p.latitude, p.longitude),
          icon: icon,
          onTap: () => _showPropertyCard(p),
        ),
      );
    }

    return markers;
  }

  Future<BitmapDescriptor> _getOrCreateIcon(String priceText) async {
    if (_markerCache.containsKey(priceText)) {
      return _markerCache[priceText]!;
    }
    final icon = await CustomMarker.createMarker(priceText);
    _markerCache[priceText] = icon;
    return icon;
  }

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

  Future<void> _moveToInitialLocation() async {
    if (widget.center != null) {
      final c = widget.center!;
      final km = 90.0;
      final dLat = km / 90.0;
      final rad = c.latitude * math.pi / 180;
      final dLng = km / (90.0 * math.cos(rad));
      final sw = LatLng(c.latitude - dLat, c.longitude - dLng);
      final ne = LatLng(c.latitude + dLat, c.longitude + dLng);

      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(southwest: sw, northeast: ne),
          50,
        ),
      );
    } else if (_markers.isNotEmpty) {
      final bounds = _getBoundsForMarkers(_markers);
      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50),
      );
    } else {
      final currentLoc = await _getCurrentLocation();
      if (currentLoc != null) {
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(currentLoc, 12),
        );
        print("📍 Fallback: moved to user's current location");
      } else {
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(20.5937, 78.9629),
            8,
          ),
        );
        print("⚠️ No location found – fallback to India default.");
      }
    }
  }

  Future<LatLng?> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Location permission denied.');
          return null;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('❌ Error fetching current location: $e');
      return null;
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