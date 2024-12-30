// lib/components/property_card.dart

import 'package:flutter/material.dart';
import '../../../models/property_model.dart';
import '../utils/format.dart';
import '../../screens/property_details_screen.dart';

class PropertyCard extends StatefulWidget {
  final Property property;
  final bool isFavorited;
  final ValueChanged<bool> onFavoriteToggle;
  final VoidCallback onTap; // New callback for taps

  const PropertyCard({
    Key? key,
    required this.property,
    required this.isFavorited,
    required this.onFavoriteToggle,
    required this.onTap, // Require the onTap callback
  }) : super(key: key);

  @override
  _PropertyCardState createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  late bool isFavorited;

  @override
  void initState() {
    super.initState();
    isFavorited = widget.isFavorited;
  }

  void _toggleFavorite() {
    // Toggle favorite status and notify parent
    widget.onFavoriteToggle(!widget.isFavorited);
    setState(() {
      isFavorited = !isFavorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: widget.onTap, // Use the passed onTap callback
      child: Padding(
        padding: const EdgeInsets.only(bottom: 9), // Bottom padding
        child: Stack(
          children: [
            // Image Carousel
            AspectRatio(
              aspectRatio: 16 / 10,
              child: PageView.builder(
                itemCount: widget.property.images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.property.images[index],
                    fit: BoxFit.cover,
                    width: screenWidth,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/no_image_available.png',
                        fit: BoxFit.cover,
                        width: screenWidth,
                      );
                    },
                  );
                },
              ),
            ),
            // Text Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                // Optional: Uncomment to add a semi-transparent background
                // color: Colors.black.withOpacity(0.6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price and Unit
                    Text(
                      '${formatPrice(widget.property.pricePerUnit)}/${widget.property.propertyType == 'Agri Land' ? 'ac' : 'sqyd'}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily:
                            'Roboto', // Professional font for better design
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Town and City
                    Text(
                      '${widget.property.village ?? ''}, ${widget.property.city ?? ''}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Roboto', // Consistent professional font
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Mandal and District
                    Text(
                      '${widget.property.mandal ?? ''}, ${widget.property.district ?? ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Roboto', // Consistent professional font
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Property Type Badge
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2), // Matching color scheme
                  borderRadius: BorderRadius.circular(4), // Subtle rounding
                ),
                child: Text(
                  widget.property.propertyType,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto', // Consistent professional font
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Share and Heart Icons
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  // Share Icon
                  GestureDetector(
                    onTap: widget.onTap, // Use onTap to navigate to details
                    child: Container(
                      width: 40, // Increased width
                      height: 40, // Increased height
                      decoration: BoxDecoration(
                        color: Colors.black
                            .withOpacity(0.2), // Matching color scheme
                        shape: BoxShape.rectangle, // Square shape
                        borderRadius:
                            BorderRadius.circular(8), // More rounded corners
                      ),
                      alignment: Alignment.center, // Center the icon
                      child: const Icon(
                        Icons.share,
                        size: 24, // Larger icon size
                        color: Colors.white, // White icon on black background
                      ),
                    ),
                  ),
                  const SizedBox(width: 12), // Added spacing between icons
                  // Heart Icon
                  GestureDetector(
                    onTap: _toggleFavorite, // Use the local method
                    child: Container(
                      width: 40, // Increased width
                      height: 40, // Increased height
                      decoration: BoxDecoration(
                        color: Colors.black
                            .withOpacity(0.2), // Matching color scheme
                        shape: BoxShape.rectangle, // Square shape
                        borderRadius:
                            BorderRadius.circular(8), // More rounded corners
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        isFavorited ? Icons.favorite : Icons.favorite_border,
                        size: 24,
                        color: isFavorited ? Colors.red : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Total Area
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  // Optional: Uncomment to add a semi-transparent background
                  // color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${formatValue(widget.property.landArea)} ${widget.property.propertyType == 'Agri Land' ? 'ac' : 'sqyd'}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto', // Consistent professional font
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
