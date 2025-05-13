// lib/components/profiles/user/buying/buyer_proof_upload_dialog.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../models/buyer_model.dart';
import '../../../../services/proof_upload_service2.dart';

class BuyerProofUploadDialog extends StatefulWidget {
  final String propertyId;
  final Buyer buyer;

  const BuyerProofUploadDialog({
    Key? key,
    required this.propertyId,
    required this.buyer,
  }) : super(key: key);

  @override
  _BuyerProofUploadDialogState createState() => _BuyerProofUploadDialogState();
}

class _BuyerProofUploadDialogState extends State<BuyerProofUploadDialog> {
  List<PlatformFile> _selectedFiles = [];
  final _proofService = ProofUploadService2();
  bool _uploading = false;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFiles = result.files);
    }
  }

  Future<void> _submit() async {
    setState(() => _uploading = true);
    final files = _selectedFiles.map((f) => File(f.path!)).toList();

    // Upload files and get URLs
    final urls = await _proofService.uploadProofFiles(
      propertyId: widget.propertyId,
      stepShortName: widget.buyer.currentStep,
      files: files,
    );

    // Merge URLs into the buyer model
    switch (widget.buyer.currentStep) {
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

    // Advance to next step
    const steps = [
      'Interest',
      'DocVerify',
      'LegalCheck',
      'Agreement',
      'Registration',
      'Mutation',
      'Possession',
    ];
    final idx = steps.indexOf(widget.buyer.currentStep);
    if (idx >= 0 && idx < steps.length - 1) {
      widget.buyer.currentStep = steps[idx + 1];
    }

    // Pop and return the mutated Buyer
    Navigator.of(context).pop(widget.buyer);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Upload Proof for ${widget.buyer.currentStep}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedFiles.isEmpty)
            const Text('No files selected')
          else
            ..._selectedFiles.map((f) => Text(f.name)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickFiles,
            icon: const Icon(Icons.attach_file),
            label: const Text('Pick Files'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedFiles.isEmpty || _uploading ? null : _submit,
          child: _uploading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}
