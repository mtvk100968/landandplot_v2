import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../services/proof_upload_service.dart';
import 'dart:io';

class TimelineView extends StatefulWidget {
  final String propertyId;
  final String saleStatus;

  const TimelineView({
    Key? key,
    required this.propertyId,
    required this.saleStatus,
  }) : super(key: key);

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  PlatformFile? selectedFile;

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

  void _openUploadDialog(String stepTitle, String stepShortName) async {
    List<PlatformFile> selectedFiles = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                    // Top Row: Title and Close
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upload Proof for: $stepShortName',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Instructions
                    const Text(
                      'Please upload all relevant documents for this step. Multiple files are allowed.',
                      style: TextStyle(fontSize: 13.5, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),

                    // File list view
                    if (selectedFiles.isNotEmpty)
                      ...selectedFiles.map((file) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.insert_drive_file,
                                    size: 20, color: Colors.grey),
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

                    // Select Files Button
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.platform
                            .pickFiles(allowMultiple: true);
                        if (result != null && result.files.isNotEmpty) {
                          setState(() {
                            selectedFiles = result.files;
                          });
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

                    // Done Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (selectedFiles.isEmpty) return;

                          final service = ProofUploadService();

                          // Convert PlatformFile to File
                          List<File> fileList =
                              selectedFiles.map((f) => File(f.path!)).toList();

                          // Upload
                          final urls = await service.uploadProofFiles(
                            propertyId:
                                widget.propertyId, // pass from parent widget
                            stepShortName: stepShortName,
                            files: fileList,
                          );

                          // Update Firestore
                          await service.updateProofInFirestore(
                            propertyId: widget.propertyId,
                            stepShortName: stepShortName,
                            fileUrls: urls,
                          );

                          Navigator.pop(context);
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
    int currentIndex = steps.indexWhere((step) =>
        (step['title'] as String).toLowerCase() ==
        widget.saleStatus.toLowerCase());
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
                              stepShortNames[step['title']]!),
                          icon: const Icon(Icons.upload),
                          label: const Text('Upload Proof'),
                        ),
                        if (selectedFile != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Selected File: ${selectedFile!.name}',
                              style: const TextStyle(fontSize: 12),
                            ),
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
