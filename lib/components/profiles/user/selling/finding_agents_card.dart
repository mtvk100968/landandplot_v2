import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';

class FindingAgentsCard extends StatefulWidget {
  final Property property;
  const FindingAgentsCard({Key? key, required this.property}) : super(key: key);

  @override
  State<FindingAgentsCard> createState() => _FindingAgentsCardState();
}

class _FindingAgentsCardState extends State<FindingAgentsCard> {
  bool isExpanded = false;

  String get _address {
    final parts = [
      widget.property.ventureName,
      widget.property.address,
      widget.property.village,
      widget.property.taluqMandal,
      widget.property.district,
      widget.property.state,
      widget.property.pincode
    ];
    return parts.where((p) => p != null && p.trim().isNotEmpty).join(', ');
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            title: Text('${property.propertyOwner} / ${property.mobileNumber}',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(property.propertyType),
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
                  _infoRow('Survey Number', property.surveyNumber),
                  if (property.plotNumbers.isNotEmpty)
                    _infoRow('Plot Numbers', property.plotNumbers.join(', ')),
                  _infoRow('Address', _address),
                  _infoRow(
                      'Price', '₹${property.totalPrice.toStringAsFixed(0)}'),
                  _infoRow('Price Per Unit',
                      '₹${property.pricePerUnit.toStringAsFixed(0)}'),
                  _infoRow(
                    'Area (${property.propertyType.toLowerCase().contains("agri") ? "acre" : "sqyds"})',
                    property.landArea.toString(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Assigning agents to your property…',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
