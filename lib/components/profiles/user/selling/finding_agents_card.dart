// lib/components/profiles/user/selling/finding_agents_card.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';

class FindingAgentsCard extends StatelessWidget {
  final Property property;
  const FindingAgentsCard({Key? key, required this.property}) : super(key: key);

  String get _address {
    if (property.address != null && property.address!.isNotEmpty) {
      return property.address!;
    }
    final parts = [
      property.village,
      property.taluqMandal,
      property.city,
      property.state,
      property.pincode
    ];
    return parts.where((p) => p!.isNotEmpty).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          // TODO: navigate to original listing
          // Navigator.of(context).push(
          //   MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: property)),
          // );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _address,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Price: ₹${property.totalPrice.toStringAsFixed(0)}'),
                  Text('Area: ${property.landArea.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 4),
              Text('₹${property.pricePerUnit.toStringAsFixed(0)}/unit'),
              const Divider(height: 20),
              Text(
                'Assigning agents to your property…',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
