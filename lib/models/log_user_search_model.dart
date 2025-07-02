import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> logUserSearch({
  required String userId,
  required String phone,
  required String area,
  required String propertyType,
}) async {
  final doc = FirebaseFirestore.instance.collection('user_search_logs').doc();
  await doc.set({
    'userId': userId,
    'phone': phone,
    'area': area,
    'propertyType': propertyType,
    'timestamp': FieldValue.serverTimestamp(),
  });
}
