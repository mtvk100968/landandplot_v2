import 'dart:async';

import 'package:flutter/material.dart';
import '../services/property_service.dart';
import '../models/property_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../components/views/property_list_view.dart';
import '../../components/views/property_map_view.dart';
import '../../components/filter_bottom_sheet.dart';

class BuyLandScreen extends StatefulWidget {
  const BuyLandScreen({super.key});

  @override
  BuyLandScreenState createState() => BuyLandScreenState();
}

class BuyLandScreenState extends State<BuyLandScreen> {
  bool showMap = false; // Toggle between list and map view
  Timer? _debounce;
  TextEditingController _searchController = TextEditingController();

  // Define filter variables
  List<String> selectedPropertyTypes = [];
  RangeValues selectedPriceRange = const RangeValues(0, 0);
  String pricePerUnitUnit = '';
  RangeValues selectedLandAreaRange = const RangeValues(0, 0);
  String landAreaUnit = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Property>> fetchProperties() async {
    PropertyService propertyService = PropertyService();

    // Get the search query
    final searchQuery = _searchController.text.trim();

    // Check if filters are applied
    if (selectedPropertyTypes.isNotEmpty) {
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
        searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
      );
    } else {
      return await propertyService.getAllProperties(
        searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
      );
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LANDANDPLOT',
          style: TextStyle(
            color: Colors.green,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          FutureBuilder<bool>(
            future: isLoggedIn(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink(); // Or a placeholder widget
              } else if (snapshot.hasData && snapshot.data!) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    Navigator.pushReplacementNamed(context, '/profile');
                    await FirebaseAuth.instance.signOut();
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
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // **Search Bar**
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search properties...',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    onChanged: (value) {
                      // Debounce the search input
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        setState(() {});
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // **Filter Button**
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
                // **Toggle Button (Map/List)**
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
          // **Active Filters**
          if (selectedPropertyTypes.isNotEmpty ||
              (selectedPriceRange.start > 0 && selectedPriceRange.end > 0) ||
              (selectedLandAreaRange.start > 0 &&
                  selectedLandAreaRange.end > 0))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8.0,
                children: [
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
          const SizedBox(height: 10),
          // **Property Listings**
          Expanded(
            child: FutureBuilder<List<Property>>(
              future: fetchProperties(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading properties'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No properties found'));
                } else {
                  final properties = snapshot.data!;
                  // Toggle between Map View and List View
                  return showMap
                      ? PropertyMapView(properties: properties) // Map View
                      : PropertyListView(properties: properties); // List View
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
