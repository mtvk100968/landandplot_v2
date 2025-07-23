// lib/components/profiles/user/buying/buying_tab.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';
import '../../../../services/user_service.dart';
import 'interested_card.dart';
import 'visited_card.dart';
import 'accepted_card.dart';
import 'bought_card.dart';
import 'rejected_card.dart';

class BuyingTab extends StatefulWidget {
  final String userId; // this is the buyer’s phone number
  const BuyingTab({Key? key, required this.userId}) : super(key: key);

  @override
  _BuyingTabState createState() => _BuyingTabState();
}

class _BuyingTabState extends State<BuyingTab> {
  late Future<List<Property>> _allPropertiesFuture;

  @override
  void initState() {
    super.initState();
    // load all properties where this user appears as a buyer
    _allPropertiesFuture = UserService().getBuyerProperties(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Property>>(
      future: _allPropertiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final props = snapshot.data ?? [];

        // bucket them by status/stage
        final interested = <Property>[];
        final visited = <Property>[];
        final accepted = <Property>[];
        final bought = <Property>[];
        final rejected = <Property>[];

        for (var p in props) {
          final buyer = p.buyers.firstWhere(
            (b) => b.phone == widget.userId,
            orElse: () =>
                Buyer(name: '', phone: '', status: '', currentStep: ''),
          );
          switch (buyer.status) {
            case 'visitPending':
              interested.add(p);
              break;
            case 'rejected':
              rejected.add(p);
              break;
            case 'accepted':
              if (p.stage == 'saleInProgress') {
                accepted.add(p);
              } else {
                visited.add(p);
              }
              break;
            case 'bought':
              if (p.stage == 'sold') {
                bought.add(p);
              } else {
                visited.add(p);
              }
              break;
            default:
              visited.add(p);
          }
        }

        final children = <Widget>[];

        if (interested.isNotEmpty) {
          children.add(const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text('Interested',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ));
          children.addAll(interested.map(
              (p) => InterestedCard(property: p, userPhone: widget.userId)));
        }

        if (visited.isNotEmpty) {
          children.add(const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text('Visited',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ));
          children.addAll(visited
              .map((p) => VisitedCard(property: p, userPhone: widget.userId)));
        }

        if (accepted.isNotEmpty) {
          children.add(const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text('Accepted (Sale In Progress)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ));
          children.addAll(accepted
              .map((p) => AcceptedCard(property: p, userPhone: widget.userId)));
        }

        if (bought.isNotEmpty) {
          children.add(const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text('Bought',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ));
          children.addAll(bought
              .map((p) => BoughtCard(property: p, userPhone: widget.userId)));
        }

        if (rejected.isNotEmpty) {
          children.add(const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text('Rejected',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ));
          children.addAll(rejected
              .map((p) => RejectedCard(property: p, userPhone: widget.userId)));
        }

        if (children.isEmpty) {
          return const Center(child: Text('No buying activity.'));
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: children,
        );
      },
    );
  }
}
