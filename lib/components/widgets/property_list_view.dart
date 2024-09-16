import 'package:flutter/material.dart';
import '../../models/property_model.dart';

class PropertyListView extends StatelessWidget {
  final List<Property> properties;

  const PropertyListView({
    super.key,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        return Card(
          margin: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
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
}
