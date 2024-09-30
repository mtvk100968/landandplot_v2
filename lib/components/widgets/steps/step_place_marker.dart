// lib/components/forms/steps/step_place_marker.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StepPlaceMarker extends StatelessWidget {
  final GoogleMapController? mapController;
  final Marker? selectedMarker;
  final Function(LatLng) onMapTapped;

  const StepPlaceMarker({
    Key? key,
    required this.mapController,
    required this.selectedMarker,
    required this.onMapTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Mark the location of the property on the map below:',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 300,
          child: GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(20.5937, 78.9629),
              zoom: 5,
            ),
            onMapCreated: (controller) {},
            markers: selectedMarker != null ? {selectedMarker!} : <Marker>{},
            onTap: onMapTapped,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            // Accessibility: Add semantics labels
            // However, GoogleMap widget has limited accessibility options
          ),
        ),
      ],
    );
  }
}
