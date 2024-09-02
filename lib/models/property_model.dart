class Property {
  final String id;
  final String userId;
  final double landArea;
  final double landPrice;
  final double pricePerSqYard;

  Property({
    required this.id,
    required this.userId,
    required this.landArea,
    required this.landPrice,
    required this.pricePerSqYard,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'landArea': landArea,
      'landPrice': landPrice,
      'pricePerSqYard': pricePerSqYard,
    };
  }

  factory Property.fromMap(String id, Map<String, dynamic> map) {
    return Property(
      id: id,
      userId: map['userId'] ?? '',
      landArea: map['landArea'].toDouble(),
      landPrice: map['landPrice'].toDouble(),
      pricePerSqYard: map['pricePerSqYard'].toDouble(),
    );
  }
}