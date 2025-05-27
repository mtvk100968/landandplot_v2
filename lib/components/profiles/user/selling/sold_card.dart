// lib/components/profiles/user/selling/sold_card.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';

class SoldCard extends StatelessWidget {
  final Property property;
  const SoldCard({Key? key, required this.property}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // find the buyer with status 'bought'
    Buyer? buyer;
    try {
      buyer = property.buyers.firstWhere((b) => b.status == 'accepted');
    } catch (_) {
      buyer = null;
    }

    if (buyer == null) {
      return const SizedBox.shrink();
    }

    // use winningAgentId if set, otherwise fallback to first assigned
    final String? agentId = property.winningAgentId?.isNotEmpty == true
        ? property.winningAgentId
        : property.assignedAgentIds.isNotEmpty
            ? property.assignedAgentIds.first
            : null;

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
            const Text('Sold',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Final Documents
            const Text('Final Documents',
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

            const Divider(height: 32),

            // Buyer Details
            const Text('Buyer:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${buyer.name} — ${buyer.phone}'),
            const SizedBox(height: 16),

            // Agent Details
            const Text('Agent:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(agentId != null ? 'Agent ID: $agentId' : 'N/A'),
            const SizedBox(height: 16),

            // Commented out until needed
            // ElevatedButton(
            //   onPressed: () {
            //     // TODO: confirm percentage brokerage
            //   },
            //   child: const Text('Confirm Brokerage'),
            // ),
          ],
        ),
      ),
    );
  }
}
