import 'package:flutter/material.dart';
import '../services/property_service.dart';
import '../models/property_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<List<Property>> fetchProperties() async {
    PropertyService propertyService = PropertyService();
    return await propertyService.getAllProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Navigate to the sign-in screen
              Navigator.pushReplacementNamed(context, '/sign_in');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Welcome to the Home Screen!'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the Sell Your Land form
                    Navigator.pushNamed(context, '/sell_land');
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Sell Your Land'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
                  return ListView.builder(
                    itemCount: properties.length,
                    itemBuilder: (context, index) {
                      final property = properties[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            'Land Area: ${property.landArea} Sq Yards',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Price: \$${property.landPrice}\n'
                            'Price per Sq Yard: \$${property.pricePerSqYard}',
                          ),
                          onTap: () {
                            // Handle card tap if needed
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
