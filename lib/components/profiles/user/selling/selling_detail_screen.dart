// lib/components/profiles/user/selling/selling_detail_screen.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';
import './selling_timeline_view.dart';
import '../mini-components/interested_visited_tabs.dart';

class SellingDetailScreen extends StatefulWidget {
  final Property property;
  const SellingDetailScreen({Key? key, required this.property})
      : super(key: key);

  @override
  _SellingDetailScreenState createState() => _SellingDetailScreenState();
}

class _SellingDetailScreenState extends State<SellingDetailScreen> {
  late Property property;

  @override
  void initState() {
    super.initState();
    property = widget.property;
  }

  @override
  Widget build(BuildContext context) {
    // find accepted buyer if any
    Buyer? acceptedBuyer;
    try {
      acceptedBuyer = property.buyers.firstWhere((b) => b.status == 'accepted');
    } catch (_) {
      acceptedBuyer = null;
    }

    return Scaffold(
      appBar: AppBar(title: Text(property.propertyOwner)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            SizedBox(
              height: 200,
              child: property.images.isNotEmpty
                  ? PageView(
                      children: property.images
                          .map((url) => Image.network(url, fit: BoxFit.cover))
                          .toList(),
                    )
                  : const Center(child: Text('No Images')),
            ),

            // Summary panel
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.propertyType,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Price: ₹${property.totalPrice.toStringAsFixed(0)}'),
                  const SizedBox(height: 4),
                  Text('Area: ${property.landArea}'),
                  if (property.address != null) ...[
                    const SizedBox(height: 4),
                    Text(property.address!),
                  ],
                ],
              ),
            ),

            const Divider(),

            // Current-stage UI
            if (acceptedBuyer != null) ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Sale Timeline',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 300,
                child: SellerTimelineView(buyer: acceptedBuyer),
              ),
            ] else ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Manage Interested & Visited',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              // InterestedVisitedTabs(
              //   property: property,
              //   onBuyerUpdated: () => setState(() {}),
              // ),
            ],

            const Divider(),

            // Full history toggle
            if (acceptedBuyer != null)
              ExpansionTile(
                title: const Text('History & Documents'),
                children: [SellerTimelineView(buyer: acceptedBuyer!)],
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
