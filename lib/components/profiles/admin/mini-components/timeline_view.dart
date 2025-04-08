import 'package:flutter/material.dart';

class TimelineView extends StatelessWidget {
  final String saleStatus;
  const TimelineView({Key? key, required this.saleStatus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use your original step names with associated icons.
    final steps = [
      {'title': 'Buyer Interest Shown', 'icon': Icons.visibility},
      {'title': 'Document Verification', 'icon': Icons.verified_user},
      {'title': 'Legal Due Diligence & Survey Check', 'icon': Icons.assignment},
      {
        'title': 'Sale Agreement & Advance Payment',
        'icon': Icons.assignment_turned_in
      },
      {
        'title': 'Stamp Duty & Registration (SRO)',
        'icon': Icons.app_registration
      },
      {'title': 'Mutation in Dharani Portal', 'icon': Icons.sync},
      {'title': 'Possession Handover', 'icon': Icons.home},
    ];

    // Determine the current step index based on saleStatus.
    int currentIndex = steps.indexWhere((step) =>
        (step['title'] as String).toLowerCase() == saleStatus.toLowerCase());
    if (currentIndex == -1) currentIndex = 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      child: Column(
        children: steps.asMap().entries.map((entry) {
          int index = entry.key;
          final step = entry.value;
          final isActive = index <= currentIndex;
          final isLast = index == steps.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column for the icon and connecting line.
              Column(
                children: [
                  // Circle representing the step.
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isActive ? Colors.green : Colors.grey[300],
                    child: Icon(
                      step['icon'] as IconData,
                      size: 16,
                      color: isActive ? Colors.white : Colors.black45,
                    ),
                  ),
                  // Draw a vertical line, except for the last step.
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 30,
                      color: Colors.grey[300],
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Right column for the step title.
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    step['title'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
