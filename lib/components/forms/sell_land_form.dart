import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SellLandForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController areaController;
  final TextEditingController priceController;
  final TextEditingController pricePerSqYardController;
  final VoidCallback onSubmit;
  final Function(LatLng) onLocationSelected;

  const SellLandForm({
    super.key,
    required this.formKey,
    required this.areaController,
    required this.priceController,
    required this.pricePerSqYardController,
    required this.onSubmit,
    required this.onLocationSelected,
  });

  @override
  _SellLandFormState createState() => _SellLandFormState();
}

class _SellLandFormState extends State<SellLandForm> {
  late GoogleMapController _mapController;

  // Method to retrieve the center coordinates
  Future<void> _getCenterLocation() async {
    LatLng center = await _mapController.getLatLng(
      ScreenCoordinate(
        x: MediaQuery.of(context).size.width ~/ 2,
        y: MediaQuery.of(context).size.height ~/ 3,
      ),
    );
    // Pass the center location back to the parent widget
    widget.onLocationSelected(center);
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

            // Google Map with the overlay marker in the center
            Stack(
              alignment: Alignment.center,
              children: [
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
                  ),
                ),
                const Icon(
                  Icons.location_on,
                  size: 40,
                  color: Colors.red,
                ), // Static marker in the center of the map
              ],
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {
                if (widget.formKey.currentState!.validate()) {
                  // Get the center location of the map
                  await _getCenterLocation();
                  widget.onSubmit();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please fill in the required fields')),
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
