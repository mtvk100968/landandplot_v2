import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/dev_subtype.dart';
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
  RangeValues _selectedAreaRange = const RangeValues(0, 0);
  RangeValues _selectedTotalPriceRange = const RangeValues(0, 0);
  RangeValues _selectedUnitPriceRange = const RangeValues(0, 0);
  bool _useTotalPrice = false;
  List<DevSubtype> _selectedDevSubtypes = []; // ✅ Add this here

  String pricePerUnitUnit = '';
  String landAreaUnit = '';

  // Variables for location search
  Map<String, dynamic>? selectedPlace;
  double searchRadius = 50; // in kilometers

  // Administrative area filters
  String? selectedCity;
  String? selectedDistrict;
  String? selectedPincode;
  String? selectedState;
  pt.PropertyType? _type;
  DevSubtype? _devSubtype;
  int? _selectedBedrooms;
  int? _selectedBathrooms;

  // Geo search type & supporting variable for 2D area searches
  GeoSearchType geoSearchType = GeoSearchType.point; // Default to point search
  List<LatLng>? selectedPolygon; // For 2D (area) searches

  Future<List<Property>>? _propertyFuture;

  // for geo-bounds filtering
  double? _minLat, _maxLat, _minLon, _maxLon;

  // for text search
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _propertyFuture = _loadProperties();
  }

  /// Pull-to-refresh just re-invokes the same loader
  Future<void> _refreshProperties() async {
    setState(() {
      _propertyFuture = _loadProperties();
    });
  }

  /// The single place that actually builds your Firestore query
  Future<List<Property>> _loadProperties() {
    final field = _useTotalPrice ? 'totalPrice' : 'pricePerUnit';
    final minP = _useTotalPrice
        ? _selectedTotalPriceRange.start
        : _selectedUnitPriceRange.start;
    final maxP = _useTotalPrice
        ? _selectedTotalPriceRange.end
        : _selectedUnitPriceRange.end;

    return PropertyService().getPropertiesWithFilters(
      propertyTypes:
          selectedPropertyTypes.isEmpty ? null : selectedPropertyTypes,
      priceField: field,
      minPrice: minP > 0 ? minP : null,
      maxPrice: maxP > 0 ? maxP : null,
      minArea: _selectedAreaRange.start > 0 ? _selectedAreaRange.start : null,
      maxArea: _selectedAreaRange.end > 0 ? _selectedAreaRange.end : null,
      bedrooms: _selectedBedrooms,
      bathrooms: _selectedBathrooms,
      // — geo bounds & searchQuery elided for now —
      city: selectedCity,
      district: selectedDistrict,
      pincode: selectedPincode,
      minLat: _minLat,
      maxLat: _maxLat,
      minLon: _minLon,
      maxLon: _maxLon,
      searchQuery: _searchQuery,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> openFilterBottomSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.7,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: FilterBottomSheet(
                initialType: _type,
                initialDevSubtype: _devSubtype,
                selectedDevSubtypes: _selectedDevSubtypes, // ✅ PASS THIS
                initialPlace: selectedPlace,
                initialMinArea: _selectedAreaRange.start,
                initialMaxArea: _selectedAreaRange.end,
                initialTotalMinPrice: _selectedTotalPriceRange.start,
                initialTotalMaxPrice: _selectedTotalPriceRange.end,
                initialUnitMinPrice: _selectedUnitPriceRange.start,
                initialUnitMaxPrice: _selectedUnitPriceRange.end,
                initialBeds: _selectedBedrooms,
                initialBaths: _selectedBathrooms,
              ),
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _type = result['type'] as pt.PropertyType?;
        _devSubtype = result['devSubtype'] as DevSubtype?;
        _useTotalPrice = result['useTotal'] as bool;
        _selectedUnitPriceRange = result['unitPrice'] as RangeValues;
        _selectedTotalPriceRange = result['totalPrice'] as RangeValues;
        _selectedAreaRange = result['area'] as RangeValues;
        _selectedBedrooms = result['beds'] as int?;
        _selectedBathrooms = result['baths'] as int?;
        selectedPlace = result['place'] as Map<String, dynamic>?;

        // ✅ ADD THIS:
        _selectedDevSubtypes = result['devSubtypes']?.cast<DevSubtype>() ?? [];

        selectedPropertyTypes = _type != null ? [_type!.firestoreKey] : [];

        // 🔁 Reload properties after filter
        _propertyFuture = _loadProperties();
      });
    }
  }

