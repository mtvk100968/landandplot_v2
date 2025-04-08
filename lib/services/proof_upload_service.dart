import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProofUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Uploads files and returns their URLs
  Future<List<String>> uploadProofFiles({
    required String propertyId,
    required String stepShortName,
    required List<File> files,
  }) async {
    List<String> downloadUrls = [];

    for (File file in files) {
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

  /// Updates the Firestore record with uploaded proof URLs
  Future<void> updateProofInFirestore({
    required String propertyId,
    required String stepShortName,
    required List<String> fileUrls,
  }) async {
    final propertyRef = _firestore.collection('properties').doc(propertyId);

    await propertyRef.set({
      'proofs': {
        stepShortName: FieldValue.arrayUnion(fileUrls),
      }
    }, SetOptions(merge: true));
  }
}
