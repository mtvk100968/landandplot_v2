// lib/components/profiles/user/buying/buying_tab.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';
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
  late Future<List<Property>> _allPropsFuture;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  void _loadProperties() {
    setState(() {
      _allPropsFuture = _fetchAllBuyingProperties();
    });
  }

  Future<void> _refresh() async {
    _loadProperties();
    await _allPropsFuture;
  }

  Future<List<Property>> _fetchAllBuyingProperties() async {
    final inTalks = await UserService().getInTalksProperties(widget.userId);
    final bought = await UserService().getBoughtProperties(widget.userId);

    // combine and de-dupe by ID
    final map = <String, Property>{};
    for (var p in [...inTalks, ...bought]) {
      map[p.id] = p;
    }
    return map.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<Property>>(
        future: _allPropsFuture,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snap.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 48),
                Center(
                  child: Text(
                    'Oops, something went wrong.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Retry'),
                  ),
                ),
              ],
            );
          }

          final props = snap.data ?? [];
          // Empty state
          if (props.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 48),
                Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'No purchases yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ],
            );
          }

          // categorize by buyer.status
          final interest = <Property>[];
          final visiting = <Property>[];
          final negotiating = <Property>[];
          final purchased = <Property>[];
          final rejected = <Property>[];

          for (var p in props) {
            Buyer? buyer;
            for (var b in p.buyers) {
              if (b.phone == widget.userId) {
                buyer = b;
                break;
              }
            }
            if (buyer == null) continue;

            switch (buyer.status) {
              case 'visitPending':
                interest.add(p);
                break;
              case 'negotiating':
                negotiating.add(p);
                break;
              case 'accepted':
                // sale in progress
                visiting.add(p);
                break;
              case 'bought':
                purchased.add(p);
                break;
              case 'rejected':
                rejected.add(p);
                break;
              default:
                visiting.add(p);
            }
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              if (interest.isNotEmpty) ...[
                const SectionHeader('Interest'),
                for (var p in interest)
                  BuyerInProgressCard(property: p, userId: widget.userId),
              ],
              if (visiting.isNotEmpty) ...[
                const SectionHeader('Visiting'),
                for (var p in visiting)
                  BuyerInProgressCard(property: p, userId: widget.userId),
              ],
              if (negotiating.isNotEmpty) ...[
                const SectionHeader('Negotiating'),
                for (var p in negotiating)
                  BuyerInProgressCard(property: p, userId: widget.userId),
              ],
              if (purchased.isNotEmpty) ...[
                const SectionHeader('Purchased'),
                for (var p in purchased) BuyerBoughtCard(property: p),
              ],
              if (rejected.isNotEmpty) ...[
                const SectionHeader('Rejected'),
                for (var p in rejected) RejectedCard(property: p),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Simple section header widget
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
}

/// Basic card for a rejected property
class RejectedCard extends StatelessWidget {
  final Property property;
  const RejectedCard({Key? key, required this.property}) : super(key: key);

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          title: Text(property.propertyOwner),
          subtitle: Text('${property.propertyType} • Rejected'),
          onTap: () {
            // TODO: navigate to your detailed Property screen
          },
        ),
      );
}
