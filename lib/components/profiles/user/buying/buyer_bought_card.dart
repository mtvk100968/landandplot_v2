// lib/components/profiles/user/buying/buyer_bought_card.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';
import '../selling/selling_timeline_view.dart';
import './buying_detail_screen.dart';

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
    if (buyer == null) {
      return const SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () {
          final buyer = _acceptedBuyer!;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BuyingDetailScreen(
                property: property,
                buyer: buyer,
              ),
            ),
          );
        },
        child: Column(
          children: [
            ListTile(
              title: Text(property.propertyOwner),
              subtitle: Text('${property.propertyType} • Purchased'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SellerTimelineView(buyer: buyer),
            ),
          ],
        ),
      ),
    );
  }
}
