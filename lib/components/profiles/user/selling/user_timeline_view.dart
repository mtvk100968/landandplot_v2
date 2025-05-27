// lib/components/profiles/user/selling/user_timeline_view.dart

import 'package:flutter/material.dart';
import '../../../../models/buyer_model.dart';

class UserTimelineView extends StatelessWidget {
  final Buyer buyer;
  const UserTimelineView({Key? key, required this.buyer}) : super(key: key);

  static const List<Map<String, dynamic>> _steps = [
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

  static const Map<String, String> _shortNames = {
    'Buyer Interest Shown': 'Interest',
    'Document Verification': 'DocVerify',
    'Legal Due Diligence & Survey Check': 'LegalCheck',
    'Sale Agreement & Advance Payment': 'Agreement',
    'Stamp Duty & Registration (SRO)': 'Registration',
    'Mutation in Dharani Portal': 'Mutation',
    'Possession Handover': 'Possession',
  };

  @override
  Widget build(BuildContext context) {
    final currentShort = buyer.currentStep;
    int currentIndex = _steps.indexWhere((s) =>
        _shortNames[s['title']]!.toLowerCase() == currentShort.toLowerCase());
    if (currentIndex == -1) currentIndex = 0;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: _steps.asMap().entries.map((entry) {
            final idx = entry.key;
            final step = entry.value;
            final isCompleted = idx < currentIndex;
            final isCurrent = idx == currentIndex;
            final isLast = idx == _steps.length - 1;

            final circleColor =
                (isCompleted || isCurrent) ? Colors.green : Colors.grey[300];
            final iconColor =
                (isCompleted || isCurrent) ? Colors.white : Colors.black45;
            final lineColor = isCompleted ? Colors.green : Colors.grey[300];

            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: circleColor,
                          child: Icon(
                            step['icon'] as IconData,
                            size: 16,
                            color: iconColor,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 40,
                            color: lineColor,
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step['title'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: (isCompleted || isCurrent)
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: (isCompleted || isCurrent)
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