//   Future<List<Property>> fetchPropertiesWithGeo({
//     Map<String, dynamic>? place,
//     List<String>? types,
//     RangeValues? priceRange,
//     RangeValues? areaRange,
//     List<int>? beds,
//     List<int>? baths,
//   }) async {
//
//     // 2️⃣ Compute geo‐bounds (unchanged)
//     double? minLat, maxLat, minLon, maxLon;
//     if (geoSearchType == GeoSearchType.polygon && selectedPolygon != null) {
//       minLat = selectedPolygon!.map((p) => p.latitude).reduce(math.min);
//       maxLat = selectedPolygon!.map((p) => p.latitude).reduce(math.max);
//       minLon = selectedPolygon!.map((p) => p.longitude).reduce(math.min);
//       maxLon = selectedPolygon!.map((p) => p.longitude).reduce(math.max);
//     } else if (selectedPlace != null) {
//       final lat = selectedPlace!['geometry']['location']['lat'] as double;
//       final lon = selectedPlace!['geometry']['location']['lng'] as double;
//       final r = searchRadius / 111.0;
//       minLat = lat - r;
//       maxLat = lat + r;
//       minLon = lon - r;
//       maxLon = lon + r;
//     }
//
//     final useTotal = _useTotalPrice;
//     final double? minTotal = (useTotal && priceRange != null && priceRange.start > 0)
//         ? priceRange.start
//         : null;
//     final double? maxTotal = (useTotal && priceRange != null && priceRange.end > 0)
//         ? priceRange.end
//         : null;
//     final double? minUnit = (!useTotal && priceRange != null && priceRange.start > 0)
//         ? priceRange.start
//         : null;
//     final double? maxUnit = (!useTotal && priceRange != null && priceRange.end > 0)
//         ? priceRange.end
//         : null;
//     final double? minArea = (areaRange != null && areaRange.start > 0)
//         ? areaRange.start
//         : null;
//     final double? maxArea = (areaRange != null && areaRange.end > 0)
//         ? areaRange.end
//         : null;
//
//     // ➋ pick the right “area” field
//     String areaField;
//     switch (_type) {
//       case pt.PropertyType.apartment:
//         areaField = 'carpetArea';
//         break;
//       case pt.PropertyType.house:
//       case pt.PropertyType.villa:
//         areaField = 'constructedArea';
//         break;
//       case pt.PropertyType.plot:
//         areaField = 'plotArea';
//         break;
//       default:
//         areaField = 'landArea';
//     }
//
//     // ➌ start a Query<T> (not a CollectionReference)
//     Query<Map<String, dynamic>> query =
//     FirebaseFirestore.instance.collection('properties');
//
//     // ➍ add filters only if non-null
//     if (types != null && types.isNotEmpty) {
//       query = query.where('propertyType', whereIn: types);
//     }
//     if (minTotal != null) query = query.where('totalPrice',   isGreaterThanOrEqualTo: minTotal);
//     if (maxTotal != null) query = query.where('totalPrice',   isLessThanOrEqualTo:    maxTotal);
//     if (minUnit  != null) query = query.where('pricePerUnit', isGreaterThanOrEqualTo: minUnit);
//     if (maxUnit  != null) query = query.where('pricePerUnit', isLessThanOrEqualTo:    maxUnit);
//
//     // ← use the dynamically chosen field name here
//     if (minArea != null) query = query.where(areaField, isGreaterThanOrEqualTo: minArea);
//     if (maxArea != null) query = query.where(areaField, isLessThanOrEqualTo:    maxArea);
//
//     if (beds != null && beds.isNotEmpty) query = query.where('bedrooms', whereIn: beds);
//     if (baths != null && baths.isNotEmpty) query = query.where('bathrooms', whereIn: baths);
//
//
// // …and the rest of your filters…
//
//     if (selectedCity != null)
//       query = query.where('city', isEqualTo: selectedCity);
//     if (selectedDistrict != null)
//       query = query.where('district', isEqualTo: selectedDistrict);
//     if (selectedPincode != null)
//       query = query.where('pincode', isEqualTo: selectedPincode);
//
//     if (minLat != null && maxLat != null) {
//       query = query
//           .where('latitude', isGreaterThanOrEqualTo: minLat)
//           .where('latitude', isLessThanOrEqualTo: maxLat);
//     }
//     if (minLon != null && maxLon != null) {
//       query = query
//           .where('longitude', isGreaterThanOrEqualTo: minLon)
//           .where('longitude', isLessThanOrEqualTo: maxLon);
//     }
//
//
//     // — execute & debug print raw data —
//     final snap = await query.get();
//     final props = snap.docs.map((d) => Property.fromMap(d.id, d.data())).toList();
//     for (var d in snap.docs) {
//       print('🔍 raw ${d.id} → ${d.data()}');
//     }
//
//     // 5️⃣ Client‐side (Dart) filtering for **area** and any remaining ranges:
//     return props.where((p) {
//       // pick the right area value per property
//       final double? areaVal = {
//         pt.PropertyType.apartment: p.carpetArea,
//         pt.PropertyType.house:     p.constructedArea,
//         pt.PropertyType.villa:     p.constructedArea,
//         pt.PropertyType.plot:      p.plotArea,
//       }[_type] ??
//           p.landArea;
//
//       final okArea = (areaRange == null)
//           ? true
//           : (areaRange.start <= areaVal! && areaVal <= areaRange.end);
//
//       // already did price server‐side, so skip price here
//
//       // you can also do geo‐bounds _again_ if you want to double‐check,
//       // or any other custom Dart filters (beds, baths were server‐side)
//
//       return okArea;
//     }).toList();
//   }

  /// Opens the filter bottom sheet and applies or resets filters.

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

      _propertyFuture = _loadProperties();
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
                            ConnectionState.waiting)
                          return const Center(
                              child: CircularProgressIndicator());
                        final props = propertySnapshot.data ?? [];

                        // build both views up front
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
