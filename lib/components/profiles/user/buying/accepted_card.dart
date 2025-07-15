// lib/components/profiles/user/buying/accepted_card.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';
import '../selling/user_timeline_view.dart';

class AcceptedCard extends StatelessWidget {
  final Property property;
  final String userPhone; // matches Buyer.phone
  const AcceptedCard({
    super.key,
    required this.property,
    required this.userPhone,
  });

  // inside AcceptedCard

  Buyer? get _thisBuyer {
    try {
      return property.buyers.firstWhere(
            (b) => b.phone == userPhone && b.status == 'accepted',
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final buyer = _thisBuyer;
    if (buyer == null) return const SizedBox.shrink();

    // only show if the property is in saleInProgress stage
    if (property.stage != 'saleInProgress') return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Header
            Text(
              property.fullAddress,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

            // Buyer Details
            const Text('Buyer Details:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${buyer.name} — ${buyer.phone}'),
            const SizedBox(height: 16),

            // Timeline View (read-only)
            const Text('Sale In Progress Timeline:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            UserTimelineView(buyer: buyer),
          ],
        ),
      ),
    );
  }
}
