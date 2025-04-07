import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property_model.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';
import '../components/property_details_screen/image_gallery_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailsScreen({Key? key, required this.property})
      : super(key: key);

  @override
  _PropertyDetailsScreenState createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  late Future<void> _fetchProposedPricesFuture;

  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    final appleMapsUrl =
        Uri.parse('https://maps.apple.com/?q=$latitude,$longitude');

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(appleMapsUrl)) {
      await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch maps')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProposedPricesFuture =
        Provider.of<PropertyProvider>(context, listen: false)
            .fetchProposedPrices(widget.property.id);
  }

  String formatPrice(double value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(1)}C';
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  // Function to initiate a phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not initiate call')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Existing body remains unchanged
      body: FutureBuilder<void>(
        future: _fetchProposedPricesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading proposed prices: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image Section
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 12,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageGalleryScreen(
                                    images: widget.property.images),
                              ),
                            );
                          },
                          child: Image.network(
                            widget.property.images.isNotEmpty
                                ? widget.property.images.first
                                : '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Text("Image not available"),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 35,
                        left: 7,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                            size: 28,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      // Image Count Overlay
                      if (widget.property.images.isNotEmpty)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.image,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.property.images.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Price Details Card
                  buildCard(
                    title: 'Price Details',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Property Type: ${widget.property.propertyType ?? 'N/A'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (widget.property.propertyType.toLowerCase() ==
                            'Plot') ...[
                          Text(
                            'Survey Number: ${widget.property.surveyNumber ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Plot Numbers: ${widget.property.plotNumbers.isNotEmpty ? widget.property.plotNumbers.join(', ') : 'N/A'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                        Text(
                          'Land Area: ${widget.property.landArea ?? '0'} ${widget.property.propertyType.toLowerCase() == 'agri land' ? 'Acres' : 'sqyds'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Price per Unit: \$${formatPrice(widget.property.pricePerUnit)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Total Price: \$${formatPrice(widget.property.totalPrice)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Status Card
                  buildCard(
                    title: 'Status',
                    content: Text(
                      widget.property.status == true ? 'Active' : 'Inactive',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Address Card
                  buildCard(
                    title: 'Address',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.property.propertyType.toLowerCase() ==
                            'Plot')
                          Text(
                            'Venture Name: ${widget.property.ventureName ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        Text(
                          [
                            widget.property.village ?? '',
                            widget.property.mandal ?? '',
                            widget.property.district ?? '',
                            widget.property.pincode ?? '',
                          ].where((element) => element.isNotEmpty).join(', '),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description Card
                  // buildCard(
                  //   title: 'Description',
                  //   content: Text(
                  //     widget.property.description ??
                  //         'A beautiful and valuable piece of land',
                  //     style: const TextStyle(fontSize: 16),
                  //   ),
                  // ),

                  // const SizedBox(height: 16),

                  // Features Card
                  buildCard(
                    title: 'Features',
                    content: Column(
                      children: [
                        featureRow('Fencing', widget.property.fencing),
                        featureRow('Gate', widget.property.gate),
                        featureRow('Bore', widget.property.bore),
                        featureRow('Pipeline', widget.property.pipeline),
                        featureRow('Electricity', widget.property.electricity),
                        featureRow('Plantation', widget.property.plantation),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Map Card
                  buildCard(
                    title: 'Location',
                    content: Container(
                      height: 300, // Adjust height as needed
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(widget.property.latitude,
                              widget.property.longitude),
                          zoom: 14,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId(widget.property.id),
                            position: LatLng(widget.property.latitude,
                                widget.property.longitude),
                            onTap: () {
                              _openGoogleMaps(widget.property.latitude,
                                  widget.property.longitude);
                            },
                          ),
                        },
                        onTap: (LatLng position) {
                          // Optionally handle map taps
                        },
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: true,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: Container(
        height: 70, // Increase the height of the bottom bar
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, -2), // Shadow above the bar
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              // Call Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _makePhoneCall('+919959788005');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green background for Call
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12), // Reduced padding
                    elevation: 2,
                  ),
                  child: const Text(
                    'Call',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height:
                          1.2, // Line height to ensure proper text alignment
                    ),
                    textAlign: TextAlign.center, // Align text properly
                  ),
                ),
              ),
              const SizedBox(width: 16), // Spacing between buttons
              // Message Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'WhatsApp messaging is currently unavailable.'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Blue background for Message
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12), // Reduced padding
                    elevation: 2,
                  ),
                  child: const Text(
                    'Message',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height:
                          1.2, // Line height to ensure proper text alignment
                    ),
                    textAlign: TextAlign.center, // Align text properly
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method to build feature rows with check marks or cross icons
  Widget featureRow(String featureName, bool? isAvailable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isAvailable == true ? Icons.check_circle : Icons.cancel,
            color: isAvailable == true ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            featureName,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// Helper method to build reusable Card widgets
  Widget buildCard({required String title, required Widget content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              content,
            ],
          ),
        ),
      ),
    );
  }
}
