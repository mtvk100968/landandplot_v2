// lib/components/profiles/user/buying/rejected_card.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';

class RejectedCard extends StatelessWidget {
  final Property property;
  final String userPhone; // matches Buyer.phone
  const RejectedCard({
    Key? key,
    required this.property,
    required this.userPhone,
  }) : super(key: key);

  // Buyer? get _thisBuyer {
  //   return property.buyers.firstWhere(
  //     (b) => b.phone == userPhone && b.status == 'rejected',
  //     orElse: () => null,
  //   );
  // }

  Buyer? get _thisBuyer {
    try {
      return property.buyers.firstWhere(
            (b) => b.phone == userPhone && b.status == 'bought',
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final buyer = _thisBuyer;
    if (buyer == null) return const SizedBox.shrink();

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

            // Rejection Details
            const Text('Status: Rejected',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 8),
            if (buyer.lastUpdated != null)
              Text(
                'Rejected On: ${buyer.lastUpdated!.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(color: Colors.grey),
              ),

            if (buyer.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Notes:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...buyer.notes.map((n) => Text('- $n')),
            ],
          ],
        ),
      ),
    );
  }
}
