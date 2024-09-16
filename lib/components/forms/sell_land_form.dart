import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SellLandForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController areaController;
  final TextEditingController priceController;
  final TextEditingController pricePerSqYardController;
  final VoidCallback onSubmit;
  final Function(LatLng)
      onLocationSelected; // New callback for location selection

  const SellLandForm({
    super.key,
    required this.formKey,
    required this.areaController,
    required this.priceController,
    required this.pricePerSqYardController,
    required this.onSubmit,
    required this.onLocationSelected, // New required callback parameter
  });

  @override
  _SellLandFormState createState() => _SellLandFormState();
}

class _SellLandFormState extends State<SellLandForm> {
  LatLng? selectedLocation;
  late GoogleMapController _mapController;

  void _selectLocation(LatLng location) {
    setState(() {
      selectedLocation = location;
    });
    // Pass the selected location back to the parent widget
    widget.onLocationSelected(location);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: widget.areaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Land Area (sq. yards)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter land area'
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: widget.priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Land Price',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter land price'
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: widget.pricePerSqYardController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price Per Sq. Yard',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter price per sq. yard'
                  : null,
            ),
            const SizedBox(height: 20),
            // Google Map Widget
            SizedBox(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(20.5937, 78.9629), // Default to India
                  zoom: 5,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                onTap: _selectLocation,
                markers: selectedLocation != null
                    ? {
                        Marker(
                          markerId: const MarkerId('selected-location'),
                          position: selectedLocation!,
                        ),
                      }
                    : {},
              ),
            ),
            const SizedBox(height: 10),
            // Show selected location
            selectedLocation != null
                ? Text(
                    'Location: (${selectedLocation!.latitude}, ${selectedLocation!.longitude})',
                    style: const TextStyle(fontSize: 16),
                  )
                : const Text(
                    'Tap on the map to select a location',
                    style: TextStyle(fontSize: 16),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (widget.formKey.currentState!.validate() &&
                    selectedLocation != null) {
                  widget.onSubmit();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please pick a location')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
