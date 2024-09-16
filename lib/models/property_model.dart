class Property {
  final String id;
  final String userId;
  final double landArea;
  final double landPrice;
  final double pricePerSqYard;
  final double latitude;
  final double longitude;

  Property({
    required this.id,
    required this.userId,
    required this.landArea,
    required this.landPrice,
    required this.pricePerSqYard,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'landArea': landArea,
      'landPrice': landPrice,
      'pricePerSqYard': pricePerSqYard,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Property.fromMap(String id, Map<String, dynamic> map) {
    return Property(
      id: id,
      userId: map['userId'] ?? '',
      landArea: (map['landArea'] != null) ? map['landArea'].toDouble() : 0.0,
      landPrice: (map['landPrice'] != null) ? map['landPrice'].toDouble() : 0.0,
      pricePerSqYard: (map['pricePerSqYard'] != null)
          ? map['pricePerSqYard'].toDouble()
          : 0.0,
      latitude: (map['latitude'] != null) ? map['latitude'].toDouble() : 0.0,
      longitude: (map['longitude'] != null) ? map['longitude'].toDouble() : 0.0,
    );
  }
}
