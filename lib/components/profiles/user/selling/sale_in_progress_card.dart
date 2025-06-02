// lib/components/profiles/user/selling/sale_in_progress_card.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';
import './user_timeline_view.dart';

class SaleInProgressCard extends StatefulWidget {
  final Property property;
  const SaleInProgressCard({Key? key, required this.property})
      : super(key: key);

  @override
  State<SaleInProgressCard> createState() => _SaleInProgressCardState();
}

class _SaleInProgressCardState extends State<SaleInProgressCard> {
  bool isExpanded = false;

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prop = widget.property;

    // find the accepted buyer
    Buyer? buyer;
    try {
      buyer = prop.buyers.firstWhere((b) => b.status == 'accepted');
    } catch (_) {
      buyer = null;
    }

    if (buyer == null) {
      return const SizedBox.shrink();
    }

    // pick the first assigned agent
    final agentId =
        prop.assignedAgentIds.isNotEmpty ? prop.assignedAgentIds.first : '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            title: Text('${prop.propertyOwner} / ${prop.mobileNumber}',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(prop.propertyType),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => isExpanded = !isExpanded),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Buyer Details',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('${buyer.name} — ${buyer.phone}',
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                  const Text('Agent Details',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    agentId.isNotEmpty
                        ? 'Agent ID: $agentId'
                        : 'No agent assigned',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Divider(height: 32),
                  SizedBox(
                    height: 300,
                    child: UserTimelineView(buyer: buyer),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
