import 'dart:async';

import 'package:flutter/material.dart';
import '../services/property_service.dart';
import '../models/property_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../components/views/property_list_view.dart';
import '../../components/views/property_map_view.dart';

class BuyLandScreen extends StatefulWidget {
  const BuyLandScreen({super.key});

  @override
  BuyLandScreenState createState() => BuyLandScreenState();
}

class BuyLandScreenState extends State<BuyLandScreen> {
  bool showMap = false; // Toggle between list and map view
  Timer? _debounce;
  TextEditingController _searchController = TextEditingController();

  Future<List<Property>> fetchProperties() async {
    PropertyService propertyService = PropertyService();
    return await propertyService.getAllProperties();
  }

  Future<bool> isLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

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
                              bottom: MediaQuery.of(context).viewInsets.bottom,
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
}
