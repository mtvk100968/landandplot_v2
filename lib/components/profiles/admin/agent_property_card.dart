import 'package:flutter/material.dart';
import '../../../models/property_model.dart';
import 'mini-components/timeline_view.dart';
import 'mini-components/interested_visited_tabs.dart';
import '../../../models/buyer_model.dart';

class AgentPropertyCard extends StatefulWidget {
  final Property property;
  const AgentPropertyCard({Key? key, required this.property}) : super(key: key);

  @override
  _AgentPropertyCardState createState() => _AgentPropertyCardState();
}

class _AgentPropertyCardState extends State<AgentPropertyCard> {
  bool isExpanded = false;

  String get saleStatus {
    if (widget.property.proposedPrices.isNotEmpty) {
      return widget.property.proposedPrices.first['saleStatus'] ?? '';
    }
    return '';
  }

  Widget _detailText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text('$label: $value',
          style: const TextStyle(fontSize: 14, color: Colors.black87)),
    );
  }

  Widget _buildPropertyDetails(Property property) {
    final addressParts = [
      property.ventureName,
      property.address,
      property.village,
      property.mandal,
      property.district,
      property.state,
    ].where((part) => part != null && part.trim().isNotEmpty).toList();

    final formattedAddress = addressParts.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _detailText('Survey Number', property.surveyNumber),
        if (property.plotNumbers.isNotEmpty)
          _detailText('Plot Numbers', property.plotNumbers.join(', ')),
        _detailText('Address', formattedAddress),
        // Display property price.
        _detailText('Price', '\$${property.totalPrice}'),
        _detailText('Price Per Unit', '\$${property.pricePerUnit}'),
        // Display property area with conditional unit based on property type.
        _detailText(
          'Area (${property.propertyType.toLowerCase().contains("agri") ? "acre" : "sqyds"})',
          property.landArea.toString(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSaleInitiated = saleStatus.isNotEmpty;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          ListTile(
            title: Text(
                '${widget.property.propertyOwner} / ${widget.property.mobileNumber}'),
            subtitle: Text(widget.property.propertyType),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => isExpanded = !isExpanded),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPropertyDetails(widget.property),
                  const SizedBox(height: 10),
                  isSaleInitiated
                      ? Container(
                          height: 300,
                          child: TimelineView(saleStatus: saleStatus),
                        )
                      : Container(
                          height: 300,
                          child:
                              InterestedVisitedTabs(property: widget.property),
                        ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
