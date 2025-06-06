// lib/components/profiles/user/buying/interested_card.dart

import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../models/buyer_model.dart';
import '../../../../services/property_service.dart';

class InterestedCard extends StatelessWidget {
  final Property property;
  final String userPhone; // matches Buyer.phone

  const InterestedCard({
    Key? key,
    required this.property,
    required this.userPhone,
  }) : super(key: key);

  Buyer? get _thisBuyer {
    // Option 1: use try/catch so orElse can return null
    try {
      return property.buyers.firstWhere(
        (b) => b.phone == userPhone,
      );
    } catch (_) {
      return null;
    }

    // Option 2: filter then pick first
    // final matches = property.buyers.where((b) => b.phone == userPhone);
    // return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final buyer = _thisBuyer;
    if (buyer == null) {
      return const SizedBox.shrink();
    }

    // If there's a visit date, format it now:
    String? formattedDate;
    if (buyer.date != null) {
      formattedDate =
          buyer.date!.toLocal().toString().split(' ')[0]; // YYYY-MM-DD
    }

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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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

            // “Visit Pending” vs. “Visit Date” UI
            if (buyer.date == null) ...[
              const Text('Status: Visit Pending'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  // open a date picker to set a visit date
                  final chosen = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (chosen != null) {
                    await PropertyService().updateBuyerStatus(
                      propertyId: property.id,
                      buyerPhone: userPhone,
                      visitDate: chosen,
                    );
                    // Ideally trigger a setState/hard refresh outside
                  }
                },
                child: const Text('Set Visit Date'),
              ),
            ] else ...[
              // buyer.date is not null, so show the formatted date
              Text('Visit Date: $formattedDate'),
            ],
          ],
        ),
      ),
    );
  }
}
