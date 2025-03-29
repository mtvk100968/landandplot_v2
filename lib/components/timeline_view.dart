import 'package:flutter/material.dart';

class TimelineView extends StatelessWidget {
  final String saleStatus;
  const TimelineView({Key? key, required this.saleStatus}) : super(key: key);

  Widget _buildTimelineStep(String title, bool isActive) {
    return Row(
      children: [
        Icon(Icons.circle,
            size: 12, color: isActive ? Colors.green : Colors.grey),
        const SizedBox(width: 8),
        Text(title),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // For demonstration, saleStatus can be '', 'initiated', 'in-progress', or 'complete'
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimelineStep(
          'Sale Initiated',
          saleStatus == 'initiated' ||
              saleStatus == 'in-progress' ||
              saleStatus == 'complete',
        ),
        const SizedBox(height: 8),
        _buildTimelineStep(
          'Sale in Progress',
          saleStatus == 'in-progress' || saleStatus == 'complete',
        ),
        const SizedBox(height: 8),
        _buildTimelineStep(
          'Sale Complete',
          saleStatus == 'complete',
        ),
      ],
    );
  }
}
