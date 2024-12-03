import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../models/property_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/user_service.dart';
import '../../../models/user_model.dart';
import '../../../utils/format.dart';
import '../../providers/user_provider.dart';

class PropertyCard extends StatefulWidget {
  final Property property;
  final Function(Property) onFavoriteToggle;
  final bool isFavorited; // Add this parameter

  const PropertyCard({super.key, required this.property, required this.onFavoriteToggle,     required this.isFavorited,  // Accept the favorite status
  });

  @override
  PropertyCardState createState() => PropertyCardState();
}

class PropertyCardState extends State<PropertyCard> {
  int _current = 0;
  User? _currentUser;
  AppUser? _appUser;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _toggleFavorite() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (_currentUser == null) {
      _showSignInDialog();
      return;
    }

    try {
      // Toggle the favorite status in the database
      await _userService.toggleFavorite(_currentUser!.uid, widget.property.id);

      // Fetch the updated user data
      AppUser? updatedUser = await _userService.getUserById(_currentUser!.uid);
      if (updatedUser != null) {
        // Update the UserProvider
        userProvider.setUser(updatedUser);
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating favorites: $e')),
      );
    }
  }

  // Future<void> _getCurrentUserAndFavorites() async {
  //   _currentUser = FirebaseAuth.instance.currentUser;
  //   if (_currentUser != null) {
  //     try {
  //       // Fetch the user's data from Firestore
  //       _appUser = await _userService.getUserById(_currentUser!.uid);
  //       if (mounted && _appUser != null) {
  //         setState(() {
  //           _isFavorited =
  //               _appUser!.favoritedPropertyIds.contains(widget.property.id);
  //         });
  //       }
  //     } catch (e) {
  //       print('Error fetching user data: $e');
  //     }
  //   }
  // }


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

  Future<void> _getCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      try {
        // Fetch the user's data from Firestore
        _appUser = await _userService.getUserById(_currentUser!.uid);
        // No need to call setState() here unless you're using _appUser in the UI
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isFavorited = userProvider.user.favoritedPropertyIds.contains(widget.property.id);

    // Determine the size of the card to make it responsive
    double cardWidth = MediaQuery.of(context).size.width * 0.95; // 95% of screen width
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
                        isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: isFavorited ? Colors.pinkAccent : Colors.white,
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
