import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';
import 'package:dotted_border/dotted_border.dart';

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

  bool isPaperworkComplete(Buyer buyer) {
    return buyer.priceOffered != null &&
        buyer.notes.isNotEmpty &&
        buyer.status != 'pending';
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
      setState(() {
        buyer.date = newDate;
      });
    }
  }

  // Clear selected date.
  void _clearDate(Buyer buyer) {
    setState(() {
      buyer.date = null;
    });
  }

  /// Called when it’s time to fill the “visit paperwork.”
  void _completePaperwork(Buyer buyer) {
    final priceController =
        TextEditingController(text: buyer.priceOffered?.toString() ?? '');
    final noteController = TextEditingController();
    String currentStatus = buyer.status != 'pending' ? buyer.status : 'visited';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // to allow keyboard opening without clipping
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16),
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
                  items: ['visited', 'accepted', 'rejected', 'negotiating']
                      .map((status) {
                    return DropdownMenuItem(
                        value: status, child: Text(status.capitalize()));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      currentStatus = value;
                    }
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
                  onPressed: () {
                    double? price = double.tryParse(priceController.text);
                    String note = noteController.text.trim();
                    if (price == null || note.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text("Please enter a valid price and note.")));
                      return;
                    }
                    setState(() {
                      buyer.priceOffered = price;
                      buyer.status = currentStatus;
                      buyer.notes.add(note);
                      buyer.lastUpdated = DateTime.now();
                    });
                    Navigator.pop(ctx);
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
              top: 16),
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
                  items: ['visited', 'accepted', 'rejected', 'negotiating']
                      .map((status) {
                    return DropdownMenuItem(
                        value: status, child: Text(status.capitalize()));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      currentStatus = value;
                    }
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
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Please enter a valid price.")));
                      return;
                    }
                    setState(() {
                      buyer.priceOffered = price;
                      buyer.status = currentStatus;
                      if (note.isNotEmpty) {
                        buyer.notes.add(note);
                      }
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

  Widget _buildInterestedTab() {
    // new: only those still pending
    final List<Buyer> list =
        widget.property.buyers.where((b) => b.status == 'pending').toList();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: list.length + 1, // extra for "Add Buyer" card
            itemBuilder: (_, i) {
              if (i < list.length) {
                final buyer = list[i];

                String dateText;
                Color dateColor;
                if (buyer.date == null) {
                  dateText = "No date set";
                  dateColor = Colors.black;
                } else {
                  final formattedDate =
                      buyer.date!.toLocal().toString().split(' ')[0];
                  dateText = "Visiting: $formattedDate";
                  final today = DateTime.now();
                  final diffDays = buyer.date!
                      .difference(DateTime(today.year, today.month, today.day))
                      .inDays;
                  if (diffDays > 0) {
                    dateColor = Colors.orange;
                  } else if (diffDays == 0) {
                    dateColor = Colors.green;
                  } else {
                    dateColor = Colors.red;
                  }
                }

                return Card(
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
                            Text(dateText, style: TextStyle(color: dateColor)),
                          ],
                        ),
                        trailing: buyer.date == null
                            ? TextButton(
                                onPressed: () => _editDate(buyer),
                                child: const Text("Set Date"),
                              )
                            : TextButton(
                                onPressed: () => _editDate(buyer),
                                child: const Text("Change Date"),
                              ),
                        onTap: () => _completePaperwork(buyer),
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
                                "Late! Please complete visit details.",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }

              // ➕ Add Interested Buyer dotted card
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
                            "Add Interested Buyer",
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
        )
      ],
    );
  }

  Widget _buildVisitedTab() {
    // new: anything not pending
    final List<Buyer> list =
        widget.property.buyers.where((b) => b.status != 'pending').toList();

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) {
        final buyer = list[i];
        final formattedDate = buyer.date != null
            ? buyer.date!.toLocal().toString().split(' ')[0]
            : 'No date';
        final lastUpdated = buyer.lastUpdated != null
            ? buyer.lastUpdated!.toLocal().toString().split('.')[0]
            : '';
        final priceText = buyer.priceOffered != null
            ? "Price: ₹${buyer.priceOffered!.toStringAsFixed(0)}"
            : "Price: -";
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(buyer.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(buyer.phone),
                Text("Visited on: $formattedDate"),
                Text(priceText),
                Text("Status: ${buyer.status.capitalize()}"),
                if (buyer.lastUpdated != null)
                  Text("Last Updated: $lastUpdated",
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
              onPressed: () {
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
                  status: 'pending',
                );

                setState(() {
                  widget.property.buyers.add(newBuyer);
                });

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
