import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/property_service.dart';
import '../models/property_model.dart';
import '../providers/property_provider.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import '../components/buy_land_related/views/property_list_view.dart';
import '../components/buy_land_related/views/property_map_view.dart';
import '../components/buy_land_related/filter_bottom_sheet.dart';
import '../components/buy_land_related/location_search_bar.dart';
import './property_details_screen.dart';
import '../components/bottom_nav_bar.dart';
import '../components/buy_land_related/sign_in_bottom_sheet.dart';

/// Defines the type of geo search:
/// - point: a single location (with a given radius)
/// - polygon: a drawn or selected area (2D)
enum GeoSearchType { point, polygon }

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

  // Variables for location search
  Map<String, dynamic>? selectedPlace;
  double searchRadius = 10; // in kilometers

  // Administrative area filters
  String? selectedCity;
  String? selectedDistrict;
  String? selectedPincode;
  String? selectedState;

  // Geo search type & supporting variable for 2D area searches
  GeoSearchType geoSearchType = GeoSearchType.point; // Default to point search
  List<LatLng>? selectedPolygon; // For 2D (area) searches

  Future<List<Property>>? _propertyFuture;

  @override
  void initState() {
    super.initState();
    _propertyFuture = fetchPropertiesWithGeo();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Fetch properties based on geo-search type.
  /// • For polygon searches, it computes the bounding box of the polygon,
  ///   fetches properties within that box, and then filters client-side using
  ///   a point-in-polygon test.
  /// • For point searches, it uses the selectedPlace with a search radius.
  Future<List<Property>> fetchPropertiesWithGeo() async {
    print('fetchPropertiesWithGeo called with filters:');
    print('  selectedPropertyTypes: $selectedPropertyTypes');
    print('  selectedPriceRange: $selectedPriceRange');
    print('  selectedLandAreaRange: $selectedLandAreaRange');
    print('  selectedCity: $selectedCity');
    print('  selectedDistrict: $selectedDistrict');
    print('  selectedPincode: $selectedPincode');
    print('  selectedPlace: $selectedPlace');
    print('  geoSearchType: $geoSearchType');
    print('  selectedPolygon: $selectedPolygon');
    print('  searchRadius: $searchRadius');

    final propertyService = context.read<PropertyService>();

    double? minLat, maxLat, minLon, maxLon;

    if (geoSearchType == GeoSearchType.polygon &&
        selectedPolygon != null &&
        selectedPolygon!.isNotEmpty) {
      // 2D area search: compute bounding box from polygon
      minLat = selectedPolygon!.map((p) => p.latitude).reduce(math.min);
      maxLat = selectedPolygon!.map((p) => p.latitude).reduce(math.max);
      minLon = selectedPolygon!.map((p) => p.longitude).reduce(math.min);
      maxLon = selectedPolygon!.map((p) => p.longitude).reduce(math.max);
    } else if (selectedPlace != null) {
      // Point search: use selectedPlace with a search radius
      double lat = selectedPlace!['geometry']['location']['lat'];
      double lon = selectedPlace!['geometry']['location']['lng'];
      double radiusInDegrees =
          searchRadius / 111; // Approx conversion km -> degrees
      minLat = lat - radiusInDegrees;
      maxLat = lat + radiusInDegrees;
      minLon = lon - radiusInDegrees;
      maxLon = lon + radiusInDegrees;
    }

    // When using geo-based search, we relax the pincode filter by passing null.
    List<Property> properties = await propertyService.getPropertiesWithFilters(
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
      // Relax the pincode filter if a place is selected (i.e. using geo search).
      pincode: (selectedPlace != null) ? null : selectedPincode,
    );

    // For polygon searches, further filter properties using point-in-polygon test.
    if (geoSearchType == GeoSearchType.polygon &&
        selectedPolygon != null &&
        selectedPolygon!.isNotEmpty) {
      properties = properties.where((property) {
        return isPointInsidePolygon(
            LatLng(property.latitude, property.longitude), selectedPolygon!);
      }).toList();
    }

    return properties;
  }

  /// Helper: Check if a point is inside a polygon using the ray-casting algorithm.
  bool isPointInsidePolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      if (_rayCastIntersect(point, polygon[j], polygon[j + 1])) {
        intersectCount++;
      }
    }
    // Check edge between last and first point.
    if (_rayCastIntersect(point, polygon.last, polygon.first)) {
      intersectCount++;
    }
    return (intersectCount % 2) == 1;
  }

  bool _rayCastIntersect(LatLng point, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = point.latitude;
    double pX = point.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false;
    }
    double m = (bY - aY) / (bX - aX);
    double x = (pY - aY) / m + aX;
    return x > pX;
  }

  /// Opens the filter bottom sheet and applies filters.
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
        // Optionally, update geoSearchType here if your filters include it.
        _propertyFuture = fetchPropertiesWithGeo(); // Update the property list
      });
    }
  }

  void _handlePlaceSelected(Map<String, dynamic> place) {
    setState(() {
      selectedPlace = place;

      // Reset administrative filters.
      selectedCity = null;
      selectedDistrict = null;
      selectedPincode =
          null; // <-- Remove the pincode filter for geo-based search.
      selectedState = null;

      // Extract administrative components.
      if (place['address_components'] != null) {
        for (var component in place['address_components']) {
          var types = component['types'] as List<dynamic>;
          if (types.contains('locality')) {
            selectedCity = component['long_name'];
          } else if (types.contains('administrative_area_level_2')) {
            selectedDistrict = component['long_name'];
          } else if (types.contains('postal_code')) {
            // Instead of using postal_code as a filter, we clear it.
            // selectedPincode = component['long_name'];
            selectedPincode = null;
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

      // For a place selection, default to point search.
      geoSearchType = GeoSearchType.point;
      // Clear any polygon selection.
      selectedPolygon = null;

      _propertyFuture = fetchPropertiesWithGeo();
    });
  }

  Future<bool> _onFavoriteToggle(String propertyId, bool nowFavorited) async {
    // Check if a user is signed in.
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      // Open the sign-in bottom sheet and wait for completion.
      bool signInSuccess = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (context) => const SignInBottomSheet(),
          ) ??
          false;
      // If sign in fails or is cancelled, return false without updating favorite state.
      if (!signInSuccess) {
        return false;
      }
      firebaseUser = FirebaseAuth.instance.currentUser;
      // Double-check sign-in success.
      if (firebaseUser == null) return false;
    }
    try {
      // Update Firestore only if the user is signed in.
      if (nowFavorited) {
        await UserService().addFavoriteProperty(firebaseUser.uid, propertyId);
      } else {
        await UserService()
            .removeFavoriteProperty(firebaseUser.uid, propertyId);
      }
      return true;
    } catch (e) {
      print('Error toggling favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update favorite: $e')),
      );
      return false;
    }
  }

  // Pull-to-refresh method.
  Future<void> _refreshProperties() async {
    setState(() {
      _propertyFuture = fetchPropertiesWithGeo();
    });
  }

  // Helper method to format price.
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
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'LANDANDPLOT',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final navBarState =
                          context.findAncestorStateOfType<BottomNavBarState>();
                      if (navBarState != null) {
                        navBarState.switchTab(2);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Add Property',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: RefreshIndicator(
              onRefresh: _refreshProperties,
              child: Column(
                children: [
                  // Search and Filter Section
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Location Search Bar
                        Expanded(
                          child: LocationSearchBar(
                            onPlaceSelected: _handlePlaceSelected,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Filter Button
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          child: IconButton(
                            icon: const Icon(Icons.tune, color: Colors.white),
                            onPressed: () async {
                              await openFilterBottomSheet();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Toggle Map/List view
                        CircleAvatar(
                          backgroundColor: Colors.green,
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
                  const SizedBox(height: 2),
                  // Property Listings
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
                                                          property: property),
                                                ),
                                              );
                                            },
                                          );
                                  },
                                );
                              } else {
                                return showMap
                                    ? PropertyMapView(properties: properties)
                                    : PropertyListView(
                                        properties: properties,
                                        favoritedPropertyIds: [],
                                        onFavoriteToggle: _onFavoriteToggle,
                                        onTapProperty: (property) {
                                          Navigator.push(
                                            childContext,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  PropertyDetailsScreen(
                                                      property: property),
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
