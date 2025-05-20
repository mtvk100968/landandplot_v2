// lib/widgets/mini-components/timeline_view.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../models/buyer_model.dart';
import '../../../../services/proof_upload_service.dart';
import '../../../../services/property_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TimelineView extends StatefulWidget {
  final String propertyId;
  final Buyer buyer; // now pass a Buyer instead of a String
  final String agentId; // ← NEW

  const TimelineView({
    Key? key,
    required this.propertyId,
    required this.buyer,
    required this.agentId, // ← NEW
  }) : super(key: key);

  @override
  _TimelineViewState createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  PlatformFile? selectedFile;
  final _proofService = ProofUploadService();
  final _propService = PropertyService();

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

  final stepShortNames = {
    'Buyer Interest Shown': 'Interest',
    'Document Verification': 'DocVerify',
    'Legal Due Diligence & Survey Check': 'LegalCheck',
    'Sale Agreement & Advance Payment': 'Agreement',
    'Stamp Duty & Registration (SRO)': 'Registration',
    'Mutation in Dharani Portal': 'Mutation',
    'Possession Handover': 'Possession',
  };

  /// Opens the same upload dialog you had, but then:
  /// 1. uploads files
  /// 2. merges URLs into widget.buyer
  /// 3. advances widget.buyer.currentStep
  /// 4. calls PropertyService.updateBuyer(oldBuyer, widget.buyer)
  void _openUploadDialog(String stepTitle, String stepShortName) async {
    List<PlatformFile> selectedFiles = [];
    final oldBuyer = Buyer.fromMap(widget.buyer.toMap());

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSt) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + close
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Upload Proof for: $stepShortName',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Please upload all relevant documents for this step. Multiple files are allowed.',
                      style: TextStyle(fontSize: 13.5, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    if (selectedFiles.isNotEmpty)
                      ...selectedFiles.map((file) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.insert_drive_file,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    file.name,
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.platform
                            .pickFiles(allowMultiple: true);
                        if (result != null && result.files.isNotEmpty) {
                          setSt(() => selectedFiles = result.files);
                        }
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Select Files'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        side: BorderSide(color: Colors.grey.shade400),
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: selectedFiles.isEmpty
                            ? null
                            : () async {
                                // 1) upload
                                final files = selectedFiles
                                    .map((f) => File(f.path!))
                                    .toList();
                                final urls =
                                    await _proofService.uploadProofFiles(
                                  propertyId: widget.propertyId,
                                  stepShortName: stepShortName,
                                  files: files,
                                );

                                // 2) merge URLs into buyer
                                switch (stepShortName) {
                                  case 'Interest':
                                    widget.buyer.interestDocs.addAll(urls);
                                    break;
                                  case 'DocVerify':
                                    widget.buyer.docVerifyDocs.addAll(urls);
                                    break;
                                  case 'LegalCheck':
                                    widget.buyer.legalCheckDocs.addAll(urls);
                                    break;
                                  case 'Agreement':
                                    widget.buyer.agreementDocs.addAll(urls);
                                    break;
                                  case 'Registration':
                                    widget.buyer.registrationDocs.addAll(urls);
                                    break;
                                  case 'Mutation':
                                    widget.buyer.mutationDocs.addAll(urls);
                                    break;
                                  case 'Possession':
                                    widget.buyer.possessionDocs.addAll(urls);
                                    break;
                                }

                                // 3) advance to next step
                                final idx = steps
                                    .indexWhere((s) => s['title'] == stepTitle);
                                final next = idx + 1;
                                if (next < steps.length) {
                                  widget.buyer.currentStep =
                                      stepShortNames[steps[next]['title']]!;
                                }

                                // 4) persist oldBuyer → newBuyer
                                await _propService.updateBuyer(
                                    widget.propertyId,
                                    oldBuyer,
                                    widget.buyer,
                                    widget.agentId);

                                // 5) If this was the final “Possession” step, mark the sale as complete:
                                if (stepShortName == 'Possession') {
                                  await PropertyService().updateBuyerStatus(
                                    propertyId: widget.propertyId,
                                    buyerPhone: widget.buyer.phone,
                                    status: 'bought',
                                  );
                                }

                                Navigator.pop(ctx);
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          backgroundColor: Colors.green.shade700,
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // use buyer.currentStep instead of widget.stage
    int currentIndex = steps.indexWhere((step) =>
        stepShortNames[step['title']]!.toLowerCase() ==
        widget.buyer.currentStep.toLowerCase());
    if (currentIndex == -1) currentIndex = 0;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Column(
          children: steps.asMap().entries.map((entry) {
            int index = entry.key;
            final step = entry.value;
            final isActive = index <= currentIndex;
            final isCurrent = index == currentIndex;
            final isLast = index == steps.length - 1;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              isActive ? Colors.green : Colors.grey[300],
                          child: Icon(
                            step['icon'] as IconData,
                            size: 16,
                            color: isActive ? Colors.white : Colors.black45,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 30,
                            color: Colors.grey[300],
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
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
                ),
                if (isCurrent) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(left: 40),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete: ${stepShortNames[step['title']]} (Upload Proof)',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _openUploadDialog(
                            step['title'] as String,
                            stepShortNames[step['title']]!,
                          ),
                          icon: const Icon(Icons.upload),
                          label: const Text('Upload Proof'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ]
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
