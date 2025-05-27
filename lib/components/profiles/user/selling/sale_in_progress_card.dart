// lib/components/profiles/user/selling/sale_in_progress_card.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';
import './user_timeline_view.dart';

class SaleInProgressCard extends StatelessWidget {
  final Property property;
  const SaleInProgressCard({Key? key, required this.property})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // find the accepted buyer
    Buyer? buyer;
    try {
      buyer = property.buyers.firstWhere((b) => b.status == 'accepted');
    } catch (_) {
      buyer = null;
    }

    if (buyer == null) {
      // no accepted buyer yet
      return const SizedBox.shrink();
    }

    // pick the first assigned agent (you can expand this later)
    final agentId = property.assignedAgentIds.isNotEmpty
        ? property.assignedAgentIds.first
        : '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buyer header
            const Text('Buyer Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${buyer.name} — ${buyer.phone}'),
            const SizedBox(height: 16),

            // Agent header
            const Text('Agent Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(agentId.isNotEmpty
                ? 'Agent ID: $agentId'
                : 'No agent assigned'),

            const Divider(height: 32),

            // Timeline view (read-only for the user)
            UserTimelineView(
              buyer: buyer,
            ),
          ],
        ),
      ),
    );
  }
}
