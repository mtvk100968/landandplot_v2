// lib/components/profiles/user/buying/buying_tab.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../services/user_service.dart';
import './buyer_in_progress_card.dart';
import './buyer_bought_card.dart';

class BuyingTab extends StatefulWidget {
  final String userId;
  const BuyingTab({Key? key, required this.userId}) : super(key: key);

  @override
  _BuyingTabState createState() => _BuyingTabState();
}

class _BuyingTabState extends State<BuyingTab> {
  late Future<List<Property>> _inProgressFuture;
  late Future<List<Property>> _boughtFuture;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _inProgressFuture = _userService.getInTalksProperties(widget.userId);
    _boughtFuture = _userService.getBoughtProperties(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('In Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          FutureBuilder<List<Property>>(
            future: _inProgressFuture,
            builder: (ctx, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = snap.data;
              if (list == null || list.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('No in-progress purchases'),
                );
              }
              return Column(
                children: list
                    .map((p) =>
                        BuyerInProgressCard(property: p, userId: widget.userId))
                    .toList(),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('Bought',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          FutureBuilder<List<Property>>(
            future: _boughtFuture,
            builder: (ctx, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = snap.data;
              if (list == null || list.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('No completed purchases'),
                );
              }
              return Column(
                children:
                    list.map((p) => BuyerBoughtCard(property: p)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
