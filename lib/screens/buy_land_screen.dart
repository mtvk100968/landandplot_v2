// lib/screens/buy_land_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/property_service.dart';
import '../models/property_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../components/views/property_list_view.dart';
import '../../components/views/property_map_view.dart';
import '../../components/filter_bottom_sheet.dart';
import '../../components/location_search_bar.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import 'login_screen.dart';

class BuyLandScreen extends StatefulWidget {
  const BuyLandScreen({Key? key}) : super(key: key);

  @override
  BuyLandScreenState createState() => BuyLandScreenState();
}

class BuyLandScreenState extends State<BuyLandScreen> {
  bool showMap = false;
  Timer? _debounce;

  // Define filter variables
  List<String> selectedPropertyTypes = [];
  RangeValues selectedPriceRange = const RangeValues(0, 0);
  String pricePerUnitUnit = '';
  RangeValues selectedLandAreaRange = const RangeValues(0, 0);
  String landAreaUnit = '';

  // New variables for location search
  Map<String, dynamic>? selectedPlace;
  double searchRadius = 10; // in kilometers

  // Administrative area filters
  String? selectedCity;
  String? selectedDistrict;
  String? selectedPincode;
  String? selectedState;

  // Current user
  AppUser? currentUser;

  // Store the properties future
  Future<List<Property>>? _propertyFuture;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _propertyFuture = fetchProperties();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // Load current user data
  Future<void> _loadCurrentUser() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      AppUser? user = await UserService().getUserById(firebaseUser.uid);
      setState(() {
        currentUser = user;
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(
              propertyList: [],
              favoritedPropertyIds: [],
              onFavoriteToggle: (propertyId, isFavorited) {},
            ),
          ),
        );
      });
    }
  }

  // Fetch properties with applied filters
  Future<List<Property>> fetchProperties() async {
    print('fetchProperties called with filters:');
    print('selectedPropertyTypes: $selectedPropertyTypes');
    print('selectedPriceRange: $selectedPriceRange');
    print('selectedLandAreaRange: $selectedLandAreaRange');
    print('selectedCity: $selectedCity');
    print('selectedDistrict: $selectedDistrict');
    print('selectedPincode: $selectedPincode');
    print('selectedPlace: $selectedPlace');
    print('searchRadius: $searchRadius');

    PropertyService propertyService = PropertyService();

    // Check if filters are applied
    if (selectedPropertyTypes.isNotEmpty ||
        selectedPlace != null ||
        selectedCity != null ||
        selectedDistrict != null ||
        selectedPincode != null) {
      double? minLat;
      double? maxLat;
      double? minLon;
      double? maxLon;

      // For point searches
      if (selectedPlace != null &&
          selectedCity == null &&
          selectedDistrict == null &&
          selectedPincode == null) {
        if (selectedPlace!['geometry'] != null) {
          double lat = selectedPlace!['geometry']['location']['lat'];
          double lon = selectedPlace!['geometry']['location']['lng'];

          // Calculate bounding box for radius-based search
          double radiusInDegrees = searchRadius / 111; // Approximate conversion

          minLat = lat - radiusInDegrees;
          maxLat = lat + radiusInDegrees;
          minLon = lon - radiusInDegrees;
          maxLon = lon + radiusInDegrees;
        }
      }

      return await propertyService.getPropertiesWithFilters(
        propertyTypes: selectedPropertyTypes,
        minPricePerUnit:
        selectedPriceRange.start > 0 ? selectedPriceRange.start : null,
        maxPricePerUnit:
        selectedPriceRange.end > 0 ? selectedPriceRange.end : null,
        minLandArea: selectedLandAreaRange.start > 0
            ? selectedLandAreaRange.start
            : null,
        maxLandArea:
        selectedLandAreaRange.end > 0 ? selectedLandAreaRange.end : null,
        minLat: minLat,
        maxLat: maxLat,
        minLon: minLon,
        maxLon: maxLon,
        city: selectedCity,
        district: selectedDistrict,
        pincode: selectedPincode,
      );
    } else {
      return await propertyService.getAllProperties();
    }
  }

  Future<bool> isLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  // Method to open the FilterBottomSheet and get the selected filters
  Future<void> openFilterBottomSheet() async {
    // Pass current filters to the bottom sheet (optional)
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FilterBottomSheet(
          currentFilters: {
            'selectedPropertyTypes': selectedPropertyTypes,
            'selectedPriceRange': selectedPriceRange,
            'pricePerUnitUnit': pricePerUnitUnit,
            'selectedLandAreaRange': selectedLandAreaRange,
            'landAreaUnit': landAreaUnit,
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedPropertyTypes = result['selectedPropertyTypes'] ?? [];
        selectedPriceRange =
            result['selectedPriceRange'] ?? const RangeValues(0, 0);
        pricePerUnitUnit = result['pricePerUnitUnit'] ?? '';
        selectedLandAreaRange =
            result['selectedLandAreaRange'] ?? const RangeValues(0, 0);
        landAreaUnit = result['landAreaUnit'] ?? '';
        _propertyFuture = fetchProperties(); // Update properties
      });
    }
  }

  void _handlePlaceSelected(Map<String, dynamic> place) {
    setState(() {
      selectedPlace = place;

      // Reset administrative filters
      selectedCity = null;
      selectedDistrict = null;
      selectedPincode = null;
      selectedState = null;

      // Extract administrative components
      if (place['address_components'] != null) {
        for (var component in place['address_components']) {
          var types = component['types'] as List<dynamic>;
          if (types.contains('locality')) {
            selectedCity = component['long_name'];
          } else if (types.contains('administrative_area_level_2')) {
            selectedDistrict = component['long_name'];
          } else if (types.contains('postal_code')) {
            selectedPincode = component['long_name'];
          } else if (types.contains('administrative_area_level_1')) {
            selectedState = component['long_name'];
          }
        }
      }

      // If the place is an area (e.g., city, district), clear the point location
      if (selectedCity != null ||
          selectedDistrict != null ||
          selectedPincode != null) {
        selectedPlace = null;
      }

      print('Place selected: $place');
      print('Selected City: $selectedCity');
      print('Selected District: $selectedDistrict');
      print('Selected Pincode: $selectedPincode');
      print('Selected State: $selectedState');

      _propertyFuture = fetchProperties(); // Update properties
    });
  }

  // Toggle favorite status
  // void _onFavoriteToggle(String propertyId, bool isFavorited) async {
  //   if (currentUser == null) {
  //     // Prompt user to log in
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //           content: Text('You need to be logged in to favorite properties.')),
  //     );
  //     return;
  //   }
  //
  //   try {
  //     if (isFavorited) {
  //       // If currently favorited, remove from favorites
  //       await UserService()
  //           .removeFavoriteProperty(currentUser!.uid, propertyId);
  //     } else {
  //       // If not favorited, add to favorites
  //       await UserService().addFavoriteProperty(currentUser!.uid, propertyId);
  //     }
  //
  //     // Reload current user data to update favoritedPropertyIds
  //     AppUser? updatedUser = await UserService().getUserById(currentUser!.uid);
  //     setState(() {
  //       currentUser = updatedUser;
  //     });
  //   } catch (e) {
  //     print('Error toggling favorite: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to update favorite: $e')),
  //     );
  //   }
  // }

  void _onFavoriteToggle(String propertyId, bool isFavorited) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Navigate to LoginScreen if the user is not logged in
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            propertyList: [],
            favoritedPropertyIds: [],
            onFavoriteToggle: (propertyId, isFavorited) {},
          ),
        ),
      );
      return; // Stop further execution
    }

    // Proceed with favoriting or unfavoriting the property
    try {
      if (isFavorited) {
        // Remove property from favorites
        await UserService().removeFavoriteProperty(user.uid, propertyId);
      } else {
        // Add property to favorites
        await UserService().addFavoriteProperty(user.uid, propertyId);
      }

      // Reload user data to update favorite property IDs
      AppUser? updatedUser = await UserService().getUserById(user.uid);
      setState(() {
        currentUser = updatedUser;
      });
    } catch (e) {
      print('Error toggling favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update favorite: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LANDANDPLOT',
          style: TextStyle(
            color: Colors.lightGreen,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          FutureBuilder<bool>(
            future: isLoggedIn(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              } else if (snapshot.hasData && snapshot.data!) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(
                          propertyList: [],
                          favoritedPropertyIds: [],
                          onFavoriteToggle: (propertyId, isFavorited) {},
                        ),
                      ),
                    );
                  },
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // **Search and Filter Section**
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // **Location Search Bar**
                Expanded(
                  child: LocationSearchBar(
                    onPlaceSelected: _handlePlaceSelected,
                  ),
                ),
                const SizedBox(width: 8),
                // **Filter Button**
                CircleAvatar(
                  backgroundColor: Colors.lightGreen,
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white),
                    onPressed: () async {
                      await openFilterBottomSheet();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // **Toggle Button (Map/List)**
                CircleAvatar(
                  backgroundColor: Colors.lightGreen,
                  child: IconButton(
                    icon: Icon(
                      showMap ? Icons.view_list : Icons.map,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        showMap = !showMap;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // **Active Filters**
          if (selectedPropertyTypes.isNotEmpty ||
              (selectedPriceRange.start > 0 && selectedPriceRange.end > 0) ||
              (selectedLandAreaRange.start > 0 &&
                  selectedLandAreaRange.end > 0) ||
              selectedPlace != null ||
              selectedCity != null ||
              selectedDistrict != null ||
              selectedPincode != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8.0,
                children: [
                  if (selectedCity != null)
                    Chip(
                      label: Text('City: $selectedCity'),
                      onDeleted: () {
                        setState(() {
                          selectedCity = null;
                          _propertyFuture = fetchProperties();
                        });
                      },
                    ),
                  if (selectedDistrict != null)
                    Chip(
                      label: Text('District: $selectedDistrict'),
                      onDeleted: () {
                        setState(() {
                          selectedDistrict = null;
                          _propertyFuture = fetchProperties();
                        });
                      },
                    ),
                  if (selectedPincode != null)
                    Chip(
                      label: Text('Pincode: $selectedPincode'),
                      onDeleted: () {
                        setState(() {
                          selectedPincode = null;
                          _propertyFuture = fetchProperties();
                        });
                      },
                    ),
                  if (selectedPlace != null)
                    Chip(
                      label: Text(
                          'Location: ${selectedPlace!['formatted_address']}'),
                      onDeleted: () {
                        setState(() {
                          selectedPlace = null;
                          _propertyFuture = fetchProperties();
                        });
                      },
                    ),
                  for (var type in selectedPropertyTypes)
                    Chip(label: Text(type)),
                  if (pricePerUnitUnit.isNotEmpty &&
                      selectedPriceRange.start > 0 &&
                      selectedPriceRange.end > 0)
                    Chip(
                      label: Text(
                        'Price: ${formatPrice(selectedPriceRange.start)} - ${formatPrice(selectedPriceRange.end)} $pricePerUnitUnit',
                      ),
                    ),
                  if (landAreaUnit.isNotEmpty &&
                      selectedLandAreaRange.start > 0 &&
                      selectedLandAreaRange.end > 0)
                    Chip(
                      label: Text(
                        'Area: ${selectedLandAreaRange.start.toStringAsFixed(1)} - ${selectedLandAreaRange.end.toStringAsFixed(1)} $landAreaUnit',
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 2),
          // **Property Listings**
          Expanded(
            child: FutureBuilder<List<Property>>(
              future: _propertyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print('Error in FutureBuilder: ${snapshot.error}');
                  return const Center(child: Text('Error loading properties'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No properties found'));
                } else {
                  final properties = snapshot.data!;
                  print('Number of properties fetched: ${properties.length}');
                  // Toggle between Map View and List View
                  return showMap
                      ? PropertyMapView(properties: properties) // Map View
                      : PropertyListView(
                    properties: properties,
                    favoritedPropertyIds:
                    currentUser?.favoritedPropertyIds ?? [],
                    onFavoriteToggle:
                    _onFavoriteToggle, // Updated callback
                  ); // List View
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to format price
  String formatPrice(double value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(1)}C'; // Crores
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L'; // Lakhs
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K'; // Thousands
    } else {
      return value.toStringAsFixed(0);
    }
  }
}
