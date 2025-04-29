import 'package:cloud_firestore/cloud_firestore.dart';

class Buyer {
  final String name;
  final String phone;
  DateTime? date;
  double? priceOffered;
  // Options: 'pending', 'visited', 'accepted', 'rejected', 'negotiating'
  String status;
  List<String> notes;
  DateTime? lastUpdated;

  Buyer({
    required this.name,
    required this.phone,
    this.date,
    this.priceOffered,
    this.status = 'pending',
    this.notes = const [],
    this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      if (date != null) 'date': Timestamp.fromDate(date!),
      'priceOffered': priceOffered,
      'status': status,
      'notes': notes,
      if (lastUpdated != null) 'lastUpdated': Timestamp.fromDate(lastUpdated!),
    };
  }

  factory Buyer.fromMap(Map<String, dynamic> map) {
    final rawDate = map['date'];
    final rawUpdated = map['lastUpdated'];
    return Buyer(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      date: rawDate is Timestamp
          ? rawDate.toDate()
          : rawDate is DateTime
              ? rawDate
              : null,
      priceOffered: (map['priceOffered'] as num?)?.toDouble(),
      status: map['status'] ?? 'pending',
      notes: List<String>.from(map['notes'] ?? []),
      lastUpdated: rawUpdated is Timestamp
          ? rawUpdated.toDate()
          : rawUpdated is DateTime
              ? rawUpdated
              : null,
    );
  }
}
