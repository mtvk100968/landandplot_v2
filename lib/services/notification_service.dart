import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final _col = FirebaseFirestore.instance.collection('notifications');

  /// Stream all notifications for a user, ordered newest first
  Stream<List<AppNotification>> streamForUser(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AppNotification.fromDoc(d)).toList());
  }

  /// Stream unread count
  Stream<int> streamUnreadCount(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notifId) async {
    await _col.doc(notifId).update({'read': true});
  }

  /// Create a new notification
  Future<void> create(AppNotification notif) async {
    await _col.add(notif.toMap());
  }
}
