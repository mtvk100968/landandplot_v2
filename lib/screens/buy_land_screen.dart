import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/filter_config.dart' as fc;
import '../models/property_type.dart' as pt;
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
  bool showMap = true;
  Timer? _debounce;

  // Define filter variables
  List<String> selectedPropertyTypes = [];
  RangeValues selectedPriceRange = const RangeValues(0, 0);
  String pricePerUnitUnit = '';
  RangeValues selectedLandAreaRange = const RangeValues(0, 0);
  String landAreaUnit = '';

  // Variables for location search
  Map<String, dynamic>? selectedPlace;
  double searchRadius = 50; // in kilometers

  // Administrative area filters
  String? selectedCity;
  String? selectedDistrict;
  String? selectedPincode;
  String? selectedState;
  pt.PropertyType? _selectedType;
  int? _selectedBedrooms;
  int? _selectedBathrooms;

  // Geo search type & supporting variable for 2D area searches
  GeoSearchType geoSearchType = GeoSearchType.point; // Default to point search
  List<LatLng>? selectedPolygon; // For 2D (area) searches

  Future<List<Property>>? _propertyFuture;

  @override
  void initState() {
    super.initState();
    _propertyFuture = fetchPropertiesWithGeo();
  }

  Future<void> _refreshProperties() async {
    setState(() {
      _propertyFuture = fetchPropertiesWithGeo();
    });
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
  Future<List<Property>> fetchPropertiesWithGeo({
    Map<String,dynamic>? place,
    List<String>? types,
    RangeValues? priceRange,
    RangeValues? areaRange,
    int? beds,
    int? baths,
  }) async {
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

    print('UI-selections (labels): $selectedPropertyTypes');

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
      final lat = selectedPlace!['geometry']['location']['lat'];
      final lon = selectedPlace!['geometry']['location']['lng'];
      final radiusInDegrees =
          searchRadius / 111; // Approx conversion km -> degrees
      minLat = lat - radiusInDegrees;
      maxLat = lat + radiusInDegrees;
      minLon = lon - radiusInDegrees;
      maxLon = lon + radiusInDegrees;
    }

    // 2️⃣ Turn your UI‐labels into enums, then into actual Firestore keys:
    final selectedEnums = selectedPropertyTypes
        .map((label) => pt.PropertyType.fromLabel(label))
        .toList();

    // 1️⃣ Build your list of Firestore keys (including expanding “Development”):
    final typesForQuery = selectedPropertyTypes
        .map((label) => pt.PropertyType.fromLabel(label))
        .expand<String>((t) {
      if (t == pt.PropertyType.development) {
        return ['development_plot', 'development_land'];
      }
      return [t.firestoreKey];
    })
        .toList();

    print('→ querying Firestore for types: $typesForQuery');
    
    // If any dwelling type is selected, **don't** filter by area:
    const dwellings = {
      pt.PropertyType.house,
      pt.PropertyType.apartment,
      pt.PropertyType.villa,
      pt.PropertyType.commercialSpace,
    };

    bool isDwelling = selectedPropertyTypes
        .map((l) => pt.PropertyType.fromLabel(l))
        .any(dwellings.contains);

    double? minPrice = isDwelling ? null : (selectedPriceRange.start > 0 ? selectedPriceRange.start : null);
    double? maxPrice = isDwelling ? null : (selectedPriceRange.end   > 0 ? selectedPriceRange.end   : null);
    double? minArea  = isDwelling ? null : (selectedLandAreaRange.start > 0 ? selectedLandAreaRange.start : null);
    double? maxArea  = isDwelling ? null : (selectedLandAreaRange.end   > 0 ? selectedLandAreaRange.end   : null);

    if (selectedEnums.any(dwellings.contains)) {
      minArea = maxArea = null;
    }

    // 4️⃣ Ask your service with **only** typesForQuery
    var properties = await context
        .read<PropertyService>()
        .getPropertiesWithFilters(
      propertyTypes:   typesForQuery,
      minPricePerUnit: minPrice,
      maxPricePerUnit: maxPrice,
      minLandArea:     minArea,
      maxLandArea:     maxArea,
      minLat:          minLat,
      maxLat:          maxLat,
      minLon:          minLon,
      maxLon:          maxLon,
      city:            geoSearchType == GeoSearchType.point
          ? null
          : selectedCity,
      district:        geoSearchType == GeoSearchType.point
          ? null
          : selectedDistrict,
      pincode:         geoSearchType == GeoSearchType.point
          ? null
          : selectedPincode,
    );

    // For polygon searches, further filter properties using point-in-polygon test.
    // 3️⃣ If polygon search, filter in-memory:
    List<Property> filteredProperties = properties;
    if (geoSearchType == GeoSearchType.polygon &&
        selectedPolygon != null &&
        selectedPolygon!.isNotEmpty) {
      filteredProperties = properties.where((p) {
        return isPointInsidePolygon(
          LatLng(p.latitude, p.longitude),
          selectedPolygon!,
        );
      }).toList();
    }

    return filteredProperties;
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

  /// Opens the filter bottom sheet and applies or resets filters.
  Future<void> openFilterBottomSheet() async {
    // Seed the dropdown from your existing selection, if any:
    final seedType = selectedPropertyTypes.isNotEmpty
        ? pt.PropertyType.values.firstWhere(
          (t) =>
      t.toString().split('.').last == selectedPropertyTypes.first,
      orElse: () => pt.PropertyType.values.first,
    )
        : null;

    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.6, // ← occupies 60% of the screen height
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: FilterBottomSheet(
              initialType: seedType,
              initialPlace: selectedPlace,
              initialMinPrice: selectedPriceRange.start,
              initialMaxPrice: selectedPriceRange.end,
              initialMinArea: selectedLandAreaRange.start,
              initialMaxArea: selectedLandAreaRange.end,
              initialBeds: _selectedBedrooms,
              initialBaths: _selectedBathrooms,
            ),
          ),
        );
      },
    );

    if (result == null) {
      // User tapped “X” or “Reset” → clear filters and reload everything
      setState(() {
        _selectedType = null;
        selectedPropertyTypes = [];
        selectedPlace = null;
        selectedPriceRange = const RangeValues(0, 0);
        selectedLandAreaRange = const RangeValues(0, 0);
        _selectedBedrooms = null;
        _selectedBathrooms = null;
        _propertyFuture = fetchPropertiesWithGeo(); // unfiltered
      });
    } else {
      // Apply the filters they picked:
      setState(() {
        _selectedType = result['type'] as pt.PropertyType?;
        selectedPropertyTypes = _selectedType != null
            ? [ _selectedType!.label ]    // ← use the exact DB label
            : [];
        selectedPlace = result['place'] as Map<String, dynamic>?;
        selectedPriceRange = result['price'] as RangeValues;
        selectedLandAreaRange = result['area'] as RangeValues;
        _selectedBedrooms = result['beds'] as int?;
        _selectedBathrooms = result['baths'] as int?;
        // re‐run your filtered query:
        _propertyFuture = fetchPropertiesWithGeo();
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
            // in BuyLandScreenState.build, replace your appBar with:
            appBar: AppBar(
              title: const SizedBox(),
              centerTitle: false,
              titleSpacing: 0,
              flexibleSpace: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      // Give the logo 75% of the space:
                      Expanded(
                        flex: 4,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Image.asset('assets/images/splash.png'),
                        ),
                      ),

                      // Add some white space between logo & button:
                      const SizedBox(width: 16),

                      // Give the button 25% of the space, right-aligned:
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              final nav = context
                                  .findAncestorStateOfType<BottomNavBarState>();
                              if (nav != null) nav.switchTab(2);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4C7040),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Add Property',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                          backgroundColor: Color(0xFF4C7040),
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
                          backgroundColor: const Color(0xFF4C7040),
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
                        }
                        if (propertySnapshot.hasError) {
                          return const Center(
                              child: Text('Error loading properties'));
                        }

                        final props = propertySnapshot.data ?? [];

                        // Build once
                        final mapView = PropertyMapView(
                          properties: props,
                          center: selectedPlace != null
                              ? LatLng(
                                  selectedPlace!['geometry']['location']['lat'],
                                  selectedPlace!['geometry']['location']['lng'],
                                )
                              : null,
                        );

                        final listView = StreamBuilder<User?>(
                          stream: FirebaseAuth.instance.authStateChanges(),
                          builder: (authCtx, authSnap) {
                            final favIds = authSnap.hasData
                                ? (authSnap.data != null
                                    ? StreamBuilder<AppUser?>(
                                        stream: UserService()
                                            .getUserStream(authSnap.data!.uid),
                                        builder: (uCtx, uSnap) {
                                          final ids = uSnap
                                                  .data?.favoritedPropertyIds ??
                                              [];
                                          return PropertyListView(
                                            properties: props,
                                            favoritedPropertyIds: ids,
                                            selectedCity: selectedCity,
                                            onFavoriteToggle: _onFavoriteToggle,
                                            onTapProperty: (p) =>
                                                Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      PropertyDetailsScreen(
                                                          property: p)),
                                            ),
                                          );
                                        },
                                      )
                                    : const SizedBox())
                                : const SizedBox();

                            return authSnap.hasData
                                ? favIds as Widget
                                : PropertyListView(
                                    properties: props,
                                    favoritedPropertyIds: [],
                                    selectedCity: selectedCity,
                                    onFavoriteToggle: _onFavoriteToggle,
                                    onTapProperty: (p) => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => PropertyDetailsScreen(
                                              property: p)),
                                    ),
                                  );
                          },
                        );

                        // Empty-state
                        if (props.isEmpty) {
                          return showMap ? mapView : listView;
                        }

                        // Normal
                        return showMap ? mapView : listView;
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
