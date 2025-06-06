// lib/components/profiles/user/buying/visited_card.dart

import 'package:flutter/material.dart';
import 'package:landandplot/components/profiles/agent/mini-components/interested_visited_tabs.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';
import '../../../../services/property_service.dart';

class VisitedCard extends StatelessWidget {
  final Property property;
  final String userPhone;
  const VisitedCard({
    Key? key,
    required this.property,
    required this.userPhone,
  }) : super(key: key);

  // Buyer? get _thisBuyer {
  //   return property.buyers.firstWhere(
  //     (b) => b.phone == userPhone,
  //     orElse: () => null,
  //   );
  // }

  Buyer? get _thisBuyer {
    try {
      return property.buyers.firstWhere(
            (b) => b.phone == userPhone && b.status == 'bought',
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final buyer = _thisBuyer;
    if (buyer == null) return const SizedBox.shrink();

    final formattedDate = buyer.date != null
        ? buyer.date!.toLocal().toString().split(' ')[0]
        : 'No date';

    final negotiatingOrAccepted =
        buyer.status == 'negotiating' || buyer.status == 'accepted';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // address / price / area
            Text(
              property.fullAddress,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Price: ₹${property.totalPrice.toStringAsFixed(0)}'),
                Text('Area: ${property.landArea.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 4),
            Text('₹${property.pricePerUnit.toStringAsFixed(0)}/unit'),
            const Divider(height: 20),

            // Visit details
            Text('Visited on: $formattedDate'),
            const SizedBox(height: 8),
            Text('Status: ${buyer.status.capitalize()}'),
            const SizedBox(height: 12),

            if (buyer.status == 'negotiating') ...[
              ElevatedButton(
                onPressed: () {
                  // open modal to complete negotiation: enter price/offered, change status to accepted/rejected
                  final priceController = TextEditingController(
                      text: buyer.priceOffered?.toString() ?? '');
                  String currentStatus = buyer.status;
                  final noteController = TextEditingController();

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
                              const Text('Complete Negotiation',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              TextField(
                                controller: priceController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: 'Offered Price'),
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: currentStatus,
                                items: ['negotiating', 'accepted', 'rejected']
                                    .map((s) {
                                  return DropdownMenuItem(
                                    value: s,
                                    child: Text(s.capitalize()),
                                  );
                                }).toList(),
                                onChanged: (v) {
                                  if (v != null) currentStatus = v;
                                },
                                decoration:
                                    const InputDecoration(labelText: 'Status'),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: noteController,
                                decoration:
                                    const InputDecoration(labelText: 'Notes'),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () async {
                                  final offered =
                                      double.tryParse(priceController.text);
                                  final notes = noteController.text.trim();

                                  if (offered == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Enter a valid price')),
                                    );
                                    return;
                                  }
                                  if (currentStatus == 'accepted') {
                                    // bump property stage to saleInProgress
                                    await PropertyService()
                                        .markSaleInProgress(property.id);
                                  }

                                  // update buyer status, price, notes
                                  await PropertyService().updateBuyerStatus(
                                    propertyId: property.id,
                                    buyerPhone: userPhone,
                                    status: currentStatus,
                                    priceOffered: offered,
                                    notes: [notes],
                                  );

                                  Navigator.pop(ctx);
                                },
                                child: const Text('Submit'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: const Text('Complete Negotiation'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
