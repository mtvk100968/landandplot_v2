// lib/models/property_model.dart

class Property {
  final String id;
  final String userId;
  final String name;
  final String mobileNumber;
  final String propertyType;
  final double landArea;
  final double pricePerUnit;
  final double totalPrice;
  final String surveyNumber;
  final List<String> plotNumbers;
  final String? district; // Made nullable
  final String? mandal; // Made nullable
  // final String town;
  final String village;
  final String pincode;
  final double latitude;
  final double longitude;
  final String state;
  final String roadAccess; // Optional
  final String roadType; // Optional
  final double roadWidth; // Optional
  final String landFacing; // Optional
  final String propertyOwner;
  final List<String> images;
  final List<String> videos;
  final List<String> documents;

  Property({
    this.id = '',
    required this.userId,
    required this.name,
    required this.mobileNumber,
    required this.propertyType,
    required this.landArea,
    required this.pricePerUnit,
    required this.totalPrice,
    required this.surveyNumber,
    required this.plotNumbers,
    this.district, // Updated
    this.mandal, // Updated
    // required this.town,
    required this.village,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.state,
    this.roadAccess = '',
    this.roadType = '',
    this.roadWidth = 0.0,
    this.landFacing = '',
    required this.propertyOwner,
    required this.images,
    required this.videos,
    required this.documents,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'mobileNumber': mobileNumber,
      'propertyType': propertyType,
      'landArea': landArea,
      'pricePerUnit': pricePerUnit,
      'totalPrice': totalPrice,
      'surveyNumber': surveyNumber,
      'plotNumbers': plotNumbers,
      'district': district,
      'mandal': mandal,
      // 'town': town,
      'village': village,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'state': state,
      'roadAccess': roadAccess,
      'roadType': roadType,
      'roadWidth': roadWidth,
      'landFacing': landFacing,
      'propertyOwner': propertyOwner,
      'images': images,
      'videos': videos,
      'documents': documents,
    };
  }

  factory Property.fromMap(String id, Map<String, dynamic> map) {
    return Property(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      propertyType: map['propertyType'] ?? '',
      landArea: map['landArea']?.toDouble() ?? 0.0,
      pricePerUnit: map['pricePerUnit']?.toDouble() ?? 0.0,
      totalPrice: map['totalPrice']?.toDouble() ?? 0.0,
      surveyNumber: map['surveyNumber'] ?? '',
      plotNumbers: List<String>.from(map['plotNumbers'] ?? []),
      district: map['district'], // Updated
      mandal: map['mandal'], // Updated
      // town: map['town'] ?? '',
      village: map['village'] ?? '',
      pincode: map['pincode'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      state: map['state'] ?? '',
      roadAccess: map['roadAccess'] ?? '',
      roadType: map['roadType'] ?? '',
      roadWidth: map['roadWidth']?.toDouble() ?? 0.0,
      landFacing: map['landFacing'] ?? '',
      propertyOwner: map['propertyOwner'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      videos: List<String>.from(map['videos'] ?? []),
      documents: List<String>.from(map['documents'] ?? []),
    );
  }
}
