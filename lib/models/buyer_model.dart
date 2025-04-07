class Buyer {
  final String name;
  final String phone;
  DateTime? date;
  double? priceOffered;
  String status; // 'pending', 'accepted', 'rejected'
  List<String> notes;

  Buyer({
    required this.name,
    required this.phone,
    this.date,
    this.priceOffered,
    this.status = 'pending',
    this.notes = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'date': date?.toIso8601String(),
      'priceOffered': priceOffered,
      'status': status,
      'notes': notes,
    };
  }

  factory Buyer.fromMap(Map<String, dynamic> map) {
    return Buyer(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      date: map['date'] != null ? DateTime.tryParse(map['date']) : null,
      priceOffered: map['priceOffered']?.toDouble(),
      status: map['status'] ?? 'pending',
      notes: List<String>.from(map['notes'] ?? []),
    );
  }
}
