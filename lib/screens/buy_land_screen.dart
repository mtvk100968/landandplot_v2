// lib/screens/buy_land_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../services/property_service.dart';
import '../models/property_model.dart';
import '../providers/property_provider.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import '../../components/views/property_list_view.dart';
import '../../components/views/property_map_view.dart';
import '../../components/filter_bottom_sheet.dart';
import '../../components/location_search_bar.dart';
import './property_details_screen.dart';

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

  Future<List<Property>>? _propertyFuture;

  @override
  void initState() {
    super.initState();
    _propertyFuture = fetchProperties();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<List<Property>> fetchProperties() async {
    print('fetchProperties called with filters:');
    print('  selectedPropertyTypes: $selectedPropertyTypes');
    print('  selectedPriceRange: $selectedPriceRange');
    print('  selectedLandAreaRange: $selectedLandAreaRange');
    print('  selectedCity: $selectedCity');
    print('  selectedDistrict: $selectedDistrict');
    print('  selectedPincode: $selectedPincode');
    print('  selectedPlace: $selectedPlace');
    print('  searchRadius: $searchRadius');

    // Use the injected PropertyService from the MultiProvider
    final propertyService = context.read<PropertyService>();

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

          // Approximate conversion from km to degrees
          double radiusInDegrees = searchRadius / 111;

          minLat = lat - radiusInDegrees;
          maxLat = lat + radiusInDegrees;
          minLon = lon - radiusInDegrees;
          maxLon = lon + radiusInDegrees;
        }
      }

      return await propertyService.getPropertiesWithFilters(
        propertyTypes: selectedPropertyTypes,
        minPricePerUnit:
            (selectedPriceRange.start > 0) ? selectedPriceRange.start : null,
        maxPricePerUnit:
            (selectedPriceRange.end > 0) ? selectedPriceRange.end : null,
        minLandArea: (selectedLandAreaRange.start > 0)
            ? selectedLandAreaRange.start
            : null,
        maxLandArea:
            (selectedLandAreaRange.end > 0) ? selectedLandAreaRange.end : null,
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

  // Method to open the FilterBottomSheet and get the selected filters
  Future<void> openFilterBottomSheet() async {
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
        _propertyFuture = fetchProperties(); // Update the property list
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

      print('Place selected: $place');
      print('Selected City: $selectedCity');
      print('Selected District: $selectedDistrict');
      print('Selected Pincode: $selectedPincode');
      print('Selected State: $selectedState');

      _propertyFuture = fetchProperties(); // Re-fetch properties
    });
  }

  void _onFavoriteToggle(String propertyId, bool nowFavorited) async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You need to be logged in to favorite properties.')),
      );
      Navigator.pushNamed(context, '/profile'); // Navigate to profile page
      return;
    }

    try {
      if (nowFavorited) {
        await UserService().addFavoriteProperty(firebaseUser.uid, propertyId);
      } else {
        await UserService()
            .removeFavoriteProperty(firebaseUser.uid, propertyId);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update favorite: $e')),
      );
    }
  }

  // Pull-to-refresh method
  Future<void> _refreshProperties() async {
    setState(() {
      _propertyFuture = fetchProperties();
    });
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

  @override
  Widget build(BuildContext context) {
    // Wrap the entire widget tree in a MultiProvider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PropertyProvider>(
          create: (_) => PropertyProvider(),
        ),
        Provider<PropertyService>(
          create: (_) => PropertyService(),
        ),
      ],
      child: Builder(
        builder: (childContext) {
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
                StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink(); // Or a placeholder widget
                    } else if (snapshot.hasData && snapshot.data != null) {
                      return IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacementNamed(
                              childContext, '/profile');
                        },
                      );
                    } else {
                      return IconButton(
                        icon: const Icon(Icons.login),
                        onPressed: () {
                          Navigator.pushNamed(childContext, '/profile');
                        },
                      );
                    }
                  },
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: _refreshProperties,
              child: Column(
                children: [
                  // **Search and Filter Section**
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
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
                      (selectedPriceRange.start > 0 &&
                          selectedPriceRange.end > 0) ||
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
                      builder: (context, propertySnapshot) {
                        if (propertySnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (propertySnapshot.hasError) {
                          print(
                              'Error in FutureBuilder: ${propertySnapshot.error}');
                          return const Center(
                              child: Text('Error loading properties'));
                        } else if (!propertySnapshot.hasData ||
                            propertySnapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No properties found'));
                        } else {
                          final properties = propertySnapshot.data!;
                          print(
                              'Number of properties fetched: ${properties.length}');
                          return StreamBuilder<User?>(
                            stream: FirebaseAuth.instance.authStateChanges(),
                            builder: (context, authSnapshot) {
                              if (authSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              final user = authSnapshot.data;
                              if (user != null) {
                                // User is logged in
                                return StreamBuilder<AppUser?>(
                                  stream: UserService().getUserStream(user.uid),
                                  builder: (context, userSnapshot) {
                                    if (userSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                    if (userSnapshot.hasError) {
                                      return Center(
                                          child: Text(
                                              'Error: ${userSnapshot.error}'));
                                    }
                                    final currentUser = userSnapshot.data;
                                    if (currentUser == null) {
                                      return const Center(
                                          child:
                                              Text('No user data available.'));
                                    }

                                    return showMap
                                        ? PropertyMapView(
                                            properties: properties)
                                        : PropertyListView(
                                            properties: properties,
                                            favoritedPropertyIds: currentUser
                                                .favoritedPropertyIds,
                                            onFavoriteToggle: _onFavoriteToggle,
                                            onTapProperty: (property) {
                                              Navigator.push(
                                                childContext,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      PropertyDetailsScreen(
                                                    property: property,
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                  },
                                );
                              } else {
                                // User is not logged in
                                return showMap
                                    ? PropertyMapView(properties: properties)
                                    : PropertyListView(
                                        properties: properties,
                                        favoritedPropertyIds: [], // Empty list for guests
                                        onFavoriteToggle: _onFavoriteToggle,
                                        onTapProperty: (property) {
                                          Navigator.push(
                                            childContext,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  PropertyDetailsScreen(
                                                property: property,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                              }
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
