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
      'date': date?.toIso8601String(),
      'priceOffered': priceOffered,
      'status': status,
      'notes': notes,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory Buyer.fromMap(Map<String, dynamic> map) {
    return Buyer(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      date: map['date'] != null ? DateTime.tryParse(map['date']) : null,
      priceOffered: map['priceOffered'] != null
          ? (map['priceOffered'] as num).toDouble()
          : null,
      status: map['status'] ?? 'pending',
      notes: List<String>.from(map['notes'] ?? []),
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.tryParse(map['lastUpdated'])
          : null,
    );
  }
}
