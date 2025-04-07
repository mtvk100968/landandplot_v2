import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart'; // Import the Buyer model

class InterestedVisitedTabs extends StatefulWidget {
  final Property property;
  const InterestedVisitedTabs({Key? key, required this.property})
      : super(key: key);

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

  void _editDate(Buyer buyer) async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: buyer.date ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );
    if (newDate != null) {
      setState(() {
        buyer.date = newDate;
      });
    }
  }

  void _editNotes(Buyer buyer) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Note'),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Enter note'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final note = controller.text.trim();
                if (note.isNotEmpty) {
                  setState(() {
                    buyer.notes.add(note);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestedTab() {
    final List<Buyer> list = widget.property.interestedUsers;
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) {
        final buyer = list[i];
        final dateText = buyer.date != null
            ? 'Visiting: ${buyer.date!.toLocal().toString().split(' ')[0]}'
            : 'No visit date';
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(buyer.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(buyer.phone),
                Text(dateText),
              ],
            ),
            onTap: () => _editDate(buyer),
          ),
        );
      },
    );
  }

  Widget _buildVisitedTab() {
    final List<Buyer> list = widget.property.visitedUsers;
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) {
        final buyer = list[i];
        final dateText = buyer.date != null
            ? 'Visited: ${buyer.date!.toLocal().toString().split(' ')[0]}'
            : 'No date';
        final price = buyer.priceOffered != null
            ? 'Price: ₹${buyer.priceOffered!.toStringAsFixed(0)}'
            : 'Price: -';
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(buyer.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(buyer.phone),
                Text(dateText),
                Text(price),
                if (buyer.notes.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    children: buyer.notes
                        .map((note) => Chip(label: Text(note)))
                        .toList(),
                  ),
              ],
            ),
            onTap: () => _editNotes(buyer),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Interested'),
            Tab(text: 'Visited'),
          ],
        ),
        SizedBox(
          height: 300,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildInterestedTab(),
              _buildVisitedTab(),
            ],
          ),
        ),
      ],
    );
  }
}
