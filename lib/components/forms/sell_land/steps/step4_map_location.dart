// lib/widgets/step4_map_location.dart

import 'dart:async'; // For Timer (debouncing)
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../models/property_model.dart';
import '../../../../providers/property_provider.dart';

class Step4MapLocation extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const Step4MapLocation({Key? key, required this.formKey}) : super(key: key);

  @override
  _Step4MapLocationState createState() => _Step4MapLocationState();
}

class _Step4MapLocationState extends State<Step4MapLocation> {
  GoogleMapController? _mapController;
  bool _isLoading = true;
  Timer? _debounce; // Timer for debouncing
  bool _isFetchingLocation = false; // Indicator for fetching location
  LatLng? _currentMapCenter; // Tracks the current center of the map
  bool _locationPermissionGranted = false; // Tracks if location permission is granted

  // Initialize markers
  Set<Marker> _markers = {};

  // ClusterManager for clusters
  late ClusterManager _clusterManager;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.primaryFocus?.unfocus();
    _checkPermissions(); // Call this method to check and request permissions
    _initializeMap();
    _fetchAndUpdateProperties(); // Fetch properties from the provider
  }

  // Fetch properties and update markers
  Future<void> _fetchAndUpdateProperties() async {
    final propertyProvider =
    Provider.of<PropertyProvider>(context, listen: false);

    await propertyProvider.fetchProperties(); // Fetch properties from Firestore

    _addMarkers(propertyProvider.properties); // Add markers based on the properties list
  }

  // Add markers to the map
  void _addMarkers(List<Property> properties) {
    Set<Marker> markers = {};

    for (var property in properties) {
      markers.add(Marker(
        markerId: MarkerId(property.id),
        position: LatLng(property.latitude, property.longitude),
        infoWindow: InfoWindow(
          title: property.name, // You can customize the title here
          snippet: property.propertyOwner, // Customize the description as needed
        ),
      ));
    }

    setState(() {
      _markers = markers;
    });
  }

  // Method to check and request permissions
  Future<void> _checkPermissions() async {
    bool locationServiceEnabled = await _isLocationServiceEnabled();

    if (!locationServiceEnabled) {
      print("Location service is not enabled");
      // You can show an alert to the user here prompting them to enable location services
      return;
    }

    // Check if the app has location permission
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      // If granted, enable myLocation button and layer
      setState(() {
        _locationPermissionGranted = true;
      });
    } else {
      // If not granted, show a message or handle it accordingly
      print("Location permission not granted");
    }
  }

  // Method to check if location service is enabled
  Future<bool> _isLocationServiceEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // You can prompt the user here to enable location services
      return false;
    }
    return true;
  }

  /// Initialize the map by geocoding the pincode and moving the camera
  Future<void> _initializeMap() async {
    final propertyProvider =
        Provider.of<PropertyProvider>(context, listen: false);

    // Ensure pincode is set before geocoding
    if (propertyProvider.pincode.isNotEmpty) {
      await propertyProvider.geocodePincode(propertyProvider.pincode);
    }

    setState(() {
      _isLoading = false;
      _currentMapCenter = LatLng(
        propertyProvider.latitude,
        propertyProvider.longitude,
      );
    });

    // Move the camera after geocoding
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(propertyProvider.latitude, propertyProvider.longitude),
        ),
      );
    }

    // Initialize markers and clusters when the map is created
    _addMarkers(propertyProvider.properties); // Call this to ensure markers are updated
  }

  // // Add markers to the map
  // Future<void> _addMarkers() async {
  //   final propertyProvider =
  //       Provider.of<PropertyProvider>(context, listen: false);
  //
  //   // Create markers for the properties
  //   Set<Marker> markers = {};
  //
  //   for (var property in propertyProvider.properties) {
  //     markers.add(Marker(
  //       markerId: MarkerId(property.id),
  //       position: LatLng(property.latitude, property.longitude),
  //       infoWindow: InfoWindow(
  //         title: property.title,
  //         snippet: property.description,
  //       ),
  //     ));
  //   }
  //   setState(() {
  //     _markers = markers;
  //   });
  // }

  /// Handle camera idle with debouncing to optimize performance
  void _onCameraIdle() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (_currentMapCenter != null) {
        setState(() {
          _isFetchingLocation = true;
        });

        // Update the provider with the new location
        final propertyProvider =
            Provider.of<PropertyProvider>(context, listen: false);
        propertyProvider.setLatitude(_currentMapCenter!.latitude);
        propertyProvider.setLongitude(_currentMapCenter!.longitude);

        setState(() {
          _isFetchingLocation = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Cancel the debounce timer if active
    _mapController?.dispose(); // Dispose the map controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final LatLng initialCenter = LatLng(
      propertyProvider.latitude,
      propertyProvider.longitude,
    );

    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialCenter,
                  zoom: 15,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  // Move the camera to the initial position if not already done
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLng(LatLng(
                        propertyProvider.latitude, propertyProvider.longitude)),
                  );
                },
                onCameraMove: (CameraPosition position) {
                  _currentMapCenter = position.target;
                },
                onCameraIdle: _onCameraIdle,
                myLocationEnabled:
                    _locationPermissionGranted, // Use the permission status
                myLocationButtonEnabled:
                    _locationPermissionGranted, // Use the permission status
                zoomControlsEnabled: false,
                markers: _markers, // Display markers
                // Optionally, you can add markers or other map features here
              ),
              // Fixed marker at the center of the map
              Center(
                child: Icon(
                  Icons.location_pin,
                  size: 50,
                  color: Colors.red,
                ),
              ),
              // Loading indicator when fetching the new center location
              if (_isFetchingLocation)
                Positioned(
                  top: 20,
                  right: 20,
                  child: CircularProgressIndicator(),
                ),
              // Instructional Container at the bottom
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Click Next once the marker points to your property location.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          );
  }
}
