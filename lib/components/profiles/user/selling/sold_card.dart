// lib/components/profiles/user/selling/sold_card.dart
import 'package:flutter/material.dart';

class SoldCard extends StatelessWidget {
  const SoldCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sold',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // TODO: show final documents nicely + buyer/agent + (commented-out confirmation button)
          ],
        ),
      ),
    );
  }
}
