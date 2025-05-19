// lib/components/profiles/user/buying/buyer_in_progress_card.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';
import '../../../../services/property_service.dart';
import './buyer_proof_upload_dialog.dart';
import './buying_detail_screen.dart';

class BuyerInProgressCard extends StatefulWidget {
  final Property property;
  final String userId;

  const BuyerInProgressCard({
    Key? key,
    required this.property,
    required this.userId,
  }) : super(key: key);

  @override
  _BuyerInProgressCardState createState() => _BuyerInProgressCardState();
}

class _BuyerInProgressCardState extends State<BuyerInProgressCard> {
  late Buyer _buyer;
  final PropertyService _propService = PropertyService();
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    // find this user's Buyer entry by phone or name
    _buyer = widget.property.buyers.firstWhere(
      (b) => b.phone == widget.userId || b.name == widget.userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BuyingDetailScreen(
                property: widget.property,
                buyer: _buyer,
              ),
            ),
          );
        },
        child: Column(
          children: [
            ListTile(
              title: Text(widget.property.propertyOwner),
              subtitle: Text('${widget.property.propertyType} • In Progress'),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
            ),
            // if (_expanded) … // your existing expanded UI
          ],
        ),
      ),
    );
  }
}
