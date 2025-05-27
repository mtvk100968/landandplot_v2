// lib/components/profiles/user/selling/finding_buyers_card.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';

class FindingBuyersCard extends StatelessWidget {
  final Property property;
  const FindingBuyersCard({Key? key, required this.property}) : super(key: key);

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
    return parts.where((p) => p != null && p.isNotEmpty).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final assignedAgents = property.assignedAgentIds;
    final agentLabels = List.generate(
      assignedAgents.length,
      (i) => String.fromCharCode(65 + i), // A, B, C...
    );
    final interested =
        property.buyers.where((b) => b.status == 'visitPending').toList();
    final visited =
        property.buyers.where((b) => b.status != 'visitPending').toList();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header: address / price / area / ppu
            Text(_address,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

            // agent labels
            if (agentLabels.isNotEmpty) ...[
              const Text('Agents:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ToggleButtons(
                isSelected: List.filled(agentLabels.length, false),
                onPressed: (_) {},
                borderRadius: BorderRadius.circular(6),
                children: agentLabels
                    .map((l) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(l),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            // interested buyers
            const Text('Interested Buyers',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...interested.map((b) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(b.name),
                  subtitle: Text(b.phone),
                  trailing: agentLabels.length > 1
                      ? Chip(
                          label: Text(
                              /* TODO: lookup this buyer’s agent label */ 'A'))
                      : null,
                )),

            const SizedBox(height: 16),
            // visited buyers
            const Text('Visited Buyers',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...visited.map((b) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(b.name),
                  subtitle: Text(b.phone),
                  trailing: agentLabels.length > 1
                      ? Chip(
                          label: Text(
                              /* TODO: lookup this buyer’s agent label */ 'A'))
                      : null,
                )),
          ],
        ),
      ),
    );
  }
}
