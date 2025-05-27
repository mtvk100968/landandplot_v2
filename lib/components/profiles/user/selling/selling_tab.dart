// lib/components/profiles/user/selling/selling_tab.dart
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import 'finding_agents_card.dart';
import 'finding_buyers_card.dart';
import 'sale_in_progress_card.dart';
import 'sold_card.dart';

class SellingTab extends StatelessWidget {
  final AppUser user;
  const SellingTab({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // you’ll fetch the user’s properties via UserService later
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        FindingAgentsCard(/* pass in needed data */),
        FindingBuyersCard(/* … */),
        SaleInProgressCard(/* … */),
        SoldCard(/* … */),
      ],
    );
  }
}
