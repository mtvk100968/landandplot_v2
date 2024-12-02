import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../utils/format.dart';

class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({Key? key, required this.property}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9), // Top and bottom padding
      child: Stack(
        children: [
          // Image Carousel
          AspectRatio(
            aspectRatio: 16 / 9,
            child: PageView.builder(
              itemCount: property.images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  property.images[index],
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
              // color: Colors.black.withOpacity(0.6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price and Unit
                  Text(
                    '${formatPrice(property.pricePerUnit)}/${property.propertyType == 'Agri Land' ? 'ac' : 'sqyd'}',
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
                    '${property.village ?? ''}, ${property.city ?? ''}',
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
                    '${property.mandal ?? ''}, ${property.district ?? ''}',
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2), // Matching color scheme
                borderRadius: BorderRadius.circular(4), // Subtle rounding
              ),
              child: Text(
                property.propertyType,
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
                  onTap: () {
                    // Add your share functionality here
                  },
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
                  onTap: () {
                    // Add your favorite functionality here
                  },
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
                      Icons.favorite_border,
                      size: 24, // Larger icon size
                      color: Colors.white, // White icon on black background
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
                // color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${formatValue(property.landArea)} ${property.propertyType == 'Agri Land' ? 'ac' : 'sqyd'}',
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
    );
  }
}
