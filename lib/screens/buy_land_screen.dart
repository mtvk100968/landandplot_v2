import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/property_service.dart';
import '../models/property_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../components/widgets/property_list_view.dart';
import '../../components/widgets/property_map_view.dart';

class BuyLandScreen extends StatefulWidget {
  const BuyLandScreen({super.key});

  @override
  BuyLandScreenState createState() => BuyLandScreenState();
}

class BuyLandScreenState extends State<BuyLandScreen> {
  bool showMap = false; // Toggle between list and map view

  Future<List<Property>> fetchProperties() async {
    PropertyService propertyService = PropertyService();
    return await propertyService.getAllProperties();
  }

  Future<bool> isLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LANDANDPLOT'),
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
          // Toggle Button between Map and List
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showMap = false; // Show List View
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: showMap ? Colors.grey : Colors.blue,
                ),
                child: const Text('List View'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showMap = true; // Show Map View
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: showMap ? Colors.blue : Colors.grey,
                ),
                child: const Text('Map View'),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
