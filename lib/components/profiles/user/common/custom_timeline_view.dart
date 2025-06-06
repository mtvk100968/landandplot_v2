// lib/components/profiles/user/common/custom_timeline_view.dart

import 'package:flutter/material.dart';
import '../../../../models/buyer_model.dart';

class CustomTimelineView extends StatelessWidget {
  final Buyer buyer;
  const CustomTimelineView({Key? key, required this.buyer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define each step with title, shortName (matches buyer.currentStep), icon, and docs list.
    final List<_TimelineStep> steps = [
      _TimelineStep(
        title: 'Buyer Interest Shown',
        shortName: 'Interest',
        icon: Icons.remove_red_eye,
        docs: buyer.interestDocs,
      ),
      _TimelineStep(
        title: 'Document Verification',
        shortName: 'DocVerify',
        icon: Icons.verified_user,
        docs: buyer.docVerifyDocs,
      ),
      _TimelineStep(
        title: 'Legal Due Diligence & Survey',
        shortName: 'LegalCheck',
        icon: Icons.assignment,
        docs: buyer.legalCheckDocs,
      ),
      _TimelineStep(
        title: 'Sale Agreement & Advance Payment',
        shortName: 'Agreement',
        icon: Icons.assignment_turned_in,
        docs: buyer.agreementDocs,
      ),
      _TimelineStep(
        title: 'Stamp Duty & Registration (SRO)',
        shortName: 'Registration',
        icon: Icons.app_registration,
        docs: buyer.registrationDocs,
      ),
      _TimelineStep(
        title: 'Mutation in Dharani Portal',
        shortName: 'Mutation',
        icon: Icons.sync,
        docs: buyer.mutationDocs,
      ),
      _TimelineStep(
        title: 'Possession Handover',
        shortName: 'Possession',
        icon: Icons.home,
        docs: buyer.possessionDocs,
      ),
    ];

    // Find index of the current step; default to 0 if not found
    int currentIndex = steps.indexWhere(
      (s) => s.shortName.toLowerCase() == buyer.currentStep.toLowerCase(),
    );
    if (currentIndex == -1) currentIndex = 0;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          children: steps.asMap().entries.map((entry) {
            final int index = entry.key;
            final _TimelineStep step = entry.value;

            // Determine state: completed, current, or upcoming
            final bool isCompleted = index < currentIndex;
            final bool isCurrent = index == currentIndex;
            final bool isLast = index == steps.length - 1;

            // Colors
            final Color circleColor = isCompleted
                ? Colors.green
                : isCurrent
                    ? Colors.blue
                    : Colors.grey.shade400;
            final Color iconColor = Colors.white;
            final Color lineColor =
                isCompleted ? Colors.green : Colors.grey.shade300;
            final TextStyle titleStyle = TextStyle(
              fontSize: 14,
              fontWeight: isCompleted || isCurrent
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isCompleted || isCurrent ? Colors.black : Colors.grey,
            );

            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline indicator (circle + vertical line)
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: circleColor,
                          child: Icon(step.icon, size: 16, color: iconColor),
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
                    // Step content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(step.title, style: titleStyle),
                          const SizedBox(height: 6),
                          // If step is completed or current, show any uploaded docs as Chips
                          if ((isCompleted || isCurrent) &&
                              step.docs.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: step.docs.map((url) {
                                return GestureDetector(
                                  onTap: () {
                                    // TODO: open URL in a browser or PDF viewer
                                  },
                                  child: Chip(
                                    backgroundColor: Colors.grey.shade200,
                                    label: Text(
                                      'View',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Internal helper class to bundle step data
class _TimelineStep {
  final String title;
  final String shortName;
  final IconData icon;
  final List<String> docs;

  _TimelineStep({
    required this.title,
    required this.shortName,
    required this.icon,
    required this.docs,
  });
}
