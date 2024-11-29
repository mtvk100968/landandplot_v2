import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/property_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/user_service.dart';
import '../../../models/user_model.dart';
import '../../../utils/format.dart';

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
  User? _currentUser;
  AppUser? _appUser;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _getCurrentUserAndFavorites();
  }

  Future<void> _getCurrentUserAndFavorites() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      // Fetch the user's data from Firestore
      _appUser = await _userService.getUserById(_currentUser!.uid);
      if (_appUser != null) {
        setState(() {
          _isFavorited =
              _appUser!.favoritedPropertyIds.contains(widget.property.id);
        });
      }
    }
  }

  void _toggleFavorite() async {
    if (_currentUser == null) {
      // Show a dialog or prompt to sign in
      _showSignInDialog();
      return;
    }

    setState(() {
      _isFavorited = !_isFavorited;
    });

    try {
      if (_isFavorited) {
        // Add property to favorites
        await _userService.addFavoriteProperty(
            _currentUser!.uid, widget.property.id);
        // Optionally, update the local AppUser object
        _appUser?.favoritedPropertyIds.add(widget.property.id);
      } else {
        // Remove property from favorites
        await _userService.removeFavoriteProperty(
            _currentUser!.uid, widget.property.id);
        // Optionally, update the local AppUser object
        _appUser?.favoritedPropertyIds.remove(widget.property.id);
      }
    } catch (e) {
      // Handle error
      print('Error updating favorites: $e');
      // Revert the state change
      setState(() {
        _isFavorited = !_isFavorited;
      });
    }
  }

  void _showSignInDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign In Required'),
          content:
              const Text('Please sign in to add properties to your favorites.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sign In'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine the size of the card to make it responsive
    double cardWidth =
        MediaQuery.of(context).size.width * 0.95; // 95% of screen width
    double cardHeight = cardWidth; // Square shape for images

    return Center(
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded edges
        ),
        elevation: 4,
        shadowColor: Colors.black26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel with Icons and Property Type
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: cardHeight,
                      viewportFraction: 1.0,
                      enableInfiniteScroll: widget.property.images.length > 1,
                      autoPlay: widget.property.images.length > 1,
                      autoPlayInterval: const Duration(seconds: 5),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      },
                    ),
                    items: widget.property.images.isNotEmpty
                        ? widget.property.images.map((imageUrl) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  20), // Fully rounded corners
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: double.infinity,
                                height: cardHeight,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList()
                        : [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/images/no_image_available.png', // Ensure this image exists in your assets
                                width: double.infinity,
                                height: cardHeight,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                  ),
                ),
                // Property Type Rectangle at Top Left
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius:
                          BorderRadius.circular(12), // Fully rounded vertices
                    ),
                    child: Text(
                      widget.property.propertyType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Heart Icon at Top Right
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        _isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorited ? Colors.pinkAccent : Colors.white,
                        size: 24,
                      ),
                    ),
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
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
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
              ],
            ),
            // Property Details
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address
                  Text(
                    widget.property.address ?? "",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // City • Mandal
                  Row(
                    children: [
                      Text(
                        widget.property.city ??
                            " ", // Provide a default value if null
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '•',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.property.mandal ??
                            " ", // Provide a default value if null
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Land Area
                  Text(
                    '${widget.property.landArea} Sq Yards',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Total Price
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Text(
                          '₹ ${formatIndianPrice(widget.property.totalPrice)}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
