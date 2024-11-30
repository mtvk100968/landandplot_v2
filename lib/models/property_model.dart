// lib/models/property_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String? district; // Kept for backward compatibility
  final String? mandal;
  final String? village; // <--- Added Village Field
  final String? city;
  // final String town;
  final String pincode;
  final double latitude;
  final double longitude;
  final String? state;
  final String roadAccess; // Optional
  final String roadType; // Optional
  final double roadWidth; // Optional
  final String landFacing; // Optional
  final String propertyOwner;
  final List<String> images;
  final List<String> videos;
  final List<String> documents;
  final String? address; // <--- Added Address Field

  // **New Fields**
  final String userType; // 'Owner' or 'Agent'
  final String? ventureName; // Required for 'Plot' or 'Farm Land'

  final Timestamp createdAt;

  // **Add isFavorited field**
  bool isFavorited;  // This field is used to manage the favorite status

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
    this.city, // Added
    this.district, // Updated
    this.mandal,
    this.village, // Updated
    this.state,
    // required this.town,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    // Updated
    this.roadAccess = '',
    this.roadType = '',
    this.roadWidth = 0.0,
    this.landFacing = '',
    required this.propertyOwner,
    required this.images,
    required this.videos,
    required this.documents,
    this.address,

    // **Initialize New Fields**
    required this.userType,
    this.ventureName,
    required this.createdAt,
    this.isFavorited = false,  // Default value is false
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
      'village': village,
      'city': city,
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
      'address': address,
      'userType': userType,
      'ventureName': ventureName,
      'createdAt': createdAt,
      'isFavorited': isFavorited, // Include isFavorited in toMap
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
      mandal: map['mandal'],
      village: map['village'], // Updated
      city: map['city'], // Added
      // town: map['town'] ?? '',
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
      address: map['address'],

      // **Initialize New Fields from Map**
      userType: map['userType'] ?? 'Owner',
      ventureName: map['ventureName'],

      createdAt: map['createdAt'] ?? Timestamp.now(),
      isFavorited: map['isFavorited'] ?? false, // Default to false if not found
    );
  }

  // In property_model.dart
  factory Property.fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Property(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      propertyType: data['propertyType'] ?? '',
      landArea: data['landArea']?.toDouble() ?? 0.0,
      pricePerUnit: data['pricePerUnit']?.toDouble() ?? 0.0,
      totalPrice: data['totalPrice']?.toDouble() ?? 0.0,
      surveyNumber: data['surveyNumber'] ?? '',
      plotNumbers: List<String>.from(data['plotNumbers'] ?? []),
      district: data['district'],
      mandal: data['mandal'],
      village: data['village'],
      city: data['city'],
      pincode: data['pincode'] ?? '',
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      state: data['state'] ?? '',
      roadAccess: data['roadAccess'] ?? '',
      roadType: data['roadType'] ?? '',
      roadWidth: data['roadWidth']?.toDouble() ?? 0.0,
      landFacing: data['landFacing'] ?? '',
      propertyOwner: data['propertyOwner'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      videos: List<String>.from(data['videos'] ?? []),
      documents: List<String>.from(data['documents'] ?? []),
      address: data['address'],
      userType: data['userType'] ?? 'Owner',
      ventureName: data['ventureName'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isFavorited: data.containsKey('isFavorited') ? data['isFavorited'] : false,
    );
  }
}
