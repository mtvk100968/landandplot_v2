// lib/screens/buy_land_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/property_service.dart';
import '../models/property_model.dart';
import '../providers/filter_provider.dart';
import '../components/filters/property_type_filter.dart';
import '../components/filters/land_area_filter.dart';
import '../components/filters/price_filter.dart';
import '../components/filters/active_filters_chips.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/views/property_list_view.dart';
import '../components/views/property_map_view.dart';
import '../utils/format.dart';

class BuyLandScreen extends StatefulWidget {
  const BuyLandScreen({super.key});

  @override
  BuyLandScreenState createState() => BuyLandScreenState();
}

class BuyLandScreenState extends State<BuyLandScreen> {
  bool showMap = false; // Toggle between list and map view
  Timer? _debounce;
  TextEditingController _searchController = TextEditingController();

  Future<List<Property>> fetchProperties(
      FilterProvider filterProvider, String query) async {
    PropertyService propertyService = PropertyService();

    return await propertyService.getFilteredProperties(
      propertyType: filterProvider.selectedPropertyType,
      landAreaRange: filterProvider.landAreaRange,
      priceRange: filterProvider.priceRange,
      // searchQuery:
      // query, // Assuming you have implemented search in your service
    );
  }

  Future<bool> isLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  void _onFilterChanged(FilterProvider filterProvider) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        // Rebuild to fetch filtered properties
      });
    });
  }

  void _onSearchChanged(FilterProvider filterProvider) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        // Rebuild to fetch filtered properties with search query
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final filterProvider =
          Provider.of<FilterProvider>(context, listen: false);
      _onSearchChanged(filterProvider);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FilterProvider>(
      create: (_) => FilterProvider(),
      child: Scaffold(
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
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/login');
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
                        ),
                      ),
                      const SizedBox(width: 8),
                      // **Filter Button**
                      CircleAvatar(
                        backgroundColor: Colors.green,
                        child: IconButton(
                          icon: const Icon(Icons.tune, color: Colors.white),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      PropertyTypeFilter(),
                                      LandAreaFilter(),
                                      PriceFilter(),
                                    ],
                                  ),
                                );
                              },
                            );
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
                const ActiveFiltersChips(),
                const SizedBox(height: 10),
                // **Property Listings**
                Expanded(
                  child: FutureBuilder<List<Property>>(
                    future:
                        fetchProperties(filterProvider, _searchController.text),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error loading properties'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No properties found'));
                      } else {
                        final properties = snapshot.data!;
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
      ),
    );
  }
}
