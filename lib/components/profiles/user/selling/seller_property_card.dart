// lib/components/profiles/user/selling/seller_property_card.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';
import './selling_timeline_view.dart';
import './selling_detail_screen.dart';

class SellerPropertyCard extends StatefulWidget {
  final Property property;
  const SellerPropertyCard({Key? key, required this.property})
      : super(key: key);

  @override
  _SellerPropertyCardState createState() => _SellerPropertyCardState();
}

class _SellerPropertyCardState extends State<SellerPropertyCard> {
  bool isExpanded = false;

  bool get hasAccepted {
    return widget.property.buyers.any((b) => b.status == 'accepted');
  }

  Buyer? get acceptedBuyer {
    try {
      return widget.property.buyers.firstWhere((b) => b.status == 'accepted');
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prop = widget.property;
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SellingDetailScreen(property: prop),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            ListTile(
              title: Text(prop.propertyOwner),
              subtitle: Text(
                  '₹${prop.totalPrice.toStringAsFixed(0)} • ${prop.propertyType}'),
              trailing: IconButton(
                icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () => setState(() => isExpanded = !isExpanded),
              ),
            ),
            if (isExpanded) ...[
              if (hasAccepted && acceptedBuyer != null)
                SellerTimelineView(buyer: acceptedBuyer!)
              else
                Column(
                  children: widget.property.buyers
                      .where((b) => b.status == 'visitPending')
                      .map((b) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(b.phone),
                                if (b.date != null)
                                  Text('Visit: '
                                      '${b.date!.toLocal().toString().split(' ')[0]}'),
                                for (var note in b.notes) Text('• $note'),
                                const Divider(),
                              ],
                            ),
                          ))
                      .toList(),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
