// lib/components/profiles/user/selling/sale_in_progress_card.dart
import 'package:flutter/material.dart';

class SaleInProgressCard extends StatelessWidget {
  const SaleInProgressCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sale In Progress',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // TODO: buyer+agent details header + timeline view (read-only)
          ],
        ),
      ),
    );
  }
}
