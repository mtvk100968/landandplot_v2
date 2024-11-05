// lib/widgets/step4_map_location.dart

import 'dart:async'; // For Timer (debouncing)
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeMap();
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
  }

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
                    CameraUpdate.newLatLng(initialCenter),
                  );
                },
                onCameraMove: (CameraPosition position) {
                  _currentMapCenter = position.target;
                },
                onCameraIdle: _onCameraIdle,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
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
