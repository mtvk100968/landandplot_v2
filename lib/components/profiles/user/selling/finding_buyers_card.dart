// lib/components/profiles/user/selling/finding_buyers_card.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';

class FindingBuyersCard extends StatefulWidget {
  final Property property;
  const FindingBuyersCard({Key? key, required this.property}) : super(key: key);

  @override
  State<FindingBuyersCard> createState() => _FindingBuyersCardState();
}

class _FindingBuyersCardState extends State<FindingBuyersCard> {
  bool isExpanded = false;

  String get _address {
    if (widget.property.address != null &&
        widget.property.address!.isNotEmpty) {
      return widget.property.address!;
    }
    final parts = [
      widget.property.village,
      widget.property.taluqMandal,
      widget.property.city,
      widget.property.state,
      widget.property.pincode
    ];
    return parts.where((p) => p != null && p.isNotEmpty).join(', ');
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  Widget _buyerRow(Buyer b, String status) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      title: Text(b.name, style: const TextStyle(fontSize: 14)),
      subtitle: Text(b.phone,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Chip(
        label: Text(status,
            style: const TextStyle(fontSize: 11, color: Colors.black)),
        backgroundColor: status == 'Visited'
            ? Colors.green.shade100
            : Colors.orange.shade100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prop = widget.property;
    final interested =
        prop.buyers.where((b) => b.status == 'visitPending').toList();
    final visited =
        prop.buyers.where((b) => b.status != 'visitPending').toList();
    final assignedAgents = prop.assignedAgentIds;

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
                  _infoRow('Address', _address),
                  _infoRow('Price', '₹${prop.totalPrice.toStringAsFixed(0)}'),
                  _infoRow('Price Per Unit',
                      '₹${prop.pricePerUnit.toStringAsFixed(0)}'),
                  _infoRow(
                    'Area (${prop.propertyType.toLowerCase().contains("agri") ? "acre" : "sqyds"})',
                    prop.landArea.toStringAsFixed(2),
                  ),
                  const SizedBox(height: 8),
                  if (assignedAgents.isNotEmpty) ...[
                    const Text('Assigned Agents:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: assignedAgents
                          .map((a) => Chip(
                                label: Text(a,
                                    style: const TextStyle(fontSize: 12)),
                                backgroundColor: Colors.green.shade50,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const Text('Interested Buyers',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  interested.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text('No interested buyers yet.',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600)),
                        )
                      : Column(
                          children: interested
                              .map((b) => _buyerRow(b, 'Interest'))
                              .toList(),
                        ),
                  const SizedBox(height: 12),
                  const Text('Visited Buyers',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  visited.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text('No visited buyers yet.',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600)),
                        )
                      : Column(
                          children: visited
                              .map((b) => _buyerRow(b, 'Visited'))
                              .toList(),
                        ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
