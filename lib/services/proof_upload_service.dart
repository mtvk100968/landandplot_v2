// lib/services/proof_upload_service.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/buyer_model.dart';
import 'property_service.dart';

class ProofUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final PropertyService _propertyService = PropertyService();

  /// Uploads files and returns their URLs
  Future<List<String>> uploadProofFiles({
    required String propertyId,
    required String stepShortName,
    required List<File> files,
  }) async {
    List<String> downloadUrls = [];

    for (final file in files) {
      final filename =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final storageRef = _storage
          .ref()
          .child('property_proofs/$propertyId/$stepShortName/$filename');

      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);
    }

    return downloadUrls;
  }

  /// Adds the URLs into the correct Buyer field and persists via PropertyService
  Future<void> updateProofInFirestore({
    required String propertyId,
    required Buyer buyer,
    required String stepShortName,
    required List<String> fileUrls,
  }) async {
    // 1) merge into the matching list on the buyer
    switch (stepShortName) {
      case 'Interest':
        buyer.interestDocs.addAll(fileUrls);
        break;
      case 'DocVerify':
        buyer.docVerifyDocs.addAll(fileUrls);
        break;
      case 'LegalCheck':
        buyer.legalCheckDocs.addAll(fileUrls);
        break;
      case 'Agreement':
        buyer.agreementDocs.addAll(fileUrls);
        break;
      case 'Registration':
        buyer.registrationDocs.addAll(fileUrls);
        break;
      case 'Mutation':
        buyer.mutationDocs.addAll(fileUrls);
        break;
      case 'Possession':
        buyer.possessionDocs.addAll(fileUrls);
        break;
      default:
        throw ArgumentError('Unknown stepShortName: $stepShortName');
    }

    // 2) persist the updated buyer back into Firestore
    await _propertyService.updateBuyer(propertyId, buyer, buyer);
  }
}
