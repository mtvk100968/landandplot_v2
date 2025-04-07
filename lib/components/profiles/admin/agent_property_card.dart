import 'package:flutter/material.dart';
import '../../../models/property_model.dart';
import 'mini-components/timeline_view.dart';
import 'mini-components/interested_visited_tabs.dart';

class AgentPropertyCard extends StatefulWidget {
  final Property property;
  const AgentPropertyCard({Key? key, required this.property}) : super(key: key);

  @override
  _AgentPropertyCardState createState() => _AgentPropertyCardState();
}

class _AgentPropertyCardState extends State<AgentPropertyCard> {
  bool isExpanded = false;

  String get saleStatus {
    // Here we use the proposedPrices list to simulate sale status.
    // You might want to add a dedicated field (e.g., property.saleStatus) in your model.
    if (widget.property.proposedPrices.isNotEmpty) {
      return widget.property.proposedPrices.first['saleStatus'] ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final bool isSaleInitiated = saleStatus.isNotEmpty;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.property.name),
            subtitle: Text(widget.property.propertyType),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => isExpanded = !isExpanded),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: isSaleInitiated
                  ? TimelineView(saleStatus: saleStatus)
                  : const InterestedVisitedTabs(),
            ),
        ],
      ),
    );
  }
}
