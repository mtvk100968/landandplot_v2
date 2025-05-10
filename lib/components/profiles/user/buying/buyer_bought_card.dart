// lib/components/profiles/user/buying/buyer_bought_card.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';
import '../selling/selling_timeline_view.dart';

class BuyerBoughtCard extends StatelessWidget {
  final Property property;
  const BuyerBoughtCard({Key? key, required this.property}) : super(key: key);

  Buyer? get _acceptedBuyer {
    try {
      return property.buyers.firstWhere((b) => b.status == 'accepted');
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final buyer = _acceptedBuyer;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          ListTile(
            title: Text(property.propertyOwner),
            subtitle: Text('${property.propertyType} • Purchased'),
          ),
          if (buyer != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SellerTimelineView(buyer: buyer),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No completed purchase data available'),
            ),
        ],
      ),
    );
  }
}
