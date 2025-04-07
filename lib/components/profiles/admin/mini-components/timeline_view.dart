import 'package:flutter/material.dart';

class TimelineView extends StatelessWidget {
  final String saleStatus;
  const TimelineView({Key? key, required this.saleStatus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'title': 'Buyer Interest Shown', 'key': 'interest'},
      {'title': 'Document Verification', 'key': 'verification'},
      {'title': 'Legal Due Diligence & Survey Check', 'key': 'due_diligence'},
      {'title': 'Sale Agreement & Advance Payment', 'key': 'agreement'},
      {'title': 'Stamp Duty & Registration (SRO)', 'key': 'registration'},
      {'title': 'Mutation in Dharani Portal', 'key': 'mutation'},
      {'title': 'Possession Handover', 'key': 'possession'},
    ];

    int currentIndex = steps.indexWhere((step) => step['key'] == saleStatus);
    if (currentIndex == -1) currentIndex = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final isActive = index <= currentIndex;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dot + Line Column
            SizedBox(
              width: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top line
                  if (index != 0)
                    Container(
                      width: 2,
                      height: 12,
                      color: index <= currentIndex
                          ? Colors.green
                          : Colors.grey[300],
                    ),
                  // Dot
                  Container(
                    padding: EdgeInsets.only(bottom: 2),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive ? Colors.green : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: const SizedBox(width: 8, height: 8),
                  ),
                  // Bottom line
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 30,
                      color: index < currentIndex
                          ? Colors.green
                          : Colors.grey[300],
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Step Text
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  steps[index]['title']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: isActive ? Colors.black : Colors.grey,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
