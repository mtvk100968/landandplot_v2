import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents an in‐app or push notification.
class AppNotification {
  final String id;
  final String userId; // UID of the recipient
  final String type; // e.g. 'newProperty','visitReminder','saleStage'
  final String message; // human‐readable text
  final String? propertyId; // optional link back to a Property
  final bool agentAlert; // true if this should be tagged “Agent”
  final DateTime timestamp; // when it was created
  final bool read; // has user seen it?

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.message,
    this.propertyId,
    this.agentAlert = false,
    required this.timestamp,
    this.read = false,
  });

  /// Create from Firestore document
  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppNotification(
      id: doc.id,
      userId: data['userId'] as String,
      type: data['type'] as String,
      message: data['message'] as String,
      propertyId: data['propertyId'] as String?,
      agentAlert: data['agentAlert'] as bool? ?? false,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      read: data['read'] as bool? ?? false,
    );
  }

  /// Serialize for Firestore
  Map<String, dynamic> toMap() => {
        'userId': userId,
        'type': type,
        'message': message,
        if (propertyId != null) 'propertyId': propertyId,
        'agentAlert': agentAlert,
        'timestamp': Timestamp.fromDate(timestamp),
        'read': read,
      };
}
