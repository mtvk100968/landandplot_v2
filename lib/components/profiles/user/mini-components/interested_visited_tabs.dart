import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';
import '../../../../services/property_service.dart';

class InterestedVisitedTabs extends StatefulWidget {
  final Property property;
  final VoidCallback onBuyerUpdated;
  const InterestedVisitedTabs({
    Key? key,
    required this.property,
    required this.onBuyerUpdated,
  }) : super(key: key);

  @override
  _InterestedVisitedTabsState createState() => _InterestedVisitedTabsState();
}

class _InterestedVisitedTabsState extends State<InterestedVisitedTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateBuyer(Buyer buyer, {required String status}) async {
    await PropertyService().updateBuyerStatus(
      propertyId: widget.property.id,
      buyerPhone: buyer.phone,
      status: status,
      visitDate: buyer.date,
      priceOffered: buyer.priceOffered,
      notes: buyer.notes,
    );
    widget.onBuyerUpdated();
  }

  @override
  Widget build(BuildContext context) {
    final buyers = widget.property.buyers;
    final interested = buyers.where((b) => b.status == 'visitPending').toList();
    final visited = buyers.where((b) => b.status != 'visitPending').toList();

    if (interested.isEmpty && visited.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Center(
          child: Text(
            "No one’s shown interest yet",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Interested'),
            Tab(text: 'Visited'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // === Interested Tab ===
              ListView.builder(
                itemCount: interested.length,
                itemBuilder: (ctx, i) {
                  final b = interested[i];
                  return ListTile(
                    title: Text(b.name),
                    subtitle: Text('Set visit date or cancel'),
                    trailing: TextButton(
                      onPressed: () => _updateBuyer(b, status: 'rejected'),
                      child: const Text('Cancel'),
                    ),
                    onTap: () async {
                      final newDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(Duration(days: 1)),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (newDate != null) {
                        b.date = newDate;
                        await _updateBuyer(b, status: 'negotiating');
                      }
                    },
                  );
                },
              ),

              // === Visited Tab ===
              ListView.builder(
                itemCount: visited.length,
                itemBuilder: (ctx, i) {
                  final b = visited[i];
                  return ListTile(
                    title: Text(b.name),
                    subtitle: Text('Status: ${b.status}'),
                    trailing: b.status == 'negotiating'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () =>
                                    _updateBuyer(b, status: 'rejected'),
                                child: const Text('Reject'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    _updateBuyer(b, status: 'accepted'),
                                child: const Text('Accept'),
                              ),
                            ],
                          )
                        : null,
                    onTap: b.status == 'accepted' ? null : () {}, // no-op
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
