// lib/components/profiles/user/selling/selling_tab.dart

import 'package:flutter/material.dart';
import '../../../../models/user_model.dart';
import '../../../../models/property_model.dart';
import '../../../../services/user_service.dart';
import 'finding_agents_card.dart';
import 'finding_buyers_card.dart';
import 'sale_in_progress_card.dart';
import 'sold_card.dart';

class SellingTab extends StatefulWidget {
  final AppUser user;
  const SellingTab({Key? key, required this.user}) : super(key: key);

  @override
  _SellingTabState createState() => _SellingTabState();
}

class _SellingTabState extends State<SellingTab> {
  late Future<List<List<Property>>> _stagesFuture;

  @override
  void initState() {
    super.initState();
    _stagesFuture = Future.wait([
      UserService()
          .getSellerPropertiesByStage(widget.user.uid, 'findingAgents'),
      UserService()
          .getSellerPropertiesByStage(widget.user.uid, 'findingBuyers'),
      UserService()
          .getSellerPropertiesByStage(widget.user.uid, 'saleInProgress'),
      UserService().getSellerPropertiesByStage(widget.user.uid, 'sold'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<Property>>>(
      future: _stagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final lists = snapshot.data!;
        final findingAgents = lists[0];
        final findingBuyers = lists[1];
        final saleInProgress = lists[2];
        final sold = lists[3];

        final cards = <Widget>[
          ...findingAgents.map((p) => FindingAgentsCard(property: p)),
          ...findingBuyers.map((p) => FindingBuyersCard(property: p)),
          ...saleInProgress.map((p) => SaleInProgressCard(property: p)),
          ...sold.map((p) => SoldCard(property: p)),
        ];

        if (cards.isEmpty) {
          return const Center(child: Text('No properties to display.'));
        }
        return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8), children: cards);
      },
    );
  }
}
