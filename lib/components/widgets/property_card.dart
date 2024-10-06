// lib/components/widgets/property_card.dart

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/property_model.dart';

class PropertyCard extends StatefulWidget {
  final Property property;

  const PropertyCard({
    super.key,
    required this.property,
  });

  @override
  PropertyCardState createState() => PropertyCardState();
}

class PropertyCardState extends State<PropertyCard> {
  int _current = 0;
  bool _isFavorited = false; // State for favorite icon

  @override
  Widget build(BuildContext context) {
    // Determine the size of the card to make it square
    double cardWidth =
        MediaQuery.of(context).size.width * 0.9; // 90% of screen width
    double cardHeight =
        cardWidth; // Make height equal to width for square shape

    return Center(
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(15), // Increased for better rounded edges
        ),
        elevation: 4,
        child: SizedBox(
          width: cardWidth,
          height:
              cardHeight + 150, // Additional space for details below the image
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Carousel with Dots and Icons
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: cardHeight,
                        viewportFraction: 1.0,
                        enableInfiniteScroll: widget.property.images.length > 1,
                        autoPlay: widget.property.images.length > 1,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _current = index;
                          });
                        },
                      ),
                      items: widget.property.images.isNotEmpty
                          ? widget.property.images.map((imageUrl) {
                              return CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: double.infinity,
                                height: cardHeight,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }).toList()
                          : [
                              Image.asset(
                                'assets/images/no_image_available.png', // Ensure this image exists in your assets
                                width: double.infinity,
                                height: cardHeight,
                                fit: BoxFit.cover,
                              ),
                            ],
                    ),
                  ),
                  // Dots Indicator
                  if (widget.property.images.length > 1)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            widget.property.images.asMap().entries.map((entry) {
                          return GestureDetector(
                            onTap: () {
                              // Optionally handle tap on dots
                            },
                            child: Container(
                              width: 8.0,
                              height: 8.0,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _current == entry.key
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.4),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  // Heart and Share Icons
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Column(
                      children: [
                        // Favorite (Heart) Icon
                        IconButton(
                          icon: Icon(
                            _isFavorited
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                _isFavorited ? Colors.pink[700] : Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              _isFavorited = !_isFavorited;
                            });
                          },
                        ),
                        // Share Icon
                        IconButton(
                          icon: const Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            // Define the text to share
                            const String shareText =
                                "Hey, see this property I found on LandAndPlot!";

                            // Optionally, include property details
                            // final String shareText =
                            //     "Check out this property: ${widget.property.village}, ${widget.property.mandal}, ${widget.property.district}, Price: \$${widget.property.totalPrice}";

                            Share.share(shareText);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Property Details
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Land Type
                    Row(
                      children: [
                        const Icon(Icons.landscape,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          widget.property.propertyType,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Location: Village, Mandal, District
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${widget.property.village}, ${widget.property.mandal}, ${widget.property.district}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Land Area
                    Row(
                      children: [
                        const Icon(Icons.square_foot,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.property.landArea} Sq Yards',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Total Price
                    Row(
                      children: [
                        const Icon(Icons.price_change,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Price: \$${widget.property.totalPrice.toStringAsFixed(2)}',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
