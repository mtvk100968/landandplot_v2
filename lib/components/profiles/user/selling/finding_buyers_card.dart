// lib/components/profiles/user/selling/finding_agents_card.dart
import 'package:flutter/material.dart';

class FindingAgentsCard extends StatelessWidget {
  const FindingAgentsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header with address/price/area/ppu
            Text('Finding Agents',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Assigning agents to your property…'),
            // onTap: navigate to original listing (commented out)
          ],
        ),
      ),
    );
  }
}
