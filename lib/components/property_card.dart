// lib/components/property_card.dart

import 'package:flutter/material.dart';
import '../../../models/property_model.dart';
import '../utils/format.dart';
import '../../screens/property_details_screen.dart';
// import 'google_fonts';

class PropertyCard extends StatefulWidget {
  final Property property;
  final bool isFavorited;
  final ValueChanged<bool> onFavoriteToggle;
  final VoidCallback onTap; // Callback for taps

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
  int currentPage = 0; // For Carousel Dots

  @override
  void initState() {
    super.initState();
    isFavorited = widget.isFavorited;
  }

  void _toggleFavorite() {
    // Toggle favorite status and notify parent
    setState(() {
      isFavorited = !isFavorited;
    });
    widget.onFavoriteToggle(isFavorited);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: widget.onTap, // Navigate to property details
      child: Padding(
        padding: const EdgeInsets.only(
            bottom: 16), // Increased bottom padding for better spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Center the Image Container to control its width independently
            Center(
              child: SizedBox(
                width: screenWidth *
                    0.95, // Set desired width for the image container
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                  child: Stack(
                    children: [
                      // Image Carousel
                      AspectRatio(
                        aspectRatio: 16 / 10,
                        child: PageView.builder(
                          itemCount: widget.property.images.length,
                          onPageChanged: (index) {
                            setState(() {
                              currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Image.network(
                              widget.property.images[index],
                              fit: BoxFit.cover,
                              width: double.infinity, // Fill the SizedBox width
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                            (progress.expectedTotalBytes ?? 1)
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/no_image_available.png',
                                  fit: BoxFit.cover,
                                  width: double
                                      .infinity, // Fill the SizedBox width
                                );
                              },
                            );
                          },
                        ),
                      ),
                      // Heart Icon Positioned on the Image
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () {
                            // Prevent the tap from triggering the card's onTap
                            _toggleFavorite();
                          },
                          child: Icon(
                            isFavorited
                                ? Icons.favorite
                                : Icons
                                    .favorite_border, // Filled or outlined heart
                            size: 30, // Adjust the size as needed
                            color: isFavorited
                                ? Colors.red
                                : Colors
                                    .black, // Pink for favorited, black for not favorited
                            shadows: isFavorited
                                ? [
                                    Shadow(
                                      offset: Offset(0, 0),
                                      blurRadius: 2,
                                      color: Colors
                                          .white, // Adds a subtle glow when favorited
                                    ),
                                  ]
                                : null, // No shadow for the outline
                          ),
                        ),
                      ),
                      // Carousel Dots
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.property.images.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == currentPage
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Property Type Badge
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.property.propertyType,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Property Details with PopupMenuButton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expanded Column for Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Total Price
                        if (widget.property.totalPrice !=
                            null) // Check if totalPrice exists
                          Text(
                            '${formatPrice(widget.property.totalPrice!)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        // Price per unit
                        Text(
                          '${formatPrice(widget.property.pricePerUnit)}/${widget.property.propertyType == 'Agri Land' ? 'acre' : 'sqyd'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Address (2 lines)
                        Text(
                          '${widget.property.village ?? ''}, ${widget.property.city ?? ''}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '${widget.property.mandal ?? ''}, ${widget.property.district ?? ''}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Land Area
                  if (widget.property.landArea !=
                      null) // Check if landArea exists
                    Text(
                      '${formatValue(widget.property.landArea)} ${widget.property.propertyType == 'Agri Land' ? 'acres' : 'sqyds'}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Optional: Additional spacing or elements can go here
          ],
        ),
      ),
    );
  }
}
