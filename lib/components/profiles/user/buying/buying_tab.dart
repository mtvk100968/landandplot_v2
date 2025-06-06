// lib/components/profiles/user/buying/buying_tab.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';
import '../../../../services/user_service.dart';
import 'interested_card.dart';
import 'visited_card.dart';

class BuyingTab extends StatefulWidget {
  final String userId;
  const BuyingTab({Key? key, required this.userId}) : super(key: key);

  @override
  _BuyingTabState createState() => _BuyingTabState();
}

class _BuyingTabState extends State<BuyingTab> {
  late Future<List<Property>> _allPropertiesFuture;

  @override
  void initState() {
    super.initState();
    // fetch all properties in which this user is a buyer
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

        final props = snapshot.data ?? [];
        // filter into groups by buyer status
        final interested = <Property>[];
        final visited = <Property>[];
        final accepted = <Property>[];
        final bought = <Property>[];
        final rejected = <Property>[];

        for (var p in props) {
          // find the Buyer object for this user
          final buyer = p.buyers.firstWhere(
            (b) => b.phone == widget.userId,
            orElse: () =>
                Buyer(name: '', phone: '', status: '', currentStep: ''),
          );
          if (buyer.status == 'visitPending') {
            interested.add(p);
          } else if (buyer.status == 'rejected') {
            rejected.add(p);
          } else if (buyer.status == 'accepted' &&
              p.stage == 'saleInProgress') {
            accepted.add(p);
          } else if (buyer.status == 'bought' && p.stage == 'sold') {
            bought.add(p);
          } else {
            // any other non-pending states count as visited
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

        // placeholders for Accepted, Bought, Rejected
        if (accepted.isNotEmpty) {
          children.add(const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text('Accepted (Sale In Progress)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ));
          // TODO: map to AcceptedCard
        }
        if (bought.isNotEmpty) {
          children.add(const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text('Bought',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ));
          // TODO: map to BoughtCard
        }
        if (rejected.isNotEmpty) {
          children.add(const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text('Rejected',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ));
          // TODO: map to RejectedCard
        }

        if (children.isEmpty) {
          return const Center(child: Text('No buying activity.'));
        }

        return ListView(children: children);
      },
    );
  }
}
