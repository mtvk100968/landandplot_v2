import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';
import 'package:dotted_border/dotted_border.dart';
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

// 1. isPaperworkComplete
  bool isPaperworkComplete(Buyer buyer) {
    return buyer.priceOffered != null &&
        buyer.notes.isNotEmpty &&
        buyer.status != 'visitPending';
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _editDate(Buyer buyer) async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: buyer.date ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );
    if (newDate != null) {
      // persist only the date field for this buyer
      await PropertyService().updateBuyerStatus(
        propertyId: widget.property.id,
        buyerPhone: buyer.phone,
        visitDate: newDate,
      );
      setState(() {
        buyer.date = newDate;
      });
    }
  }

  // Clear selected date.
  Future<void> _clearDate(Buyer buyer) async {
    await PropertyService().updateBuyerStatus(
      propertyId: widget.property.id,
      buyerPhone: buyer.phone,
      visitDate: null,
    );
    setState(() {
      buyer.date = null;
    });
  }

  /// Called when it’s time to fill the “visit paperwork.”
// 2. _completePaperwork
  void _completePaperwork(Buyer buyer) {
    final priceController =
        TextEditingController(text: buyer.priceOffered?.toString() ?? '');
    final noteController = TextEditingController();
    String currentStatus =
        buyer.status != 'visitPending' ? buyer.status : 'negotiating';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Complete Visit Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Offered Price"),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: currentStatus,
                  items: ['negotiating', 'accepted', 'rejected'].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.capitalize()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) currentStatus = value;
                  },
                  decoration: const InputDecoration(labelText: "Status"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: "Notes"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    double? price = double.tryParse(priceController.text);
                    String note = noteController.text.trim();
                    if (price == null || note.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text("Please enter a valid price and note.")));
                      return;
                    }
                    if (currentStatus == 'accepted' &&
                        widget.property.buyers
                            .any((b) => b.status == 'accepted' && b != buyer)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Only one buyer can be Accepted.')));
                      return;
                    }

                    // 1) Update local state
                    setState(() {
                      buyer.priceOffered = price;
                      buyer.status = currentStatus;
                      buyer.notes.add(note);
                      buyer.lastUpdated = DateTime.now();
                    });

                    // 2) Persist to Firestore via updateBuyerStatus
                    await PropertyService().updateBuyerStatus(
                      propertyId: widget.property.id,
                      buyerPhone: buyer.phone,
                      status: buyer.status,
                      visitDate: buyer.date,
                      priceOffered: buyer.priceOffered,
                      notes: buyer.notes,
                    );

                    // 3) Close the sheet
                    Navigator.pop(ctx);
                    // ← this tells AgentProfile to re-fetch both tabs:
                    widget.onBuyerUpdated();
                  },
                  child: const Text('Submit Details'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// For buyers already moved to visited, allow re-editing of details.
// 3. _editVisitedDetails
  void _editVisitedDetails(Buyer buyer) {
    final priceController =
        TextEditingController(text: buyer.priceOffered?.toString() ?? '');
    final noteController = TextEditingController();
    String currentStatus = buyer.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Visit Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Offered Price"),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: currentStatus,
                  items: ['negotiating', 'accepted', 'rejected'].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.capitalize()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) currentStatus = value;
                  },
                  decoration: const InputDecoration(labelText: "Status"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noteController,
                  decoration:
                      const InputDecoration(labelText: "Additional Notes"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    double? price = double.tryParse(priceController.text);
                    String note = noteController.text.trim();
                    if (price == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a valid price."),
                        ),
                      );
                      return;
                    }
                    if (currentStatus == 'accepted' &&
                        widget.property.buyers
                            .any((b) => b.status == 'accepted' && b != buyer)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Only one buyer can be Accepted.')),
                      );
                      return;
                    }
                    setState(() {
                      buyer.priceOffered = price;
                      buyer.status = currentStatus;
                      if (note.isNotEmpty) buyer.notes.add(note);
                      buyer.lastUpdated = DateTime.now();
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Update Details'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 4. _buildInterestedTab
  Widget _buildInterestedTab() {
    final buyers = widget.property.buyers;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: buyers.length + 1,
            itemBuilder: (ctx, i) {
              if (i < buyers.length) {
                final buyer = buyers[i];
                final isPending = buyer.status == 'visitPending';

                String dateText;
                Color dateColor;
                if (buyer.date == null) {
                  dateText = 'No date set';
                  dateColor = Colors.black;
                } else {
                  final formatted =
                      buyer.date!.toLocal().toString().split(' ')[0];
                  dateText = 'Visiting: $formatted';
                  final now = DateTime.now();
                  final diff = buyer.date!
                      .difference(DateTime(now.year, now.month, now.day))
                      .inDays;
                  if (diff > 0)
                    dateColor = Colors.orange;
                  else if (diff == 0)
                    dateColor = Colors.green;
                  else
                    dateColor = Colors.red;
                }

                final statusColor = buyer.status == 'accepted'
                    ? Colors.green
                    : buyer.status == 'rejected'
                        ? Colors.red
                        : Colors.orange;

                return Opacity(
                  opacity: isPending ? 1.0 : 0.5,
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          title: Text(buyer.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(buyer.phone),
                              const SizedBox(height: 4),
                              Text(dateText,
                                  style: TextStyle(color: dateColor)),
                              Text(
                                'Status: ${buyer.status.capitalize()}',
                                style: TextStyle(color: statusColor),
                              ),
                            ],
                          ),
                          trailing: isPending
                              ? TextButton(
                                  onPressed: () => _editDate(buyer),
                                  child: Text(buyer.date == null
                                      ? 'Set Date'
                                      : 'Change Date'),
                                )
                              : null,
                          onTap: isPending
                              ? () => _completePaperwork(buyer)
                              : null,
                        ),
                        if (buyer.date != null &&
                            (DateTime.now().isAfter(buyer.date!) ||
                                isSameDay(DateTime.now(), buyer.date!)) &&
                            !isPaperworkComplete(buyer))
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            color: Colors.red.withOpacity(0.1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.error, color: Colors.red, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Late! Please complete visit details.',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: InkWell(
                  onTap: _showAddBuyerDialog,
                  borderRadius: BorderRadius.circular(8),
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                    dashPattern: [6, 3],
                    color: Colors.grey,
                    strokeWidth: 1.5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_circle_outline),
                          SizedBox(width: 8),
                          Text(
                            'Add Interested Buyer',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 5. _buildVisitedTab
  Widget _buildVisitedTab() {
    final list = widget.property.buyers
        .where((b) => b.status != 'visitPending')
        .toList();

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final buyer = list[i];
        final formattedDate = buyer.date != null
            ? buyer.date!.toLocal().toString().split(' ')[0]
            : 'No date';
        final lastUpdated = buyer.lastUpdated != null
            ? buyer.lastUpdated!.toLocal().toString().split('.')[0]
            : '';
        final priceText = buyer.priceOffered != null
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
                Text('Visited on: $formattedDate'),
                Text(priceText),
                Text('Status: ${buyer.status.capitalize()}'),
                if (buyer.lastUpdated != null)
                  Text(
                    'Last Updated: $lastUpdated',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                if (buyer.notes.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    children: buyer.notes
                        .map((note) => Chip(label: Text(note)))
                        .toList(),
                  ),
              ],
            ),
            onTap: () => _editVisitedDetails(buyer),
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
        Expanded(
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

  void _showAddBuyerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Add Interested Buyer"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Phone Number"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();

                if (name.isEmpty || phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please enter name and number")),
                  );
                  return;
                }

                final newBuyer = Buyer(
                  name: name,
                  phone: phone,
                  date: null,
                  notes: [],
                  status: 'visitPending',
                );

                // persist to Firestore
                await PropertyService().addBuyer(widget.property.id, newBuyer);
// now update local state
                setState(() => widget.property.buyers.add(newBuyer));
                Navigator.pop(ctx);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
