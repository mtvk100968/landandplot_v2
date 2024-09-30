// lib/components/forms/steps/step_upload_documents.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class StepUploadDocuments extends StatelessWidget {
  final List<File> documents;
  final Function() onPickDocuments;
  final Function(int) onRemoveDocument;

  const StepUploadDocuments({
    Key? key,
    required this.documents,
    required this.onPickDocuments,
    required this.onRemoveDocument,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Upload Documents Section
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Upload Documents',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        documents.isEmpty
            ? const Text('No documents selected.')
            : Column(
                children: documents.map((doc) {
                  String fileName = doc.path.split('/').last;
                  return ListTile(
                    leading: Icon(
                      doc.path.endsWith('.pdf')
                          ? Icons.picture_as_pdf
                          : Icons.image,
                      color: Colors.blue,
                      semanticLabel: doc.path.endsWith('.pdf')
                          ? 'PDF Document'
                          : 'Image Document',
                    ),
                    title: Text(fileName),
                    trailing: IconButton(
                      icon: const Icon(Icons.close,
                          semanticLabel: 'Remove Document'),
                      onPressed: () {
                        int index = documents.indexOf(doc);
                        onRemoveDocument(index);
                      },
                    ),
                  );
                }).toList(),
              ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: onPickDocuments,
          icon: const Icon(Icons.upload_file),
          label: const Text('Select Documents'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
