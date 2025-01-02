import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property_model.dart';
import 'package:provider/provider.dart';
import '../providers/property_provider.dart';
import '../components/image_gallery_screen.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailsScreen({Key? key, required this.property})
      : super(key: key);

  @override
  _PropertyDetailsScreenState createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  late Future<void> _fetchProposedPricesFuture;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Price Card
                  buildCard(
                    title: 'Price Details',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Property Type: ${widget.property.propertyType}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (widget.property.propertyType.toLowerCase() ==
                            'plot') ...[
                          Text(
                            'Survey Number: ${widget.property.surveyNumber}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Plot Numbers: ${widget.property.plotNumbers.join(', ')}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                        Text(
                          'Land Area: ${widget.property.landArea} ${widget.property.propertyType.toLowerCase() == 'agri land' ? 'Acres' : 'Sq. Yards'}',
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
                  // Address Card
                  buildCard(
                    title: 'Address',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.property.city} / ${widget.property.ventureName ?? ''}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.property.village ?? ''}, ${widget.property.mandal ?? ''}, ${widget.property.district ?? ''}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // const SizedBox(height: 16),
                  // Road Details Card
                  // buildCard(
                  //   title: 'Road Details',
                  //   content: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text(
                  //         'Road Access: ${widget.property.roadAccess}',
                  //         style: const TextStyle(fontSize: 16),
                  //       ),
                  //       Text(
                  //         'Road Type: ${widget.property.roadType}',
                  //         style: const TextStyle(fontSize: 16),
                  //       ),
                  //       Text(
                  //         'Road Width: ${widget.property.roadWidth} ft',
                  //         style: const TextStyle(fontSize: 16),
                  //       ),
                  //       Text(
                  //         'Land Facing: ${widget.property.landFacing}',
                  //         style: const TextStyle(fontSize: 16),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

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
