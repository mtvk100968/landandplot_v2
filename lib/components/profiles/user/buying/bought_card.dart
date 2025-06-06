// lib/components/profiles/user/buying/bought_card.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';
import '../common/custom_timeline_view.dart';

class BoughtCard extends StatelessWidget {
  final Property property;
  final String userPhone; // matches Buyer.phone
  const BoughtCard({
    Key? key,
    required this.property,
    required this.userPhone,
  }) : super(key: key);

  // Buyer? get _thisBuyer {
  //   return property.buyers.firstWhere(
  //     (b) => b.phone == userPhone && b.status == 'bought',
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

    // only show if the property is sold
    if (property.stage != 'sold') return const SizedBox.shrink();

    // map each step to its list of document URLs
    final docsMap = <String, List<String>>{
      'Interest': buyer.interestDocs,
      'Document Verification': buyer.docVerifyDocs,
      'Legal Due Diligence': buyer.legalCheckDocs,
      'Sale Agreement': buyer.agreementDocs,
      'Stamp Duty & Registration': buyer.registrationDocs,
      'Mutation': buyer.mutationDocs,
      'Possession': buyer.possessionDocs,
    };

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

            // Read-only Timeline View
            const Text('Completed Timeline:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CustomTimelineView(buyer: buyer),
            const SizedBox(height: 16),

            // Final Documents Section
            const Text('All Documents:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...docsMap.entries
                .where((entry) => entry.value.isNotEmpty)
                .map((entry) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.key,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: entry.value
                              .map((url) => GestureDetector(
                                    onTap: () {
                                      // TODO: open URL
                                    },
                                    child: const Chip(label: Text('View')),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}
