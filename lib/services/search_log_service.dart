import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchLogService {
  static Future<void> logUserSearch({
    required String searchType,
    required String searchArea,
    double? lat,
    double? lng,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    // 1. Log the search
    await FirebaseFirestore.instance.collection('user_search_logs').add({
      'uid': user?.uid,
      'phoneNumber': user?.phoneNumber,
      'searchType': searchType,
      'searchArea': searchArea,
      'timestamp': FieldValue.serverTimestamp(),
      'lat': lat,
      'lng': lng,
    });

    // 2. Update count
    final docId = '${searchArea.toLowerCase()}_${searchType.toLowerCase()}';
    final docRef = FirebaseFirestore.instance.collection('search_counts').doc(docId);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      int newCount = 1;

      if (snapshot.exists) {
        final data = snapshot.data();
        final current = (data?['count'] ?? 0) as int;
        newCount = current + 1;
      }

      tx.set(docRef, {
        'area': searchArea,
        'type': searchType,
        'count': newCount,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // 3. Trigger alert when multiple of 10
      if (newCount % 10 == 0) {
        await FirebaseFirestore.instance.collection('search_alerts').add({
          'message': '🔍 $newCount people searched $searchType in $searchArea',
          'area': searchArea,
          'type': searchType,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}
