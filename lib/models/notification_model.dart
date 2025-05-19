import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String userId;
  final String type; // e.g. 'visitReminder','newInterest','negotiationUpdate'
  final String message;
  final DateTime timestamp;
  final bool read;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.message,
    required this.timestamp,
    this.read = false,
  });

  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppNotification(
      id: doc.id,
      userId: data['userId'],
      type: data['type'],
      message: data['message'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      read: data['read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'type': type,
        'message': message,
        'timestamp': Timestamp.fromDate(timestamp),
        'read': read,
      };
}
