// lib/components/profiles/user/selling/seller_timeline_view.dart

import 'package:flutter/material.dart';
import '../../../../models/buyer_model.dart';

class SellerTimelineView extends StatelessWidget {
  final Buyer buyer;
  const SellerTimelineView({Key? key, required this.buyer}) : super(key: key);

  static const List<String> _stepTitles = [
    'Buyer Interest Shown',
    'Document Verification',
    'Legal Due Diligence & Survey Check',
    'Sale Agreement & Advance Payment',
    'Stamp Duty & Registration (SRO)',
    'Mutation in Dharani Portal',
    'Possession Handover',
  ];

  static const Map<String, List<String>> _docsByStep = {
    'Buyer Interest Shown': ['interestDocs'],
    'Document Verification': ['docVerifyDocs'],
    'Legal Due Diligence & Survey Check': ['legalCheckDocs'],
    'Sale Agreement & Advance Payment': ['agreementDocs'],
    'Stamp Duty & Registration (SRO)': ['registrationDocs'],
    'Mutation in Dharani Portal': ['mutationDocs'],
    'Possession Handover': ['possessionDocs'],
  };

  List<String> _extractDocs(String stepKey) {
    switch (stepKey) {
      case 'Buyer Interest Shown':
        return buyer.interestDocs;
      case 'Document Verification':
        return buyer.docVerifyDocs;
      case 'Legal Due Diligence & Survey Check':
        return buyer.legalCheckDocs;
      case 'Sale Agreement & Advance Payment':
        return buyer.agreementDocs;
      case 'Stamp Duty & Registration (SRO)':
        return buyer.registrationDocs;
      case 'Mutation in Dharani Portal':
        return buyer.mutationDocs;
      case 'Possession Handover':
        return buyer.possessionDocs;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _stepTitles.map((title) {
        final docs = _extractDocs(title);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              if (docs.isEmpty)
                const Text('No documents uploaded')
              else
                Column(
                  children: docs.map((url) {
                    return InkWell(
                      onTap: () {
                        // TODO: open url in browser or image viewer
                      },
                      child: Text(
                        url,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
