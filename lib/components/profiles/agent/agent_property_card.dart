import 'package:flutter/material.dart';
import '../../../models/property_model.dart';
import '../../../models/buyer_model.dart';
import 'mini-components/timeline_view.dart';
import 'mini-components/interested_visited_tabs.dart';

class AgentPropertyCard extends StatefulWidget {
  final Property property;
  final String currentAgentId;
  final VoidCallback onBuyerUpdated;
  final bool hideTimelineInFind;
  const AgentPropertyCard({
    Key? key,
    required this.property,
    required this.currentAgentId,
    required this.onBuyerUpdated,
    this.hideTimelineInFind = false,
  }) : super(key: key);

  @override
  _AgentPropertyCardState createState() => _AgentPropertyCardState();
}

class _AgentPropertyCardState extends State<AgentPropertyCard> {
  bool isExpanded = false;

  bool get isSale => widget.property.stage == 'saleInProgress';

  /// grab the one buyer whose status is “accepted”
  Buyer? get acceptedBuyer {
    try {
      return widget.property.buyers.firstWhere((b) => b.status == 'accepted');
    } catch (_) {
      return null;
    }
  }

  Widget _detailText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  Widget _buildPropertyDetails(Property property) {
    final addressParts = [
      property.ventureName,
      property.address,
      property.village,
      property.taluqMandal,
      property.district,
      property.state,
    ].where((p) => p != null && p.trim().isNotEmpty).toList();
    final formattedAddress = addressParts.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _detailText('Survey Number', property.surveyNumber),
        if (property.plotNumbers.isNotEmpty)
          _detailText('Plot Numbers', property.plotNumbers.join(', ')),
        _detailText('Address', formattedAddress),
        _detailText('Price', '₹${property.totalPrice.toStringAsFixed(0)}'),
        _detailText(
            'Price Per Unit', '₹${property.pricePerUnit.toStringAsFixed(0)}'),
        _detailText(
          'Area (${property.propertyType.toLowerCase().contains("agri") ? "acre" : "sqyds"})',
          property.landArea.toString(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final prop = widget.property;
    final inFindTab = prop.stage == 'findingBuyers';
    // decide whether to show the timeline or the Interested/Visited UI
    final showTimeline =
        !widget.hideTimelineInFind && isSale && acceptedBuyer != null;

    return Opacity(
      opacity: inFindTab ? 1.0 : 0.5,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          children: [
            ListTile(
              title: Text('${prop.propertyOwner} / ${prop.mobileNumber}'),
              subtitle: Text(prop.propertyType),
              trailing: IconButton(
                icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () => setState(() => isExpanded = !isExpanded),
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPropertyDetails(prop),
                    const SizedBox(height: 10),
                    showTimeline
                        ? SizedBox(
                      height: 300,
                      child: TimelineView(
                        propertyId: prop.id,
                        buyer: acceptedBuyer!,
                        agentId: widget.currentAgentId,
                      ),
                    )
                        : SizedBox(
                      height: 300,
                      child: InterestedVisitedTabs(
                        property: prop,
                        onBuyerUpdated: widget.onBuyerUpdated,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
