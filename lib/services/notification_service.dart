import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_model.dart';

class NotificationService {
  final _notifs = FirebaseFirestore.instance.collection('notifications');
  final _fcm = FirebaseMessaging.instance;
  final _functions = FirebaseFunctions.instance;

  /// Stream all notifications for a given user, newest first.
  Stream<List<AppNotification>> streamForUser(String uid) {
    return _notifs
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AppNotification.fromDoc(d)).toList());
  }

  /// Mark a notification as read.
  Future<void> markAsRead(String notifId) {
    return _notifs.doc(notifId).update({'read': true});
  }

  /// Create a new notification (and trigger push via Cloud Function).
  Future<void> create({
    required String userId,
    required String type,
    required String message,
    String? propertyId,
    bool agentAlert = false,
  }) async {
    // 1) Write to Firestore
    final doc = await _notifs.add(AppNotification(
      id: '', // Firestore will generate
      userId: userId,
      type: type,
      message: message,
      propertyId: propertyId,
      agentAlert: agentAlert,
      timestamp: DateTime.now(),
      read: false,
    ).toMap());

    // 2) Call a Cloud Function to send an FCM push to the user's tokens
    //    You need to implement the 'sendNotification' function server‐side.
    await _functions.httpsCallable('sendNotification').call({
      'notificationId': doc.id,
    });
  }

  /// Register this device's FCM token under the current user.
  Future<void> registerToken(String userId) async {
    final token = await _fcm.getToken();
    if (token != null) {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      await userRef.set({
        'fcmTokens': FieldValue.arrayUnion([token]),
      }, SetOptions(merge: true));
    }
  }

  /// Unregister the current device token (e.g. on logout).
  Future<void> unregisterToken(String userId) async {
    final token = await _fcm.getToken();
    if (token != null) {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      await userRef.update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
    }
  }
}
