import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/property_service.dart';
import '../models/property_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../components/views/property_list_view.dart';
import '../../components/views/property_map_view.dart';
import '../../providers/filter_provider.dart';
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

  @override
  void dispose() {
    _debounce
        ?.cancel(); // Cancels any active Timer to prevent unnecessary executions.
    _searchController
        .dispose(); // Releases resources used by the TextEditingController to avoid memory leaks.
    super
        .dispose(); // Calls the parent class's dispose method to complete the cleanup process.
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FilterProvider(),
      builder: (context, child) {
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
          body: Consumer<FilterProvider>(
            builder: (context, filterProvider, child) {
              return Column(
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
                              // Implement search logic if needed
                              // For now, we'll debounce the search input
                              if (_debounce?.isActive ?? false)
                                _debounce!.cancel();
                              _debounce =
                                  Timer(const Duration(milliseconds: 500), () {
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
                              final result = await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  return const FilterBottomSheet();
                                },
                              );
                              if (result == true) {
                                // User applied filters, refresh the property list
                                setState(() {});
                              }
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
                  // Active Filters
                  if (filterProvider.hasFiltersApplied)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Wrap(
                        spacing: 8.0,
                        children: [
                          for (var type in filterProvider.selectedPropertyTypes)
                            Chip(label: Text(type)),
                          if (filterProvider.pricePerUnitUnit.isNotEmpty)
                            Chip(
                              label: Text(
                                'Price: ${filterProvider.formatPrice(filterProvider.selectedPriceRange.start)} - ${filterProvider.formatPrice(filterProvider.selectedPriceRange.end)} ${filterProvider.pricePerUnitUnit}',
                              ),
                            ),
                          if (filterProvider.landAreaUnit.isNotEmpty)
                            Chip(
                              label: Text(
                                'Area: ${filterProvider.selectedLandAreaRange.start.toStringAsFixed(1)} - ${filterProvider.selectedLandAreaRange.end.toStringAsFixed(1)} ${filterProvider.landAreaUnit}',
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  // Property Listings
                  Expanded(
                    child: FutureBuilder<List<Property>>(
                      future: fetchProperties(filterProvider),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text(
                                  'Error loading properties: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No properties found'));
                        } else {
                          final properties = snapshot.data!;
                          // Toggle between Map View and List View
                          return showMap
                              ? PropertyMapView(
                                  properties: properties) // Map View
                              : PropertyListView(
                                  properties: properties); // List View
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<List<Property>> fetchProperties(FilterProvider filterProvider) async {
    PropertyService propertyService = PropertyService();

    // Get the search query
    final searchQuery = _searchController.text.trim();

    // Debugging: Print the current filters
    print('Fetching properties with the following filters:');
    print('Search Query: "$searchQuery"');
    print('Selected Property Types: ${filterProvider.selectedPropertyTypes}');
    print('Min Price Per Unit: ${filterProvider.selectedPriceRange.start}');
    print('Max Price Per Unit: ${filterProvider.selectedPriceRange.end}');
    print('Min Land Area: ${filterProvider.selectedLandAreaRange.start}');
    print('Max Land Area: ${filterProvider.selectedLandAreaRange.end}');

    try {
      // Check if filters are applied
      if (filterProvider.hasFiltersApplied) {
        return await propertyService.getPropertiesWithFilters(
          propertyTypes: filterProvider.selectedPropertyTypes,
          minPricePerUnit: filterProvider.selectedPriceRange.start,
          maxPricePerUnit: filterProvider.selectedPriceRange.end,
          minLandArea: filterProvider.selectedLandAreaRange.start,
          maxLandArea: filterProvider.selectedLandAreaRange.end,
          searchQuery: searchQuery,
        );
      } else {
        // Fetch all properties, possibly with search
        return await propertyService.getAllProperties(searchQuery: searchQuery);
      }
    } catch (e) {
      print('Error in fetchProperties: $e');
      rethrow;
    }
  }

  Future<bool> isLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }
}
