import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';

class SoldCard extends StatefulWidget {
  final Property property;
  const SoldCard({Key? key, required this.property}) : super(key: key);

  @override
  State<SoldCard> createState() => _SoldCardState();
}

class _SoldCardState extends State<SoldCard> {
  bool isExpanded = false;

  Buyer? get _buyer {
    try {
      return widget.property.buyers.firstWhere((b) => b.status == 'accepted');
    } catch (_) {
      return null;
    }
  }

  String? get _agentId {
    final p = widget.property;
    if (p.winningAgentId != null && p.winningAgentId!.isNotEmpty) {
      return p.winningAgentId;
    } else if (p.assignedAgentIds.isNotEmpty) {
      return p.assignedAgentIds.first;
    }
    return null;
  }

  Widget _docSection(String label, List<String> docs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: docs
                .map(
                  (url) => GestureDetector(
                    onTap: () {
                      // TODO: open doc url
                    },
                    child: const Chip(
                      label: Text('View'),
                      backgroundColor: Color(0xFFE3F2FD),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$title: $value',
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prop = widget.property;
    final buyer = _buyer;
    final agentId = _agentId;

    if (buyer == null) return const SizedBox.shrink();

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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  const Text(
                    'Final Sale Documents',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...docsMap.entries
                      .where((e) => e.value.isNotEmpty)
                      .map((e) => _docSection(e.key, e.value)),
                  const Divider(height: 32),
                  const Text(
                    'Buyer Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _infoRow('Name', buyer.name),
                  _infoRow('Phone', buyer.phone),
                  const SizedBox(height: 16),
                  const Text(
                    'Agent Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(agentId != null ? 'Agent ID: $agentId' : 'N/A',
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
